# Deployment to GCP of Highly Available Cloudify manager worker (Premium Version)

## Provision GKE cluster

[Installing Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

```bash
gcloud container clusters create \
  --num-nodes 2 \
  --region europe-west1-b \
  gke-cluster

gcloud container clusters get-credentials gke-cluster
```

# Provision of Filestore (NFS supported) in GCP:

https://cloud.google.com/community/tutorials/gke-filestore-dynamic-provisioning

## Enable the required Google APIs

```bash
gcloud services enable file.googleapis.com
```

## Create a Filestore volume

### Create a Filestore instance with 1TB of storage capacity

```bash
## --project must be your PROJECT_ID
gcloud beta filestore instances create nfs-storage \
    --project=gke-demo-320314 \
    --zone=europe-west1-b \
    --tier=STANDARD \
    --file-share=name="nfsshare",capacity=1TB \
    --network=name=default
```

### Retrieve the IP address of the Filestore instance

```bash
FSADDR=$(gcloud beta filestore instances describe cfy-fs \
     --project=gke-demo-320314 \
     --zone=europe-west1-b \
     --format="value(networks.ipAddresses[0])")
```

## Deploy nfs provisioner
You need dynamic 'nfs client provisoner' to dynamically deploy new PV from nfs storage every time PV needed

```bash
helm install nfs-cp stable/nfs-client-provisioner --set nfs.server=$FSADDR --set nfs.path=/nfsshare
```

Validate that new 'storageclass' nfs-client available:

```bash
kubectl get storageclass
```


### Alternative is to create PV manually every time:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs
spec:
  capacity:
    storage: 1000Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: $FSADDR
    path: "/nfsshare"
  mountOptions:
    - vers=4
    - minorversion=1
    - sec=sys
```

## Deploy helm chart

### Create Namespace
```bash
kubectl create ns cfy-demo
```

### Create needed certificates and store as k8s secret
```bash
$ docker pull cloudifyplatform/community-cloudify-manager-aio:latest
$ docker run --name cfy_manager_local -d --restart unless-stopped --tmpfs /run --tmpfs /run/lock -p 8000:8000 cloudifyplatform/community-cloudify-manager-aio
$ docker exec -it created_ID bash

$ cfy_manager generate-test-cert -s 'cloudify-manager-worker.cfy-demo.svc.cluster.local,rabbitmq.cfy-demo.svc.cluster.local,postgres-postgresql.cfy-demo.svc.cluster.local'

## save certs in tls.crt|tls.key|ca.crt
$ kubectl create secret generic cfy-certs --from-file=./tls.crt --from-file=./tls.key --from-file=./ca.crt
```

### Values.yaml

```yaml
volume:
  storageClass: 'nfs-client'
  accessMode: 'ReadWriteMany'
  size: "15Gi"

service:
  host: cloudify-manager-worker
  type: LoadBalancer
  name: cloudify-manager-worker
  http:
    port: 80
  https:
    port: 443
  internalRest:
    port: 53333
secret:
  name: cfy-certs

config:
  replicas: 2
  startDelay: 20
  installPlugins: false
  cliLocalProfileHostName: localhost
  security:
    sslEnabled: false
    adminPassword: admin
  tlsCertPath: /mnt/cloudify-data/ssl/tls.crt
  tlsKeyPath: /mnt/cloudify-data/ssl/tls.key
  caCertPath: /mnt/cloudify-data/ssl/ca.crt

readinessProbe:
  enabled: true
  port: 80
  path: /console
  successThreshold: 3
  initialDelaySeconds: 10

ingress:
  enabled: false
  host: cfy-efs-app.eks.cloudify.co
  annotations:
    kubernetes.io/ingress.class: nginx
    # cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    enabled: false
    secretName: cfy-secret-name
```

We using external LoadBalancer, no Ingress Nginx / CertManager installed to cluster in this example.

**Very important to notice is when you use multiple replicas, 'readinessProbe' must be enabled and startDelay: 20**

### Deployment of helm chart

```bash
helm repo add cloudify-helm https://cloudify-cosmo.github.io/cloudify-helm

helm install cloudify-manager-worker cloudify-helm/cloudify-manager-worker -f values.yaml
```

You can find this values.yaml in /examples/gcp folder. 


