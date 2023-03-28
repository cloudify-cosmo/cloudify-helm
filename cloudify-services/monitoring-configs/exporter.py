"""exporter.py: a script that re-exposes pod statuses in a prometheus format

This runs a HTTP server on 127.0.0.1:8000 that responds to any GET with
a text response containing the up{} metric for every pod found in the local
k8s namespace.
"""
import json
import os
import pathlib
import ssl
import http.server
import urllib.request


def get_metrics():
    """Return metrics based on the pods response from the k8s api.

    Fetch the list of pods in the current namespace, and return them in the
    format of prometheus.
    For example, this will return a list like:
    ['up{job="rest-service", instance="192.168.2.2"}']
    """
    sa_dir = pathlib.Path('/var/run/secrets/kubernetes.io/serviceaccount')
    k8s_addr = os.environ['KUBERNETES_SERVICE_HOST']
    namespace = (sa_dir / 'namespace').read_text()
    token = (sa_dir / 'token').read_text()

    url = f'https://{k8s_addr}/api/v1/namespaces/{namespace}/pods'
    sslcontext = ssl.create_default_context()
    sslcontext.load_verify_locations(cafile=sa_dir / 'ca.crt')

    with urllib.request.urlopen(
        urllib.request.Request(
            url,
            method='GET',
            headers={'Authorization': f'Bearer {token}'},
        ),
        context=sslcontext,
    ) as req:
        pods = json.load(req)

    parts = []
    for pod in pods['items']:
        try:
            cloudify_name = pod['metadata']['labels']['cloudify-name']
            pod_ip = pod['status']['podIP']
            is_up = all(
                cs['ready'] for cs in pod['status']['containerStatuses']
            )
        except KeyError:
            continue
        parts.append(
            f'manager_service{{name="{cloudify_name}", instance="{pod_ip}"}}'
            f' {1 if is_up else 0}'
        )
    return '\n'.join(parts).encode()


class MetricsHandler(http.server.BaseHTTPRequestHandler):
    """A Handler that always returns 200 with the result of get_metrics()"""

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(get_metrics() + b'\n')


if __name__ == '__main__':
    server_address = ('127.0.0.1', 8000)
    with http.server.HTTPServer(server_address, MetricsHandler) as httpd:
        httpd.serve_forever()
