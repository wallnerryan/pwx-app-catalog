#!/usr/bin/env bash

kubectl delete deployment --all
kubectl delete statefulset --all
kubectl delete pvc --all
kubectl delete autopilotrule --all

