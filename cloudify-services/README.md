[//]: # "-*- markdown -*-"

# Cloudify services helm chart

## Description

Helm chart deploying the cloudify-services stack, including the following services:

- api-service
- composer-backend
- composer-frontend
- execution-scheduler
- fileserver
- mgmtworker
- nginx
- postgresql
- prometheus
- rabbitmq
- rest-service
- stage-backend
- stage-frontend

## Prerequisites

- Helm installed >=3.7 (https://helm.sh/docs/intro/install/).
- AWS CLI tool installed (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- Running Kubernetes cluster.
- Sufficient resources on Kubernetes worker nodes.
- Access to ECR registry with helm chart package.
- Cloudify Services valid license.

## How to create and deploy such a setup?

1. [Deployment of Cloudify services](#install-cloudify-services-worker)

2. [(Optional) Ensure UI access to the manager upon installation](#optional-ensure-ui-access-upon-installation)

3. [(Optional) Extra configuration options](#configuration-options-of-cloudify-services-valuesyaml)

4. [Uninstallation of helm charts](#uninstallation)

## (optional) Clone cloudify-helm repo

This step isn't necessary but can be useful if you want to get default values.yaml file for customize it.

- In case you don't have Git installed - https://github.com/git-guides/install-git

```bash
$ git clone https://github.com/cloudify-cosmo/cloudify-helm.git && cd cloudify-helm
```

## Install cloudify services

### Authenticate in the ECR registry

You need to have installed AWS CLI tool and have access to "cloudify-automation" AWS account (AWS account ID: 163877087245).
Then you need to execute following for get ECR temporary credentials and authenticate helm in it:

```bash
$ aws --profile cloudify-automation ecr get-login-password --region eu-west-1 | helm registry login --username AWS --password-stdin 163877087245.dkr.ecr.eu-west-1.amazonaws.com
```

### (optional) Ensure UI access upon installation

You can use k8s ingress for expose UI outside the k8s cluster. Make sure you have one of the ingress controllers installed and confiogured inside your k8s cluster.

Example of the "ingress" configuration section in the values.yaml file:

```YAML
ingress:
  enabled: true
  host: cloudify-services.example.com
  ingressClassName: alb
  annotations:
    alb.ingress.kubernetes.io/target-type: "ip"
    alb.ingress.kubernetes.io/scheme: "internal"
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
```

In this example we using "alb" ingress class (provided by "AWS Load Balancer Controller), which creates private Application Load Balancer, listening on port 80/HTTP and forwarding all the traffic for host "cloudify-services.example.com" to cloudify-services stack.

### After values are verified, install the manager worker chart

```bash
$ helm install cloudify-services oci://163877087245.dkr.ecr.eu-west-1.amazonaws.com/cloudify-services-helm --version 0.1.0 -f VALUES_FILE -n NAMESPACE
```

## Using IPv6

When deploying on an IPv6-only cluster, additional settings must be applied to make RabbitMQ compatible. See `values-ipv6.yaml` for the changed parameters, or use this values file directly when installing the chart.

Remember that when using an IPv6 cluster, the ingress controller must support IPv6 as well.

## Scaling

There's several components you might want to scale up:

- RabbitMQ: the RabbitMQ chart provides out-of-the-box clustering, and the amount of replicas can be controlled via the `rabbitmq.replicaCount` setting.
- PostgreSQL: the PostgreSQL chart allows primary/replica replication (active/passive replication scheme with read replicas). To enable it, set `postgresql.architecture` to `replication`. When doing so, point the DB clients at the DB primary by setting `db.host` to `postgresql-primary` (read replicas are unused by Cloudify).
- Management worker: set `mgmtworker.replicas` to a number higher than 1, to start multiple mgmtworker instances, allowing better operation concurrency.

For an example of a scaled-up deployment, see the `scaled-up-values.yaml` example values file.

## Uninstallation

Uninstall helm release:

```bash
$ helm uninstall cloudify-services -n NAMESPACE
```

## Configuration options of cloudify-services values.yaml

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api_service.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-apiservice:7.0.3-dev1"` |  |
| api_service.imagePullPolicy | string | `"IfNotPresent"` |  |
| api_service.port | int | `8101` |  |
| api_service.probes.liveness.enabled | bool | `true` |  |
| api_service.probes.liveness.failureThreshold | int | `3` |  |
| api_service.probes.liveness.initialDelaySeconds | int | `20` |  |
| api_service.probes.liveness.periodSeconds | int | `20` |  |
| api_service.probes.liveness.successThreshold | int | `1` |  |
| api_service.probes.liveness.timeoutSeconds | int | `10` |  |
| api_service.replicas | int | `1` |  |
| certs.ca_cert | string | `""` |  |
| certs.ca_key | string | `""` |  |
| certs.external_cert | string | `""` |  |
| certs.external_key | string | `""` |  |
| certs.internal_cert | string | `""` |  |
| certs.internal_key | string | `""` |  |
| certs.rabbitmq_cert | string | `""` |  |
| certs.rabbitmq_key | string | `""` |  |
| composer_backend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-composer-backend:7.0.3-dev1"` |  |
| composer_backend.imagePullPolicy | string | `"IfNotPresent"` |  |
| composer_backend.port | int | `3000` |  |
| composer_backend.probes.liveness.enabled | bool | `false` |  |
| composer_backend.probes.liveness.failureThreshold | int | `3` |  |
| composer_backend.probes.liveness.initialDelaySeconds | int | `20` |  |
| composer_backend.probes.liveness.periodSeconds | int | `20` |  |
| composer_backend.probes.liveness.successThreshold | int | `1` |  |
| composer_backend.probes.liveness.timeoutSeconds | int | `10` |  |
| composer_backend.replicas | int | `1` |  |
| composer_backend.securityContext.runAsNonRoot | bool | `true` |  |
| composer_frontend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-composer-frontend:7.0.3-dev1"` |  |
| composer_frontend.imagePullPolicy | string | `"IfNotPresent"` |  |
| composer_frontend.port | int | `8188` |  |
| composer_frontend.probes.liveness.enabled | bool | `true` |  |
| composer_frontend.probes.liveness.failureThreshold | int | `3` |  |
| composer_frontend.probes.liveness.initialDelaySeconds | int | `20` |  |
| composer_frontend.probes.liveness.periodSeconds | int | `20` |  |
| composer_frontend.probes.liveness.successThreshold | int | `1` |  |
| composer_frontend.probes.liveness.timeoutSeconds | int | `10` |  |
| composer_frontend.replicas | int | `1` |  |
| composer_frontend.securityContext.runAsNonRoot | bool | `true` |  |
| db.dbName | string | `"cloudify_db"` |  |
| db.host | string | `"postgresql"` |  |
| db.k8sSecret.key | string | `"password"` |  |
| db.k8sSecret.name | string | `"cloudify-db-creds"` |  |
| db.password | string | `"cloudify"` |  |
| db.user | string | `"cloudify"` |  |
| execution_scheduler.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-execution-scheduler:7.0.3-dev1"` |  |
| execution_scheduler.imagePullPolicy | string | `"IfNotPresent"` |  |
| execution_scheduler.replicas | int | `1` |  |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"50m"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.host | string | `nil` |  |
| ingress.tls.enabled | bool | `false` |  |
| ingress.tls.secretName | string | `"cfy-secret-name"` |  |
| kube-state-metrics | object | object | Parameters group for bitnami/kube-state-metrics helm chart. Details: https://github.com/bitnami/charts/tree/main/bitnami/kube-state-metrics/README.md |
| mgmtworker.access.local_cluster | bool | `true` |  |
| mgmtworker.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-mgmtworker:7.0.3-dev1"` |  |
| mgmtworker.imagePullPolicy | string | `"IfNotPresent"` |  |
| mgmtworker.replicas | int | `1` |  |
| nameOverride | string | `""` |  |
| nginx.http_port | int | `80` |  |
| nginx.https_port | int | `443` |  |
| nginx.image | string | `"docker.io/library/nginx"` |  |
| nginx.imagePullPolicy | string | `"IfNotPresent"` |  |
| nginx.internal_port | int | `53333` |  |
| nginx.probes.liveness.enabled | bool | `true` |  |
| nginx.probes.liveness.failureThreshold | int | `3` |  |
| nginx.probes.liveness.initialDelaySeconds | int | `20` |  |
| nginx.probes.liveness.periodSeconds | int | `20` |  |
| nginx.probes.liveness.successThreshold | int | `1` |  |
| nginx.probes.liveness.timeoutSeconds | int | `10` |  |
| nginx.rate_limit.burst | int | `30` |  |
| nginx.rate_limit.delay | int | `20` |  |
| nginx.rate_limit.enabled | bool | `true` |  |
| nginx.rate_limit.rate | string | `"10r/s"` |  |
| nginx.replicas | int | `1` |  |
| postgresql.auth.database | string | `"cloudify_db"` |  |
| postgresql.auth.password | string | `"cloudify"` |  |
| postgresql.auth.username | string | `"cloudify"` |  |
| postgresql.containerPorts.postgresql | int | `5432` |  |
| postgresql.enableNetworkPolicy | bool | `true` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.fullnameOverride | string | `"postgresql"` |  |
| postgresql.image.pullPolicy | string | `"IfNotPresent"` |  |
| postgresql.image.tag | string | `"15.3.0-debian-11-r17"` |  |
| postgresql.metrics.enabled | bool | `true` |  |
| postgresql.podLabels | object | `{}` |  |
| postgresql.primary.resources.limits.cpu | int | `2` |  |
| postgresql.primary.resources.limits.memory | string | `"2Gi"` |  |
| postgresql.primary.resources.requests.cpu | float | `0.5` |  |
| postgresql.primary.resources.requests.memory | string | `"256Mi"` |  |
| prometheus | object | object | Parameters group for bitnami/prometheus helm chart. Details: https://github.com/bitnami/charts/blob/main/bitnami/prometheus/README.md |
| rabbitmq.advancedConfiguration | string | `"[\n  {rabbit, [\n    {consumer_timeout, undefined}\n  ]}\n]."` |  |
| rabbitmq.auth.erlangCookie | string | `"cloudify-erlang-cookie"` |  |
| rabbitmq.auth.password | string | `"c10udify"` |  |
| rabbitmq.auth.tls.enabled | bool | `true` |  |
| rabbitmq.auth.tls.existingSecret | string | `"rabbitmq-ssl-certs"` |  |
| rabbitmq.auth.tls.failIfNoPeerCert | bool | `false` |  |
| rabbitmq.auth.username | string | `"cloudify"` |  |
| rabbitmq.enableNetworkPolicy | bool | `true` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.extraConfiguration | string | `"management.ssl.port       = 15671\nmanagement.ssl.cacertfile = /opt/bitnami/rabbitmq/certs/ca_certificate.pem\nmanagement.ssl.certfile   = /opt/bitnami/rabbitmq/certs/server_certificate.pem\nmanagement.ssl.keyfile    = /opt/bitnami/rabbitmq/certs/server_key.pem"` |  |
| rabbitmq.extraSecrets.rabbitmq-load-definition."load_definition.json" | string | `"{\n    \"vhosts\": [\n        {\n            \"name\": \"/\"\n        }\n    ],\n    \"users\": [\n        {\n            \"hashing_algorithm\": \"rabbit_password_hashing_sha256\",\n            \"name\": \"{{ .Values.auth.username }}\",\n            \"password\": \"{{ .Values.auth.password }}\",\n            \"tags\": \"administrator\"\n        }\n    ],\n    \"permissions\": [\n        {\n            \"user\": \"{{ .Values.auth.username }}\",\n            \"vhost\": \"/\",\n            \"configure\": \".*\",\n            \"write\": \".*\",\n            \"read\": \".*\"\n        }\n    ],\n    \"policies\": [\n        {\n            \"name\": \"logs_queue_message_policy\",\n            \"vhost\": \"/\",\n            \"pattern\": \"^cloudify-log$\",\n            \"priority\": 100,\n            \"apply-to\": \"queues\",\n            \"definition\": {\n                \"message-ttl\": 1200000,\n                \"max-length\": 1000000,\n                \"ha-mode\": \"all\",\n                \"ha-sync-mode\": \"automatic\",\n                \"ha-sync-batch-size\": 50\n            }\n        },\n        {\n            \"name\": \"events_queue_message_policy\",\n            \"vhost\": \"/\",\n            \"pattern\": \"^cloudify-events$\",\n            \"priority\": 100,\n            \"apply-to\": \"queues\",\n            \"definition\": {\n                \"message-ttl\": 1200000,\n                \"max-length\": 1000000,\n                \"ha-mode\": \"all\",\n                \"ha-sync-mode\": \"automatic\",\n                \"ha-sync-batch-size\": 50\n            }\n        },\n        {\n            \"name\": \"default_policy\",\n            \"vhost\": \"/\",\n            \"pattern\": \"^\",\n            \"priority\": 1,\n            \"apply-to\": \"queues\",\n            \"definition\": {\n                \"ha-mode\": \"all\",\n                \"ha-sync-mode\": \"automatic\",\n                \"ha-sync-batch-size\": 50\n            }\n        }\n    ],\n    \"queues\": [\n        {\n            \"arguments\": {},\n            \"auto_delete\": false,\n            \"durable\": true,\n            \"name\": \"cloudify.management_operation\",\n            \"type\": \"classic\",\n            \"vhost\": \"/\"\n        },\n        {\n            \"arguments\": {},\n            \"auto_delete\": false,\n            \"durable\": true,\n            \"name\": \"cloudify.management_workflow\",\n            \"type\": \"classic\",\n            \"vhost\": \"/\"\n        }\n    ],\n    \"bindings\": [\n        {\n            \"arguments\": {},\n            \"destination\": \"cloudify.management_operation\",\n            \"destination_type\": \"queue\",\n            \"routing_key\": \"operation\",\n            \"source\": \"cloudify.management\",\n            \"vhost\": \"/\"\n        },\n        {\n            \"arguments\": {},\n            \"destination\": \"cloudify.management_workflow\",\n            \"destination_type\": \"queue\",\n            \"routing_key\": \"workflow\",\n            \"source\": \"cloudify.management\",\n            \"vhost\": \"/\"\n        }\n    ],\n    \"exchanges\": [\n        {\n            \"arguments\": {},\n            \"auto_delete\": false,\n            \"durable\": true,\n            \"name\": \"cloudify.management\",\n            \"type\": \"direct\",\n            \"vhost\": \"/\"\n        }\n    ]\n}\n"` |  |
| rabbitmq.fullnameOverride | string | `"rabbitmq"` |  |
| rabbitmq.image.pullPolicy | string | `"IfNotPresent"` |  |
| rabbitmq.image.tag | string | `"3.12.2-debian-11-r8"` |  |
| rabbitmq.loadDefinition.enabled | bool | `true` |  |
| rabbitmq.loadDefinition.existingSecret | string | `"rabbitmq-load-definition"` |  |
| rabbitmq.metrics.enabled | bool | `true` |  |
| rabbitmq.plugins | string | `"rabbitmq_management rabbitmq_prometheus rabbitmq_tracing rabbitmq_peer_discovery_k8s"` |  |
| rabbitmq.podLabels | object | `{}` |  |
| rabbitmq.resources.limits.cpu | int | `4` |  |
| rabbitmq.resources.limits.memory | string | `"1Gi"` |  |
| rabbitmq.resources.requests.cpu | float | `0.5` |  |
| rabbitmq.resources.requests.memory | string | `"512Mi"` |  |
| rabbitmq.service.extraPorts[0].name | string | `"manager-ssl"` |  |
| rabbitmq.service.extraPorts[0].port | int | `15671` |  |
| rabbitmq.service.extraPorts[0].targetPort | int | `15671` |  |
| rabbitmq.service.ports.metrics | int | `15692` |  |
| resources.packages.agents."cloudify-windows-agent.exe" | string | `"https://cloudify-release-eu.s3.amazonaws.com/cloudify/7.0.0/ga-release/cloudify-windows-agent_7.0.0-ga.exe"` |  |
| resources.packages.agents."manylinux-aarch64-agent.tar.gz" | string | `"https://cloudify-release-eu.s3.amazonaws.com/cloudify/7.0.0/ga-release/manylinux-aarch64-agent_7.0.0-ga.tar.gz"` |  |
| resources.packages.agents."manylinux-x86_64-agent.tar.gz" | string | `"https://cloudify-release-eu.s3.amazonaws.com/cloudify/7.0.0/ga-release/manylinux-x86_64-agent_7.0.0-ga.tar.gz"` |  |
| rest_service.config.manager.file_server_type | string | `"s3"` |  |
| rest_service.config.manager.hostname | string | `"cloudify-manager"` |  |
| rest_service.config.manager.private_ip | string | `"localhost"` |  |
| rest_service.config.manager.prometheus_url | string | `"http://prometheus-server:9090"` |  |
| rest_service.config.manager.public_ip | string | `"localhost"` |  |
| rest_service.config.manager.s3_resources_bucket | string | `"resources"` |  |
| rest_service.config.manager.s3_server_url | string | `""` | s3_server_url is the address of the s3 endpoint. Ignored and auto-generated when using builtin seaweedfs |
| rest_service.configPath | string | `"/tmp/config.yaml"` |  |
| rest_service.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-restservice:7.0.3-dev1"` |  |
| rest_service.imagePullPolicy | string | `"IfNotPresent"` |  |
| rest_service.port | int | `8100` |  |
| rest_service.probes.liveness.enabled | bool | `false` |  |
| rest_service.probes.liveness.failureThreshold | int | `3` |  |
| rest_service.probes.liveness.initialDelaySeconds | int | `20` |  |
| rest_service.probes.liveness.periodSeconds | int | `20` |  |
| rest_service.probes.liveness.successThreshold | int | `1` |  |
| rest_service.probes.liveness.timeoutSeconds | int | `10` |  |
| rest_service.replicas | int | `1` |  |
| rest_service.s3.credentials_secret_name | string | `"seaweedfs-s3-secret"` |  |
| rest_service.s3.session_token_secret_name | string | `""` |  |
| seaweedfs | object | object | Parameters group for seaweed helm chart. Details: https://github.com/seaweedfs/seaweedfs/tree/master/k8s/charts/seaweedfs |
| seaweedfs.clientImage | string | object | Parameters group for awscli containers (using as init containers) |
| service.http.port | int | `80` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| stage_backend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-stage-backend:7.0.3-dev1"` |  |
| stage_backend.imagePullPolicy | string | `"IfNotPresent"` |  |
| stage_backend.port | int | `8088` |  |
| stage_backend.probes.liveness.enabled | bool | `true` |  |
| stage_backend.probes.liveness.failureThreshold | int | `3` |  |
| stage_backend.probes.liveness.initialDelaySeconds | int | `20` |  |
| stage_backend.probes.liveness.periodSeconds | int | `20` |  |
| stage_backend.probes.liveness.successThreshold | int | `1` |  |
| stage_backend.probes.liveness.timeoutSeconds | int | `10` |  |
| stage_backend.replicas | int | `1` |  |
| stage_backend.securityContext.runAsNonRoot | bool | `true` |  |
| stage_frontend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-stage-frontend:7.0.3-dev1"` |  |
| stage_frontend.imagePullPolicy | string | `"IfNotPresent"` |  |
| stage_frontend.port | int | `8188` |  |
| stage_frontend.probes.liveness.enabled | bool | `true` |  |
| stage_frontend.probes.liveness.failureThreshold | int | `3` |  |
| stage_frontend.probes.liveness.initialDelaySeconds | int | `20` |  |
| stage_frontend.probes.liveness.periodSeconds | int | `20` |  |
| stage_frontend.probes.liveness.successThreshold | int | `1` |  |
| stage_frontend.probes.liveness.timeoutSeconds | int | `10` |  |
| stage_frontend.replicas | int | `1` |  |
| stage_frontend.securityContext.runAsNonRoot | bool | `true` |  |