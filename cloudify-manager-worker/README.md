# Cloudify manager worker helm chart (Premium Version)

## Description
 
It's a helm chart for cloudify manager which is:

* Highly available, can be deployed with multiple replicas. ( available only when used EFS(NFS) Volume )
* Use persistent volume to survive restarts/failures.
* Use external DB (postgress), which may be deployed via public helm chart of Bitnami: https://github.com/bitnami/charts/tree/master/bitnami/postgresql
* Use external Message Brokes (rabbitMQ), which may be deployed via public helm chart of Bitnami: https://github.com/bitnami/charts/tree/master/bitnami

This is how the setup looks after it's deployed to 'cfy-example' namespace (it's possible to have multiple replicas (pods) of cloudify manager):

![cfy-manager](../images/cfy-example.png)


## How to create and deploy such a setup?

1. Generate certificate as a secret in k8s.

2. Deployment of DB (Postgres).

3. Deployment of Message Broker (rabbitMQ).

4. Deployment of Cloudify manager worker.

**You need to deploy DB and Message Broker before deploying Cloudify manager worker**


## Generate certificates and add as secret to k8s

**SSL certificate must be provided, to secure communications between cloudify manager and posrgress/rabbitmq**

* ca.crt (to sign other certificates)

* tls.key

* tls.crt

### Option 1: Create certificates using cloudify manager docker container

```bash
$ docker pull cloudifyplatform/community-cloudify-manager-aio:latest
$ docker run --name cfy_manager_local -d --restart unless-stopped --tmpfs /run --tmpfs /run/lock -p 8000:8000 cloudifyplatform/community-cloudify-manager-aio
$ docker exec -it created_ID bash

# NAMESPACE to which cloudify-manager deployed, must be changed accordingly
$ cfy_manager generate-test-cert -s 'cloudify-manager-worker.NAMESPACE.svc.cluster.local,rabbitmq.NAMESPACE.svc.cluster.local,postgres-postgresql.NAMESPACE.svc.cluster.local'
```

Create secret in k8s from certificates:

```bash
$ kubectl create secret generic cfy-certs --from-file=./tls.crt --from-file=./tls.key --from-file=./ca.crt
```


### Option 2: Use cert-manager component installed to kubernetes cluster

