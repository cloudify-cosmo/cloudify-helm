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

deploy:
	dev-cluster/default_values_override.sh
	helm install cloudify-services ./cloudify-services --values values-override.yaml
.PHONY: deploy
