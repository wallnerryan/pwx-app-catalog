
# Gitlab Install with Portworx for Persistence

## What is Gitlab

GitLab is a complete DevOps platform, delivered as a single application

GitLab has the following Stateful Components

- Gitaly (persists the Git repositories)
- PostgreSQL (persists the GitLab database data)
- Redis (persists GitLab job data)
- MinIO (persists the object storage data)

### Easily manage these with Portworx

Gitlab does not provide management around storage changes such as capacity and movement. *portworx does*

Let Portworx automatically manage replication, capacity management and backup & restore for Gitlab.

# Install Gitlab with Portworx Data Managment

## Pre-Reqs

1. Portworx Installed
2. Prometheues Monitoring selected during Portworx Install (via https://central.portworx.com)

## Install

1. edit `helm_options.yaml` and update 

2. `sh install-gitlab.sh` (This will install and configure Portworx for Gitlab)

## Install Gitlab Runner

1. Navigate to `https://gitlab.example.com:<NodePort_IfUsing>/admin/runners`
2. Update `gitlab-runner.yaml`

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

View that the state of the rules are `Normal`
```
$ kubectl get events --field-selector involvedObject.kind=AutopilotRule --all-namespaces
NAMESPACE   LAST SEEN   TYPE     REASON       OBJECT                                        MESSAGE
default     19s         Normal   Transition   autopilotrule/gitaly-auto-volume-resize       rule: gitaly-auto-volume-resize:pvc-ce67fc45-7de6-4ba5-8938-da6b2be6fd43 transition from Initializing => Normal
default     14s         Normal   Transition   autopilotrule/minio-auto-volume-resize        rule: minio-auto-volume-resize:pvc-b0e6d232-76ec-4b37-a4af-75d6990a6c1f transition from Initializing => Normal
default     10s         Normal   Transition   autopilotrule/postgresql-auto-volume-resize   rule: postgresql-auto-volume-resize:pvc-bfee5794-eded-4ed8-822c-048b348eda07 transition from Initializing => Normal
default     4s          Normal   Transition   autopilotrule/prometheus-auto-volume-resize   rule: prometheus-auto-volume-resize:pvc-3eb1508b-0f1d-4030-a389-4e4c1d3d8449 transition from Initializing => Normal
default     3s          Normal   Transition   autopilotrule/redis-auto-volume-resize        rule: redis-auto-volume-resize:pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb transition from Initializing => Normal
```

These rules are setup such that if the volume has `less than 20%` of the capacity left it will `grow the volume by 200%`

## Usiing PX-Backup to Backup and Restore Gitlab

![Alt text](gitlab-backuprestore.png?raw=true "Gitlab-Portworx-Backup")

