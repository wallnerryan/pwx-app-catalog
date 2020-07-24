#!/bin/bash

kubectl create ns rabbitmq
kubectl create ns monitoring
kubectl create -f rabbit-sc.yaml

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
helm install \
  rmq \
  --namespace rabbitmq \
  --set replicaCount=2 \
  --set rabbitmqUsername=admin \
  --set rabbitmqPassword=secretpassword \
  --set managementPassword=anothersecretpassword \
  --set rabbitmqErlangCookie=secretcookie  \
  --set persistentVolume.enabled=true \
  --set persistentVolume.storageClass=portworx-rabbitmq \
  --set schedulerName=stork \
  stable/rabbitmq-ha

#TODO
# https://docs.portworx.com/portworx-install-with-kubernetes/application-install-with-kubernetes/rabbitmq/#validate-the-cluster-functionality
