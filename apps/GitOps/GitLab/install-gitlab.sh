#!/bin/bash

#Setup Portworx Components (PWX must be already installed)

echo "Enter the namespace you would like GitLab deployed to: "  
read gitlab_namespace

if [ -z "$gitlab_namespace" ]
then
      echo "using default namespace"
      gitlab_namespace="default"
else
      echo "using $gitlab_namespace namespace"
      kubectl create ns $gitlab_namespace
fi

read -p "Install Prometheus for Portworx... y/n? (If Portworx was installed with monitoring enabled, type 'n')" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "setting up Gitlab with Portworx"
    kubectl create -f prom-operator.yaml
    until (kubectl get po -n kube-system -l k8s-app=prometheus-operator | grep "Running"); do sleep 3; echo "waiting for prometheus operator"; done
    kubectl create -f monitoring.yaml
    until (kubectl get po -n kube-system -l prometheus=prometheus | grep "Running"); do sleep 3; echo "setting up portworx monitoring"; done
else
        echo "Not installing Prometheus...continuing"
fi

# Add autopilot (kube-system)
kubectl apply -f auto-pilot-cfg.yaml
kubectl apply -f autopilot.yaml

# add storage classes
kubectl create -f pwx-gitaly-sc.yaml -n $gitlab_namespace
kubectl create -f pwx-postgresql-sc.yaml -n $gitlab_namespace
kubectl create -f pwx-redis-sc.yaml -n $gitlab_namespace
kubectl create -f pwx-minio-sc.yaml -n $gitlab_namespace
kubectl create -f pwx-prometheus-sc.yaml -n $gitlab_namespace

# Add auto pilot rules
kubectl create -f gitaly-ap-rule.yaml -n $gitlab_namespace
kubectl create -f postgresql-ap-rule.yaml -n $gitlab_namespace
kubectl create -f redis-ap-rule.yaml -n $gitlab_namespace
kubectl create -f minio-ap-rule.yaml -n $gitlab_namespace
kubectl create -f prometheus-ap-rule.yaml -n $gitlab_namespace

cat helm_options.yaml

read -p "Portworx is setup, The above configuration will used for Gitlab, continue.. y/n? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "setting up Gitlab with Portworx"
else
	echo "exiting..."
        exit 0
fi

sleep 30

# Install the GitLab Operator
GITLAB_CHART_VERSION=v3.0.0
kubectl apply -f https://gitlab.com/gitlab-org/charts/gitlab/raw/${GITLAB_CHART_VERSION}/support/crd.yaml -n $gitlab_namespace

sleep 10

# Add helm repo
helm repo add gitlab https://charts.gitlab.io/

# Update
helm repo update

# Install with opeator enabled and storage options for Portworx
# Community Version
# (add) --set global.edition=ce
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --namespace $gitlab_namespace \
  -f helm_options.yaml 

kubectl get svc gitlab-nginx-ingress-controller -n $gitlab_namespace
echo "Visit https://gitlab.<GITLAB_DOMAIN>:<443_NodePort>"
echo "User: root"
until (kubectl -n $gitlab_namespace get secret | grep "gitlab-gitlab-initial-root-password"); do sleep 3; echo "waiting for gitlab password"; done
PASS=$(kubectl -n $gitlab_namespace get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo)
echo "Password: ${PASS}"


