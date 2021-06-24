
# Cloudify manager AIO helm chart

## Description

It's a helm chart for cloudify manager worker which is:

* Not Highly available
* Has no persistent volume to survive restarts/failures
* Has all components on board: Message Broker and DB part of it.


To understand how to install and configure AIO cloudify manager please read [Cloudify AIO Helm chart](cloudify-manager-aio/README.txt)


# Cloudify manager worker

## Description
 
It's a helm chart for cloudify manager worker which is:

* Highly available, can be deployed with multiple replicas ( available only when used EFS(NFS) Volume )
* Use Persistent Volume to survive restarts/failures
* Use external DB (postgress), which may be deployed via public helm chart of Bitnami: https://github.com/bitnami/charts/tree/master/bitnami/postgresql
* Use external Message Brokes (rabbitMQ), which may be deployed via public helm chart of Bitnami: https://github.com/bitnami/charts/tree/master/bitnami

This is how the setup looks after deployed to 'cfy-example' namespace:

![cfy-manager](images/cfy-example.png)


## How to Install?

1. Deployment of DB (Postgres).

2. Deployment of Message Broker (rabbitMQ).

3. Deployment of Cloudify manager worker.


To better understand how to install and configure cloudify manager worker setup please read [Cloudify manager worker helm chart](cloudify-manager-worker/README.txt)
