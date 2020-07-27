#!/bin/bash

helm delete --namspace rabbitmq --purge rmq 

kubectl -n rabbitmq delete sts/rmq-rabbitmq-ha \
  svc/rmq-rabbitmq-ha svc/rmq-rabbitmq-ha-discovery \
  rolebinding/rmq-rabbitmq-ha \
  role/rmq-rabbitmq-ha \
  sa/rmq-rabbitmq-ha \
  secret/rmq-rabbitmq-ha \
  cm/rmq-rabbitmq-ha

kubectl -n rabbitmq delete pvc/data-rmq-rabbitmq-ha-0 pvc/data-rmq-rabbitmq-ha-1 \
  sc/portworx-rabbitmq \
  po/perftest
