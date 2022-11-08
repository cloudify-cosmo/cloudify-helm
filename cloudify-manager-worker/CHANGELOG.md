# Changelog

All notable changes start from v0.4.0 of this helm chart will be documented in this file.

Provides a release information for each version splitted by the next sections

- **Added** - for new added features
- **Fixed** - for fixed issues
- **Changed** - for changes in already implemented
- **Removed** - for now removed features

</br>

# [v0.4.0] - 2022-11-08

## Changed

- Helm charts **bitnami/rabbitmq** and **bitnami/postgresql** now dependent charts and may be deployed automatically, so isn't necessary to deploy them manually. For new installation we suggest to add parameters **rabbitmq.deploy: true** and **postgresql.deploy: true** for enable deploy rabbitmq and postgresql as dependencies. We left defaults for these parameters to **false** for backward compatibility (will be changed later).
- "cloudify-manager-worker/README.md" file updated.
- PostgreSQL will create PV by default (when postgres deploy enabled in parameter **postgresql.deploy: true**).

## Added

- Added "cloudify-manager-worker/CHANGELOG.md" file.

## Fixed

- cert-issuer default duration for new certs was 90 days - defaulted to 10y.

## Removed

- Removed file "cloudify-manager-worker/external/postgres-values.yaml" - values file for manual install postgres from bitnami/postgres helm chart.
- Removed file "cloudify-manager-worker/external/rabbitmq-values.yaml" - values file for manual install rabbitmq from bitnami/rabbitmq helm chart.
