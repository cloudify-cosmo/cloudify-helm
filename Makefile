SHELL = /bin/bash
export DOCKER_TAG ?= latest

load-images:
	kind load docker-image cloudify-manager-mgmtworker:$$DOCKER_TAG
	kind load docker-image cloudify-manager-certs_creator:$$DOCKER_TAG
	kind load docker-image cloudify-manager-rest_service:$$DOCKER_TAG
	kind load docker-image cloudify-manager-execution_scheduler:$$DOCKER_TAG
	kind load docker-image cloudify-manager-nginx:$$DOCKER_TAG
	kind load docker-image cloudify-manager-rabbitmq:$$DOCKER_TAG
	kind load docker-image cloudify-manager-postgresql:$$DOCKER_TAG
	kind load docker-image cloudify-manager-fileserver:$$DOCKER_TAG
	kind load docker-image cloudify-manager-config:$$DOCKER_TAG
	kind load docker-image stage_frontend:$$DOCKER_TAG
	kind load docker-image stage_backend:$$DOCKER_TAG
	kind load docker-image composer_frontend:$$DOCKER_TAG
	kind load docker-image composer_backend:$$DOCKER_TAG
.PHONY: load-images

deploy: load-images
	touch values-override.yaml
	helm install cloudify-services ./cloudify-services --values values-override.yaml
.PHONY: deploy
