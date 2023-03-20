# Cloudify manager AIO helm chart

## Description

It's a helm chart for cloudify manager which is:

* Not highly available, has one replica only.
* Has no persistent volume to survive restarts/failures.
* Has all components on board (as part of docker container): Message Broker and DB part of it.

**This is the best and most simple way to make yourself familiar with cloudify, running a Cloudify manager AIO is a matter of minutes**

## Installation
```bash
helm repo add cloudify-helm https://cloudify-cosmo.github.io/cloudify-helm

helm install cloudify-manager-aio cloudify-helm/cloudify-manager-aio
```

## Configuration options of cloudify-manager-aio values.yaml

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext | object | object | Parameters group for k8s containers security context |
| fullnameOverride | string | `""` |  |
| image | object | object | Parameters group for Docker images |
| image.pullPolicy | string | `"IfNotPresent"` | Specify a imagePullPolicy, Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'. ref: http://kubernetes.io/docs/user-guide/images/#pre-pulling-images |
| image.repository | string | `"cloudifyplatform/community-cloudify-manager-aio"` | Docker image repository |
| image.tag | string | `"6.4.2"` | Docker image tag |
| ingress | object | object | Parameters group for ingress (managed external access to service) |
| ingress.annotations | object | object | Ingress annotation object. Please see an example in values.yaml file |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.host | string | `"cfy-efs-app.eks.cloudify.co"` | Hostname for ingress connection |
| ingress.ingressClassName | string | `"nginx"` | Ingress Class Name |
| ingress.tls | object | object | Ingress TLS parameters |
| ingress.tls.enabled | bool | `false` | Enabled TLS connections for Ingress |
| ingress.tls.secretName | string | `"cfy-tls-ingress"` | k8s secret name with TLS certificates for ingress |
| livenessProbe | object | object | Parameters group for pod liveness probe |
| livenessProbe.enabled | bool | `false` | Enable liveness probe |
| livenessProbe.failureThreshold | int | `8` | liveness probe failure threshold |
| livenessProbe.httpGet.path | string | `"/api/v3.1/ok"` | liveness probe HTTP GET path |
| livenessProbe.initialDelaySeconds | int | `600` | liveness probe initial delay in seconds |
| livenessProbe.periodSeconds | int | `30` | liveness probe period in seconds |
| livenessProbe.successThreshold | int | `1` | liveness probe success threshold |
| livenessProbe.timeoutSeconds | int | `15` | liveness probe timeout in seconds |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | Node labels for default backend pod assignment. Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| podSecurityContext | object | object | Parameters group for k8s pod security context |
| readinessProbe | object | object | Parameters group for pod readiness probe |
| readinessProbe.enabled | bool | `true` | Enable readiness probe |
| readinessProbe.failureThreshold | int | `2` | readiness probe failure threshold |
| readinessProbe.httpGet.path | string | `"/console"` | readiness probe HTTP GET path |
| readinessProbe.initialDelaySeconds | int | `0` | readiness probe initial delay in seconds |
| readinessProbe.periodSeconds | int | `10` | readiness probe period in seconds |
| readinessProbe.successThreshold | int | `2` | readiness probe success threshold |
| readinessProbe.timeoutSeconds | int | `5` | readiness probe timeout in seconds |
| resources | object | object | Parameters group for resources requests and limits |
| service | object | object | Parameters group for k8s service |
| service.http.port | int | `80` | k8s service http port |
| service.https.port | int | `443` | k8s service https port |
| service.internalRest.port | int | `53333` | k8s service internal rest port |
| service.name | string | `"cloudify-manager-aio"` | k8s service name |
| service.rabbitmq.port | int | `5671` | k8s service rabbitmq port |
| service.type | string | `"LoadBalancer"` | k8s service type. If you plan to use Ingress, you can use ClusterIP there. |
| startupProbe | object | object | Parameters group for pod startup probe |
| startupProbe.enabled | bool | `true` | Enable startup probe |
| startupProbe.failureThreshold | int | `30` | startup probe failure threshold |
| startupProbe.httpGet.path | string | `"/console"` | startup probe HTTP GET path |
| startupProbe.initialDelaySeconds | int | `30` | startup probe initial delay in seconds |
| startupProbe.periodSeconds | int | `10` | startup probe period in seconds |
| startupProbe.successThreshold | int | `1` | startup probe success threshold |
| startupProbe.timeoutSeconds | int | `5` | startup probe timeout in seconds |

### Image:

```yaml
image:
  repository: "cloudifyplatform/community-cloudify-manager-aio"
  tag: "6.4.2"
  pullPolicy: IfNotPresent
```

### Service:
* for more information and options see [the worker docs](../cloudify-manager-worker/README.md#option-2)

```yaml
service:
  type: LoadBalancer
  name: cloudify-manager-aio
  rabbitmq:
    port: 5671
  http:
    port: 80
  https:
    port: 443
  internalRest:
    port: 53333
```

### node selector - select on which nodes cloudify manager AIO may run:

```yaml
nodeSelector: {}
# nodeSelector:
#   nodeType: onDemand
```

### resources requests and limits:
```yaml
resources:
  requests:
    memory: 0.5Gi
    cpu: 0.5
```

### readiness probe may be enabled/disabled
```yaml
readinessProbe:
  enabled: true
  port: 80
  path: /console
  initialDelaySeconds: 10
```

