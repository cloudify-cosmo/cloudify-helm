# Cloudify manager AIO helm chart

## Description

To understand how to install and configure AIO cloudify manager please read [Cloudify AIO Helm chart](/cloudify-manager-aio/README.txt)


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