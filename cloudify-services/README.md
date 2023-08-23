[//]: # "-*- markdown -*-"

# Cloudify services helm chart

## Description

It's a helm chart for deploy cloudify-services stack, including following microservices:

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

## Configuration options of cloudify-services values.yaml

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api_service.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-apiservice:latest-x86_64"` |  |
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
| composer_backend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-composer-backend:latest-x86_64"` |  |
| composer_backend.imagePullPolicy | string | `"IfNotPresent"` |  |
| composer_backend.port | int | `3000` |  |
| composer_backend.probes.liveness.enabled | bool | `false` |  |
| composer_backend.probes.liveness.failureThreshold | int | `3` |  |
| composer_backend.probes.liveness.initialDelaySeconds | int | `20` |  |
| composer_backend.probes.liveness.periodSeconds | int | `20` |  |
| composer_backend.probes.liveness.successThreshold | int | `1` |  |
| composer_backend.probes.liveness.timeoutSeconds | int | `10` |  |
| composer_backend.replicas | int | `1` |  |
| composer_frontend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-composer-frontend:latest-x86_64"` |  |
| composer_frontend.imagePullPolicy | string | `"IfNotPresent"` |  |
| composer_frontend.port | int | `8188` |  |
| composer_frontend.probes.liveness.enabled | bool | `true` |  |
| composer_frontend.probes.liveness.failureThreshold | int | `3` |  |
| composer_frontend.probes.liveness.initialDelaySeconds | int | `20` |  |
| composer_frontend.probes.liveness.periodSeconds | int | `20` |  |
| composer_frontend.probes.liveness.successThreshold | int | `1` |  |
| composer_frontend.probes.liveness.timeoutSeconds | int | `10` |  |
| composer_frontend.replicas | int | `1` |  |
| execution_scheduler.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-execution-scheduler:latest-x86_64"` |  |
| execution_scheduler.imagePullPolicy | string | `"IfNotPresent"` |  |
| execution_scheduler.replicas | int | `1` |  |
| fileserver.access_key | string | `"admin"` |  |
| fileserver.api_port | int | `9000` |  |
| fileserver.client_image | string | `"docker.io/bitnami/minio-client:2023.4.12"` |  |
| fileserver.console_port | int | `9090` |  |
| fileserver.image | string | `"docker.io/minio/minio"` |  |
| fileserver.imagePullPolicy | string | `"IfNotPresent"` |  |
| fileserver.install | string | `"yes"` |  |
| fileserver.probes.liveness.enabled | bool | `true` |  |
| fileserver.probes.liveness.failureThreshold | int | `3` |  |
| fileserver.probes.liveness.initialDelaySeconds | int | `20` |  |
| fileserver.probes.liveness.periodSeconds | int | `20` |  |
| fileserver.probes.liveness.successThreshold | int | `1` |  |
| fileserver.probes.liveness.timeoutSeconds | int | `10` |  |
| fileserver.probes.readiness.enabled | bool | `true` |  |
| fileserver.probes.readiness.failureThreshold | int | `3` |  |
| fileserver.probes.readiness.initialDelaySeconds | int | `10` |  |
| fileserver.probes.readiness.periodSeconds | int | `10` |  |
| fileserver.probes.readiness.successThreshold | int | `1` |  |
| fileserver.probes.readiness.timeoutSeconds | int | `5` |  |
| fileserver.replicas | int | `1` |  |
| fileserver.secret_key | string | `"admin123"` |  |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"50m"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.host | string | `nil` |  |
| ingress.tls.enabled | bool | `false` |  |
| ingress.tls.secretName | string | `"cfy-secret-name"` |  |
| mgmtworker.access.local_cluster | bool | `true` |  |
| mgmtworker.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-mgmtworker:latest-x86_64"` |  |
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
| postgresql.image | string | `"docker.io/library/postgres"` |  |
| postgresql.imagePullPolicy | string | `"IfNotPresent"` |  |
| postgresql.port | int | `5432` |  |
| postgresql.postgres_db | string | `"cloudify_db"` |  |
| postgresql.postgres_password | string | `"cloudify"` |  |
| postgresql.postgres_user | string | `"cloudify"` |  |
| postgresql.probes.readiness.enabled | bool | `true` |  |
| postgresql.probes.readiness.failureThreshold | int | `3` |  |
| postgresql.probes.readiness.initialDelaySeconds | int | `10` |  |
| postgresql.probes.readiness.periodSeconds | int | `10` |  |
| postgresql.probes.readiness.successThreshold | int | `1` |  |
| postgresql.probes.readiness.timeoutSeconds | int | `5` |  |
| postgresql.replicas | int | `1` |  |
| prometheus.api_port | int | `9090` |  |
| prometheus.image | string | `"prom/prometheus"` |  |
| prometheus.imagePullPolicy | string | `"IfNotPresent"` |  |
| prometheus.replicas | int | `1` |  |
| rabbitmq.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-rabbitmq:latest-x86_64"` |  |
| rabbitmq.imagePullPolicy | string | `"IfNotPresent"` |  |
| rabbitmq.management_port | int | `15671` |  |
| rabbitmq.metrics_port | int | `15692` |  |
| rabbitmq.probes.liveness.enabled | bool | `true` |  |
| rabbitmq.probes.liveness.failureThreshold | int | `3` |  |
| rabbitmq.probes.liveness.initialDelaySeconds | int | `20` |  |
| rabbitmq.probes.liveness.periodSeconds | int | `30` |  |
| rabbitmq.probes.liveness.successThreshold | int | `1` |  |
| rabbitmq.probes.liveness.timeoutSeconds | int | `15` |  |
| rabbitmq.probes.readiness.enabled | bool | `true` |  |
| rabbitmq.probes.readiness.failureThreshold | int | `3` |  |
| rabbitmq.probes.readiness.initialDelaySeconds | int | `10` |  |
| rabbitmq.probes.readiness.periodSeconds | int | `10` |  |
| rabbitmq.probes.readiness.successThreshold | int | `1` |  |
| rabbitmq.probes.readiness.timeoutSeconds | int | `5` |  |
| rabbitmq.replicas | int | `1` |  |
| rabbitmq.ssl_port | int | `5671` |  |
| resources.packages.agents."cloudify-windows-agent.exe" | string | `"https://cloudify-release-eu.s3.amazonaws.com/cloudify/7.0.0/ga-release/cloudify-windows-agent_7.0.0-ga.exe"` |  |
| resources.packages.agents."manylinux-aarch64-agent.tar.gz" | string | `"https://cloudify-release-eu.s3.amazonaws.com/cloudify/7.0.0/ga-release/manylinux-aarch64-agent_7.0.0-ga.tar.gz"` |  |
| resources.packages.agents."manylinux-x86_64-agent.tar.gz" | string | `"https://cloudify-release-eu.s3.amazonaws.com/cloudify/7.0.0/ga-release/manylinux-x86_64-agent_7.0.0-ga.tar.gz"` |  |
| rest_service.config.manager.file_server_type | string | `"s3"` |  |
| rest_service.config.manager.hostname | string | `"cloudify-manager"` |  |
| rest_service.config.manager.private_ip | string | `"localhost"` |  |
| rest_service.config.manager.prometheus_url | string | `"http://prometheus:9090"` |  |
| rest_service.config.manager.public_ip | string | `"localhost"` |  |
| rest_service.configPath | string | `"/tmp/config.yaml"` |  |
| rest_service.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-restservice:latest-x86_64"` |  |
| rest_service.imagePullPolicy | string | `"IfNotPresent"` |  |
| rest_service.port | int | `8100` |  |
| rest_service.probes.liveness.enabled | bool | `false` |  |
| rest_service.probes.liveness.failureThreshold | int | `3` |  |
| rest_service.probes.liveness.initialDelaySeconds | int | `20` |  |
| rest_service.probes.liveness.periodSeconds | int | `20` |  |
| rest_service.probes.liveness.successThreshold | int | `1` |  |
| rest_service.probes.liveness.timeoutSeconds | int | `10` |  |
| rest_service.replicas | int | `1` |  |
| service.http.port | int | `80` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| stage_backend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-stage-backend:latest-x86_64"` |  |
| stage_backend.imagePullPolicy | string | `"IfNotPresent"` |  |
| stage_backend.port | int | `8088` |  |
| stage_backend.probes.liveness.enabled | bool | `true` |  |
| stage_backend.probes.liveness.failureThreshold | int | `3` |  |
| stage_backend.probes.liveness.initialDelaySeconds | int | `20` |  |
| stage_backend.probes.liveness.periodSeconds | int | `20` |  |
| stage_backend.probes.liveness.successThreshold | int | `1` |  |
| stage_backend.probes.liveness.timeoutSeconds | int | `10` |  |
| stage_backend.replicas | int | `1` |  |
| stage_frontend.image | string | `"263721492972.dkr.ecr.eu-west-1.amazonaws.com/cloudify-manager-stage-frontend:latest-x86_64"` |  |
| stage_frontend.imagePullPolicy | string | `"IfNotPresent"` |  |
| stage_frontend.port | int | `8188` |  |
| stage_frontend.probes.liveness.enabled | bool | `true` |  |
| stage_frontend.probes.liveness.failureThreshold | int | `3` |  |
| stage_frontend.probes.liveness.initialDelaySeconds | int | `20` |  |
| stage_frontend.probes.liveness.periodSeconds | int | `20` |  |
| stage_frontend.probes.liveness.successThreshold | int | `1` |  |
| stage_frontend.probes.liveness.timeoutSeconds | int | `10` |  |
| stage_frontend.replicas | int | `1` |  |

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

### (optional) Use a S3 bucket as the fileserver

By default, Cloudify installs a SeaweedFS instance as its fileserver. In order to use a pre-existing S3 bucket instead, follow these steps:

1. Set `seaweedfs.enabled` fo false
1. Set `rest_service.config.manager.s3_server_url` to the empty string
1. Set `rest_service.config.manager.s3_resources_bucket` to the name of your S3 bucket (just the name, not the ARN, not the URL)
1. Create a secret containing your S3 credentials. The keys in the secret must be the same as the keys used by SeaweedFS, even though no admin access is required:
  - `admin_access_key_id` contaning the access key ID
  - `admin_secret_access_key` contaning the access key secret
1. Set `rest_service.s3.credentials_secret_name` to the name of the above secret (you can use the default name of `seaweedfs-s3-secret` even when not using SeaweedFS)
1. If a session token is necessary, create a secret containing it under the key `session_token`, and set `rest_service.s3.session_token_secret_name` to the name of that secret
1. If using agents, pre-upload the agent packages to the bucket: fetch the URLs from `resources.packages.agents`, and put them under the `packages/` subdirectory in the bucket.

For easy creation of that secret in local development, you can use the template in `dev-cluster/s3-secrets-template.yaml`

### After values are verified, install the manager worker chart

```bash
$ helm install cloudify-services oci://163877087245.dkr.ecr.eu-west-1.amazonaws.com/cloudify-services-helm --version 0.1.0 -f VALUES_FILE -n NAMESPACE
```

## Uninstallation

Uninstall helm release:

```bash
$ helm uninstall cloudify-services -n NAMESPACE
```
