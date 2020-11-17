# cloudify-helm
Cloudify Helm Charts

# cloudify manager AIO

## How to use?

git clone git@github.com:cloudify-cosmo/cloudify-helm.git

cd cloudify-helm

kubectl create ns cloudify-aio

helm install cloudify-manager-aio ./cloudify-manager-aio -n cloudify-aio

## Running AIO with custom values

helm install cloudify-manager-aio -f ./cloudify-manager-aio/values.yaml ./cloudify-manager-aio -n cloudify-aio

In values.yaml you can change: image.repository / service.type ...

```
image:
  repository: "cloudifyplatform/community-cloudify-manager-aio"
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP

```

## Development / testing / validation of AIO chart

helm install --dry-run cloudify-manager-aio ./cloudify-manager-aio

helm template ./cloudify-manager-aio

