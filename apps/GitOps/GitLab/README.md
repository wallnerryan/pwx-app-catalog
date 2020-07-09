
# Gitlab Install with Portworx for Persistence

Based on: 
- https://docs.gitlab.com/charts/
- https://docs.gitlab.com/charts/installation/deployment.html

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

Copy the token next to `Use the following registration token during setup` and place in `gitlab-runner.yaml`
```
runnerRegistrationToken: "<token from above /admin/runners"
```

Next, install the runner
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
341211473088135507    pvc-3eb1508b-0f1d-4030-a389-4e4c1d3d8449_daily_2020_Jun_12_12_00    8 GiB    2    no    no        HIGH        up - detached    no
327272098153801489    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb_periodic_2020_Jun_12_16_08    5 GiB    1    no    no        HIGH        up - detached    no
86941070146763390    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb_periodic_2020_Jun_12_17_08    5 GiB    1    no    no        HIGH        up - detached    no
858702785584689017    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb_periodic_2020_Jun_12_18_08    5 GiB    1    no    no        HIGH        up - detached    no
4811708558282678    pvc-63febd2d-01aa-42cc-a7a3-ba5a600fedbb_periodic_2020_Jun_12_19_08    5 GiB    1    no    no        HIGH        up - detached    no
952069476450457085    pvc-bfee5794-eded-4ed8-822c-048b348eda07_daily_2020_Jun_12_12_00    8 GiB    3    no    no        HIGH        up - detached    no
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

For example, these rules can be setup such that if the volume has `less than 20%` of the capacity left it will `grow the volume by 200%`

### To test capacity management

(Password is `postgresql-postgres-password` in `kubectl get secret gitlab-postgresql-password  -o yaml`)

```
PASS=$(kubectl get secret gitlab-postgresql-password -ojsonpath='{.data.postgresql-postgres-password}' | base64 --decode ; echo)
echo $PASS
```

Enter the database
```
kubectl exec -it gitlab-postgresql-0 bash
```

Login (use password from above)
```
psql -U postgres
```

```
create database pxdemo;
\l
\q
```

```
pgbench -U postgres  -i -s 500 pxdemo
Password:
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data...
100000 of 5000000 tuples (2%) done (elapsed 0.55 s, remaining 27.09 s)
200000 of 5000000 tuples (4%) done (elapsed 1.54 s, remaining 36.90 s)
300000 of 5000000 tuples (6%) done (elapsed 2.89 s, remaining 45.22 s)
400000 of 5000000 tuples (8%) done (elapsed 3.61 s, remaining 41.49 s)
500000 of 5000000 tuples (10%) done (elapsed 4.74 s, remaining 42.69 s)
600000 of 5000000 tuples (12%) done (elapsed 5.98 s, remaining 43.83 s)
700000 of 5000000 tuples (14%) done (elapsed 6.77 s, remaining 41.58 s)
800000 of 5000000 tuples (16%) done (elapsed 8.09 s, remaining 42.49 s)
900000 of 5000000 tuples (18%) done (elapsed 9.54 s, remaining 43.46 s)
1000000 of 5000000 tuples (20%) done (elapsed 10.42 s, remaining 41.69 s)
1100000 of 5000000 tuples (22%) done (elapsed 11.48 s, remaining 40.71 s)
1200000 of 5000000 tuples (24%) done (elapsed 12.85 s, remaining 40.70 s)
```

Observe

```
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl v l
watch "kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl v i <postgres-PX-VOL-ID>"
```

Watch autopilot events
```
watch kubectl get events --field-selector involvedObject.kind=AutopilotRule --all-namespaces
default     3m53s	Normal   Transition   autopilotrule/postgresql-auto-volume-resize   rule: postgresql-auto-volume-resize:pvc-4630cded-0727-409d-be67-5c6201434220 tra
nsition from Normal => Triggered
default     3m14s       Normal   Transition   autopilotrule/postgresql-auto-volume-resize   rule: postgresql-auto-volume-resize:pvc-4630cded-0727-409d-be67-5c6201434220 tra
nsition from Triggered => ActiveActionsPending
default     3m10s       Normal   Transition   autopilotrule/postgresql-auto-volume-resize   rule: postgresql-auto-volume-resize:pvc-4630cded-0727-409d-be67-5c6201434220 tra
nsition from ActiveActionsPending => ActiveActionsInProgress
default     3m2s 	Normal   Transition   autopilotrule/postgresql-auto-volume-resize   rule: postgresql-auto-volume-resize:pvc-4630cded-0727-409d-be67-5c6201434220 tra
nsition from ActiveActionsInProgress => ActiveActionsTaken
```

Observe new size of PVC
```
kubectl get pvc
```

## Usiing PX-Backup to Backup and Restore Gitlab

![Alt text](gitlab-backuprestore.png?raw=true "Gitlab-Portworx-Backup")

