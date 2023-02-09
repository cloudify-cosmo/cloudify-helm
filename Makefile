SHELL = /bin/bash
export DOCKER_TAG ?= latest

dev-cluster:
	kind create cluster --config "dev-cluster/kind-config.yaml"
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	# opt out of online validation, kind won't have access to the internet necessarily
	kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
.PHONY: dev-cluster

regcred:
	dev-cluster/aws_regcred.sh
.PHONY: regcred

load-images:
	kind load docker-image cloudify-manager-mgmtworker:$$DOCKER_TAG
	kind load docker-image cloudify-manager-rest_service:$$DOCKER_TAG
	kind load docker-image cloudify-manager-execution_scheduler:$$DOCKER_TAG
	kind load docker-image cloudify-manager-nginx:$$DOCKER_TAG
	kind load docker-image cloudify-manager-rabbitmq:$$DOCKER_TAG
	kind load docker-image stage_frontend:$$DOCKER_TAG
	kind load docker-image stage_backend:$$DOCKER_TAG
	kind load docker-image composer_frontend:$$DOCKER_TAG
	kind load docker-image composer_backend:$$DOCKER_TAG
	docker pull bitnami/minio-client:latest
	kind load docker-image bitnami/minio-client:latest
.PHONY: load-images

deploy:
	dev-cluster/default_values_override.sh
	helm install cloudify-services ./cloudify-services --values values-override.yaml
.PHONY: deploy
