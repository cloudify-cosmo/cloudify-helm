#!/usr/bin/env bash

set -euxo pipefail

if [ ! -f "values-override.yaml" ]; then
    echo "
imagePullSecrets:
  - name: regcred
" > values-override.yaml
fi
