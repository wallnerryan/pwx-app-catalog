#!/bin/bash

#Based on - https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html

read -p "Install Prometheus for Portworx... y/n? (If Portworx was installed with monitoring enabled, type 'n')" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "setting up Gitlab with Portworx"
    kubectl create -f ../../../../tools/portworx/autopilot/prom-operator.yaml
    until (kubectl get po -n kube-system -l app=prometheus-operator | grep "Running"); do sleep 3; echo "waiting for prometheus operator"; done
    kubectl create -f ../../../../tools/portworx/autopilot/monitoring.yaml
    until (kubectl get po -n kube-system -l prometheus=prometheus | grep "Running"); do sleep 3; echo "setting up portworx monitoring"; done
else
        echo "Not installing Prometheus...continuing"
fi

# Add autopilot (kube-system)
kubectl apply -f ../../../../tools/portworx/autopilot/auto-pilot-cfg.yaml
kubectl apply -f ../../../../tools/portworx/autopilot/autopilot.yaml 

# Start ES install
# Install CRDs
kubectl apply -f https://download.elastic.co/downloads/eck/1.2.0/all-in-one.yaml

until (kubectl -n elastic-system get statefulset.apps/elastic-operator -o wide | awk '{print $1, $2, $3}' |grep "1/1"); do echo "Waiting for operator";sleep 3; done

# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-volume-claim-templates.html
kubectl create -f es-sc.yaml
kubectl create -f es-ap-rule.yaml 

## Use PX for data volumes and backup volumes
kubectl create ns elasticsearch
kubectl create -f es-cluster.yaml -n elasticsearch

sleep 3

kubectl get elasticsearch -n elasticsearch

until (kubectl -n elasticsearch get pod elasticsearch-es-default-0 -o wide | awk '{print $1, $2, $3}' |grep "1/1"); do echo "Waiting for elasticsearch-es-default-2";sleep 3; done
until (kubectl -n elasticsearch get pod elasticsearch-es-default-1 -o wide | awk '{print $1, $2, $3}' |grep "1/1"); do echo "Waiting for elasticsearch-es-default-2";sleep 3; done
until (kubectl -n elasticsearch get pod elasticsearch-es-default-2 -o wide | awk '{print $1, $2, $3}' |grep "1/1"); do echo "Waiting for elasticsearch-es-default-2";sleep 3; done

PASSWORD=$(kubectl -n elasticsearch get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- curl -u "elastic:$PASSWORD" -k "https://elasticsearch-es-http:9200"
