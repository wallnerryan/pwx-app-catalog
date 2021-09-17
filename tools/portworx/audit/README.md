# How to use

1. Deploy operator https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-openshift-deploy-the-operator.html

2. Deploy Filebeat, Elastic and Kibana files

```
oc deploy -f filebeat-pxaudit.yaml
oc deploy -f px-elastic-audit.yaml
oc deploy -f  kibana-pxaudit.yaml
```
