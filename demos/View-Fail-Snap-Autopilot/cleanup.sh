#!/usr/bin/env bash

kubectl delete deployment --all
kubectl delete statefulset --all
kubectl delete pvc --all
kubectl delete autopilotrule --all
kubectl delete job --all
kubectl delete svc --all
kubectl delete secrets --all
kubectl delete configmap --all
kubectl delete pods --all
kubectl delete sc cockroach-pwx-storage-class px-postgres-sc px-storageclass 
