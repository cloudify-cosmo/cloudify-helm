#!/usr/bin/env bash

helm uninstall rabbitmq
helm uninstall postgres
helm uninstall cloudify-manager-worker
sleep 10
kubectl delete pvc cloudify-data-cloudify-manager-worker-0
sleep 10
helm install rabbitmq bitnami/rabbitmq -f ./cloudify-manager-worker/external/rabbitmq-values.yaml
helm install postgres bitnami/postgresql -f ./cloudify-manager-worker/external/postgres-values.yaml
sleep 30
helm install cloudify-manager-worker ./cloudify-manager-worker -f cloudify-manager-worker/values.yaml

