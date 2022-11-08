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

**BREAKING CHANGES:**
- Helm charts **bitnami/rabbitmq** and **bitnami/postgresql** now dependent charts and will be deployed automatically, so isn't necessary to deploy them manually. Users who updating from previous helm chart version need to add parameters **rabbitmq.deploy: false** and **postgresql.deploy: false** for disable deploy them as dependencies.