You need to deploy those manifests, which will generate cfy-certs secret eventually, you need to change NAMESPACE to your namespace before.
You can find this manifest in [external folder](https://github.com/cloudify-cosmo/cloudify-helm/tree/master/cloudify-manager-worker/external) - cert-issuer.yaml

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: cfy-ca
spec:
  secretName: cfy-ca-tls
  commonName: NAMESPACE.svc.cluster.local
  usages:
    - server auth
    - client auth
  isCA: true
  issuerRef:
    name: selfsigned-issuer
---
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: cfy-ca-issuer
spec:
  ca:
    secretName: cfy-ca-tls
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: cfy-cert
spec:
  secretName: cfy-certs
  isCA: false
  usages:
    - server auth
    - client auth
  dnsNames:
  - "postgres-postgresql.NAMESPACE.svc.cluster.local"
  - "rabbitmq.NAMESPACE.svc.cluster.local"
  - "cloudify-manager-worker.NAMESPACE.svc.cluster.local"
  - "postgres-postgresql"
  - "rabbitmq"
  - "cloudify-manager-worker"
  issuerRef:
    name: cfy-ca-issuer
```

## Create configmp with premium license

Create license.properties file - the example content:

 ``license:
   capabilities: null
   cloudify_version: null
   customer_id: INT-Internal-111111112
   expiration_date: 12/31/2022
   license_edition: Premium
   trial: false
 signature: !!binary |
   <LICENSE_KEY>``

Run create config map command
`kubectl create configmap cfy-licence --from-file=license.properties -n NAMESPACE`

## Install PostgreSQL(bitnami) to Kubernetes cluster with helm

You can find example of PostgreSQL values.yaml in [external/postgres-values.yaml](https://github.com/cloudify-cosmo/cloudify-helm/blob/master/cloudify-manager-worker/external/postgres-values.yaml)

Use certificate we created as k8s secret: 'cfy-certs'

```
volumePermissions.enabled=true
tls:
  enabled: true
  preferServerCiphers: true
  certificatesSecret: 'cfy-certs'
  certFilename: 'tls.crt'
  certKeyFilename: 'tls.key'
```

Install postgresql with postgres-values.yaml

```
helm install postgres bitnami/postgresql -f ./cloudify-manager-worker/external/postgres-values.yaml -n NAMESPACE
```

## Install RabbitMQ(bitnami) to Kubernetes cluster with helm


Use certificate we created as k8s secret: 'cfy-certs'

```
tls:
    enabled: true
    existingSecret: cfy-certs
    failIfNoPeerCert: false
    sslOptionsVerify: verify_peer
    caCertificate: |-    
    serverCertificate: |-
    serverKey: |-
```

Run management console on 15671 port with SSL (cloudify manager talks to management console via SSL):

add to rabbitmq-values.yaml

```
configuration: |-
  management.ssl.port       = 15671
  management.ssl.cacertfile = /opt/bitnami/rabbitmq/certs/ca_certificate.pem
  management.ssl.certfile   = /opt/bitnami/rabbitmq/certs/server_certificate.pem
  management.ssl.keyfile    = /opt/bitnami/rabbitmq/certs/server_key.pem

extraPorts:
  - name: manager-ssl
    port: 15671
    targetPort: 15671
```

Install rabbitmq with rabbitmq-values.yaml

```
helm install rabbitmq bitnami/rabbitmq -f ./cloudify-manager-worker/external/rabbitmq-values.yaml -n NAMESPACE
```

## Install cloudify manager worker

```
helm repo add cloudify-helm https://cloudify-cosmo.github.io/cloudify-helm

helm install cloudify-manager-worker cloudify-helm/cloudify-manager-worker -f ./cloudify-manager-worker/values.yaml -n NAMESPACE
```
## Version Compatibility

To deploy a cloudify manager version 6.3.1 and above - use the latest chart version (0.1.9 and above)

To deploy a cloudify manager version 6.3.0 and below - use chart version 0.1.8

## Upgrade cloudify manager worker

To upgrade cloudify manager use 'helm upgrade'.

For example to change to newer version (from 5.3.0 to 6.2.0 in this example), 

Change image version in values.yaml:

Before:
```yaml
image:
  repository: cloudifyplatform/premium-cloudify-manager-worker
  tag: 5.3.0
```

After:
```yaml
image:
  repository: cloudifyplatform/premium-cloudify-manager-worker
  tag: 6.2.0
```

Run 'helm upgrade'

```
helm upgrade cloudify-manager-worker cloudify-helm/cloudify-manager-worker -f ./cloudify-manager-worker/values.yaml -n NAMESPACE

```
If DB schema was changed in newer version, needed migration will be running first on DB, then application will be restarted during upgrade - be patient, because it may take a couple of minutes.

## Configuration options of cloudify-manager-worker values.yaml:

### Image:

```yaml
image:
  repository: "cloudifyplatform/premium-cloudify-manager-worker"
  tag: "5.3.0"
  pullPolicy: IfNotPresent
```

### DB - postgreSQL:

```yaml
db:
  host: postgres-postgresql
  cloudifyDBName: 'cloudify_db'
  cloudifyUsername: 'cloudify'
  cloudifyPassword: 'cloudify'
  serverDBName: 'postgres'
  serverUsername: 'postgres'
  serverPassword: 'cfy_test_pass'
```

### Message Broker - rabbitmq:

```yaml
queue:
  host: rabbitmq
  username: 'cfy_user'
  password: 'cfy_test_pass'
```

### Service:

```yaml
service:
  host: cloudify-manager-worker
  type: ClusterIP
  name: cloudify-manager-worker
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

### Secret name of certificate

```yaml
secret:
  name: cfy-certs
```

### resources requests and limits:

```yaml
resources:
  requests:
    memory: 0.5Gi
    cpu: 0.5
```

### Persistent volume size for EBS/EFS:

If using multiple replicas (High availability), EFS must be used

```yaml
volume:
  storageClass: 'efs'
  accessMode: 'ReadWriteMany'
  size: "3Gi"
```

If using one replicas, you can use EBS (gp2) for example, **gp2 is default**:

```yaml
volume:
  storageClass: 'gp2'
  accessMode: 'ReadWriteOnce'
  size: "3Gi"
```

### readiness probe may be enabled/disabled

```yaml
readinessProbe:
  enabled: true
  port: 80
  path: /console
  initialDelaySeconds: 10
```

### license - relevant in case you use premium cloudify manager,not community

You can add license as secret to k8s

```yaml
licence:
  secretName: cfy-licence
```
### Okta - relevant in case you want to connect okta-auth by SAML to cloudify manager

This handles most of the Okta configuration on the cloudify manager app.
You still need to create the app on Okta and create the user group on the manager - Detailed Okta <> Cloudify integration can be found here: https://docs.cloudify.co/latest/working_with/manager/okta_authentication/

The okta-license secret, containing the your Okta certificate should be applied

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: okta-license
data:
  okta_certificate.pem: |
    -----BEGIN CERTIFICATE-----
    <<certificate content>>
    -----END CERTIFICATE-----
```
Fill the values according to your okta app

```yaml
okta:
  secretName: okta-license
  enabled: true
  certPath: "/etc/cloudify/ssl/okta_certificate.pem"
  ssoUrl: "<okta_sso_url>"
  portalUrl: "<okta_portal_url>"
```

### Config

You can delay start of cfy manager / install all plugins / disable security (not recommended)...

```yaml
config:
  startDelay: 0
  # Multiple replicas works only with EFS(NFS) volume
  replicas: 1
  installPlugins: false
  cliLocalProfileHostName: localhost
  security:
    sslEnabled: false
    adminPassword: admin
  tlsCertPath: /mnt/cloudify-data/ssl/tls.crt
  tlsKeyPath: /mnt/cloudify-data/ssl/tls.key
  caCertPath: /mnt/cloudify-data/ssl/ca.crt
```

### Ingress

You may enable ingress-nginx and generate automatically cert if you have ingress-nginx / cert-manager installed.

```yaml
ingress:
  enabled: false
  host: cloudify-manager.app.cloudify.co
  annotations:
    kubernetes.io/ingress.class: nginx
    # cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    enabled: false
    secretName: cfy-secret-name
```
