#!/usr/bin/env bash

set -euo pipefail

kubectl create secret docker-registry regcred \
  --docker-server=263721492972.dkr.ecr.eu-west-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region eu-west-1)
