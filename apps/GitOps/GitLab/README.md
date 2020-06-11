
# Gitlab Install with Portworx for Persistence

## Pre-Reqs

1. Portworx Installed
2. Prometheues Monitoring selected during Portworx Install

## Install

1. edit helm_options.yaml and update 

```
global.hosts.externalIP
global.hosts.domain
certmanager-issuer.email
nginx-ingress: *
```

2. `sh install-gitlab.sh`


## Install Gitlab Runner

1. Navigate to https://gitlab.example.com:<NodePort_IfUsing>/admin/runners
2. Update gitlab-runner.yaml

Update the NodePort to  and `runnerRegistrationToken`
```
runnerRegistrationToken: "<token from above /admin/runners"
```

Install
```
helm repo add gitlab https://charts.gitlab.io
helm install --namespace default  gitlab-runner -f gitlab-runner.yaml gitlab/gitlab-runner
```

## Unnderstanding Gitlab Portworx Volumes for Persistence, High Availability and Data Protection

```
$ kubectl get pvc
NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
data-gitlab-postgresql-0           Bound    pvc-bfee5794-eded-4ed8-822c-048b348eda07   8Gi        RWO            pwx-postgresql-sc   106m
gitlab-minio                       Bound    pvc-b0e6d232-76ec-4b37-a4af-75d6990a6c1f   10Gi       RWO            pwx-minio-sc        106m
gitlab-prometheus-server           Bound    pvc-3eb1508b-0f1d-4030-a389-4e4c1d3d8449   8Gi        RWO            pwx-prometheus-sc   106m
redis-data-gitlab-redis-master-0   Bound    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb   5Gi        RWO            pwx-redis-sc        106m
repo-data-gitlab-gitaly-0          Bound    pvc-ce67fc45-7de6-4ba5-8938-da6b2be6fd43   50Gi       RWO            pwx-gitaly-sc       106m
```

```
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
alias pxctl="kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl "
```

```
$ pxctl v l
ID            NAME                        SIZE    HA    SHARED    ENCRYPTED    IO_PRIORITY    STATUSSNAP-ENABLED
180194690810354747    pvc-3eb1508b-0f1d-4030-a389-4e4c1d3d8449    8 GiB    2    no    no        HIGH        up - attached on 70.0.89.147    yes
815414913655760676    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb    5 GiB    1    no    no        HIGH        up - attached on 70.0.89.183    yes
175268473857442975    pvc-b0e6d232-76ec-4b37-a4af-75d6990a6c1f    10 GiB    3    no    no        HIGH        up - attached on 70.0.89.147    no
947311034434441457    pvc-bfee5794-eded-4ed8-822c-048b348eda07    8 GiB    3    no    no        HIGH        up - attached on 70.0.89.165    yes
49098222505348844    pvc-ce67fc45-7de6-4ba5-8938-da6b2be6fd43    50 GiB    3    no    no        HIGH        up - attached on 70.0.89.165    no
```

```
$ pxctl v l -s
ID            NAME                                    SIZE    HA    SHARED    ENCRYPTED    IO_PRIORITY    STATUS        SNAP-ENABLED
532007626620611155    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb_periodic_2020_Jun_11_19_29    5 GiB    1    no    no        HIGH        up - detached    no
```

##  Understanding Portworx AutoPilot Rules for Capacity Management

Portworx can manage expanding PVCs automatically which is typically left to the Gitlab admin to manually perform.

To see he autopilot rules

```
$ kubectl get autopilotrule
NAME                            AGE
gitaly-auto-volume-resize       102m
minio-auto-volume-resize        102m
postgresql-auto-volume-resize   102m
prometheus-auto-volume-resize   102m
redis-auto-volume-resize        102m
```

```
$ kubectl describe autopilotrule postgresql-auto-volume-resize
Name:         postgresql-auto-volume-resize
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  autopilot.libopenstorage.org/v1alpha1
Kind:         AutopilotRule
Metadata:
  Creation Timestamp:  2020-06-11T18:25:28Z
  Finalizers:
    autopilot.libopenstorage.org/delete
  Generation:        2
  Resource Version:  281692
  Self Link:         /apis/autopilot.libopenstorage.org/v1alpha1/autopilotrules/postgresql-auto-volume-resize
  UID:               5b277072-32fc-4412-93c6-ffe673702a26
Spec:
  Actions:
    Name:  openstorage.io.action.volume/resize
    Params:
      Scalepercentage:  200
  Conditions:
    Expressions:
      Key:       100 * (px_volume_usage_bytes / px_volume_capacity_bytes)
      Operator:  Gt
      Values:
        20
      Key:       px_volume_capacity_bytes / 1000000000
      Operator:  Lt
      Values:
        20
    Provider:  prometheus
    Type:      monitoring
  Namespace Selector:
  Poll Interval:  10
  Selector:
    Match Labels:
      App:  postgresql
Events:     <none>
```

## Usiing PX-Backup to Backup and Restore Gitlab

![Alt text](gitlab-backuprestore.png?raw=true "Gitlab-Portworx-Backup")
