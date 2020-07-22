#!/bin/bash

#Based on - https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html

# Install CRDs
kubectl apply -f https://download.elastic.co/downloads/eck/1.2.0/all-in-one.yaml

until (kubectl -n elastic-system get statefulset.apps/elastic-operator -o wide | awk '{print $1, $2, $3}' |grep "1/1"); do echo "Waiting for operator";sleep 3; done

# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-volume-claim-templates.html
kubectl create -f es-sc.yaml 

## Use PX for data volumes and backup volumes
kubectl create ns elasticsearch
kubectl create -f es-cluster.yaml -n elasticsearch

