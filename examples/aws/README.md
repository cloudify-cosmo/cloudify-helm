# Deployment to AWS of Highly Available Cloudify manager worker (Premium Version)

## Provision EKS cluster

[Installing AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

```bash
$ eksctl create cluster \
  --region us-west-2 \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --name eks-cluster
```

# Provision of EFS (NFS supported) in AWS:

https://docs.aws.amazon.com/efs/latest/ug/creating-using-create-fs.html

```bash
$  aws efs create-file-system \
--creation-token efs-storage \
--backup true \
--encrypted true \
--performance-mode generalPurpose \
--throughput-mode bursting \
--region us-west-2 \
--tags Key=Name,Value="Test File System" \
--profile adminuser
```

### Deploy Amazon EFS CSI driver

Please deploy Amazon EFS CSI driver using official AWS documentation: https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html

### Create storage class

Example of manifest for "cm-efs" storage class, please replace **EFS_ID** to ID of the previously created AWS EFS file system:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: cm-efs
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: EFS_ID
  directoryPerms: "700"
  gid: "0"
  uid: "0"
  basePath: "/dynamic_provisioning"
```

The same manifest can be found there: [efs/storageclass.yaml](efs/storageclass.yaml)

Apply the manifest:

```bash
kubectl apply -f efs/storageclass.yaml
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
  storageClass: "cm-efs"
  accessMode: "ReadWriteMany"
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

You can find this values.yaml in /examples/aws folder.
