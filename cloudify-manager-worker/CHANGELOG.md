# Changelog

All notable changes start from v0.4.0 of this helm chart will be documented in this file.

Provides a release information for each version splitted by the next sections

- **Added** - for new added features
- **Fixed** - for fixed issues
- **Changed** - for changes in already implemented
- **Removed** - for now removed features
- **Upgrade notes** - instruction about upgrage from previous helm chart version

</br>
# [v0.4.5]

## Changed

-

## Added

- parameter "podAnnotations" for add custom annotations to cloudify-manager-worker pods;

## Fixed

- added version-specific sections in before/after hook scripts (for CM worker v7.1.\* operations with authorization.conf file isn't necessary);
- fixed userConfig.json for support CM worker versions >=7.0;

## Removed

-

## Upgrade notes

-

# [v0.4.4]

## Changed

-

## Added

-

## Fixed

- Fixes in service, ingress, probes and cert-manager for support deploy with parameter config.security.sslEnabled=true ;

## Removed

-

## Upgrade notes

-

# [v0.4.3]

## Changed

-

## Added

- Additional process for stream log files into stdout.
- Default parameter rabbitmq.auth.erlangCookie for avoid issues with helm upgrade (rabbitmq.auth.existingErlangSecret can be used instead).

## Fixed

- Fixed issue with helm upgrade and rabbitmq subchart.

## Removed

-

## Upgrade notes

- If you have rabbitmq cluster with several nodes (rabbitmq.replicaCount > 1) you need to preserve the erlang cookie from the existing installation. It can be done as follows:

```bash
$ kubectl get secret --namespace "NAMESPACE" rabbitmq -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode
```

and then please add erlang cookie parameter value, got on the previous step, into your values file:

```
rabbitmq:
  auth:
    erlangCookie: "ERLANG_COOKIE"
```

# [v0.4.2]

## Changed

-

## Added

- For k8s versions >= 1.25 added **minReadySeconds** statefulset spec for solve issue with launch second pod in HA mode.
- Added optional possibility for generate TLS certs using cert-manager (https://cert-manager.io). This feature disabled by default, can be enabled set parameter value 'tls.certManager.generate' to 'true'.
- Group of parameters 'tls.certManager' for manage options for cert-manager.

## Fixed

- Fixed issue with dependent charts removed from bitnami index (https://github.com/bitnami/charts/issues/10539).

## Removed

-

## Upgrade notes

-

# [v0.4.1] - 2022-12-12

## Changed

- Completely different way for manage config files for Cloudify Manager worker - for now values file contains parameters **mainConfig** and **userConfig** with templates for main config file (config.yaml) and user config file (userConfig.json) for CLoudify Manager worker. These templates will be rendered and copied into containers each time during pod launch/restart/etc (even if these configs already present on persistent volume). If you need to customize these config files you need to do it using helm values.

## Added

- Parameter **mainConfig** with template of main config file for Cloudify Manager worker (config.yaml).
- Parameter **userConfig** with template of user config file for Cloudify Manager worker (userConfig.json).
- Added optional posibility to use already existing in k8s secrets for all passwords parameters, following parameters was added into helm values:
  - db.serverExistingPasswordSecret
  - db.cloudifyExistingPassword.{secret/key}
  - queue.existingPasswordSecret
  - config.security.existingAdminPassword.{secret/key}
- Added optional possibility to use a secret instead of configMap for the license file (if helm value license.useSecret is true).
- Added optional ingressClassName for ingress.

## Fixed

-

## Removed

-

## Upgrade notes

If you have some manual customizations in the main or user config files (config.yaml or userConfig.json) of Cloudify Manager worker you need to migrate them in helm values (new parameters "mainConfig" and "userConfig") before upgrade. To do that, please copy parameters "mainConfig" and "userConfig" with values from default values.yaml of this helm chart and customize necessary parameters.

# [v0.4.0] - 2022-11-08

## Changed

- Helm charts **bitnami/rabbitmq** and **bitnami/postgresql** now dependent charts and may be deployed automatically, so isn't necessary to deploy them manually. For new installation we suggest to add parameters **rabbitmq.deploy: true** and **postgresql.deploy: true** for enable deploy rabbitmq and postgresql as dependencies. We left defaults for these parameters to **false** for backward compatibility (will be changed later).
- "cloudify-manager-worker/README.md" file updated.
- PostgreSQL will create PV by default (when postgres deploy enabled in parameter **postgresql.deploy: true**).
- RabbitMQ will create PV by default (when rabbitmq deploy enabled in parameter **rabbitmq.deploy: true**).
- Cloudify Manager Worker will keep PVC after helm uninstall and will try reuse PVC during install if PVC exists (similar behaviour with postgresql and rabbitmq). If you want to reinstall stack without data saving, PVCs should be removed at first (described in README.md).

## Added

- Added "cloudify-manager-worker/CHANGELOG.md" file.

## Fixed

- cert-issuer default duration for new certs was 90 days - defaulted to 10y.

## Removed

- Removed file "cloudify-manager-worker/external/postgres-values.yaml" - values file for manual install postgres from bitnami/postgres helm chart.
- Removed file "cloudify-manager-worker/external/rabbitmq-values.yaml" - values file for manual install rabbitmq from bitnami/rabbitmq helm chart.

## Upgrade notes

For upgrade from version 0.3.\* to 0.4.0 and keep data on Cloudify Manager Worker persistance volume please execute following command **before** upgrade:

```bash
kubectl -n NAMESPACE annotate --overwrite persistentvolumeclaims cfy-worker-pvc helm.sh/resource-policy=keep
```

After that you can upgrade helm release in usual way, e.g.:

```bash
helm upgrade cloudify-manager-worker cloudify-helm/cloudify-manager-worker --version 0.4.0 -f ./values.yaml -n NAMESPACE
```
