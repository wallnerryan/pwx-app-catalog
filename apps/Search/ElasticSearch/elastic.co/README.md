# Elasticsearch (elastic.co) Cluster with Portworx

![alt](https://i.imgur.com/VPnSaRt.png)

## Pre-reqs
 - Portworx must be installed Kubernetes
 - KUBECONFIG points to Kubernetes cluster

## Install
```
./install-elasticsearch.sh
```

```
$ kubectl -n elasticsearch get elasticsearch
NAME            HEALTH   NODES   VERSION   PHASE   AGE
elasticsearch   green    3       7.8.0     Ready   56m
```

```
$ kubectl -n elasticsearch get po
NAME                         READY   STATUS    RESTARTS   AGE
elasticsearch-es-default-0   1/1     Running   0          55m
elasticsearch-es-default-1   1/1     Running   0          55m
elasticsearch-es-default-2   1/1     Running   0          55m
```

```
$ kubectl -n elasticsearch get pvc
NAME                                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                       AGE
elasticsearch-backups                           Bound    pvc-7357d6ff-0a3a-4c54-a28e-c322fbcc8aa7   50Gi       RWO            elastic-shared-pwx-storage-class   55m
elasticsearch-data-elasticsearch-es-default-0   Bound    pvc-22456fa5-b695-4661-b877-72d06254f53e   5Gi        RWO            elastic-pwx-storage-class          55m
elasticsearch-data-elasticsearch-es-default-1   Bound    pvc-8a9cbdcd-bc45-4e25-940e-7a3cd1a40dbd   5Gi        RWO            elastic-pwx-storage-class          55m
elasticsearch-data-elasticsearch-es-default-2   Bound    pvc-cda83234-b97a-462f-a348-beff6965cc46   5Gi        RWO            elastic-pwx-storage-class          55m
```

Get nodes via API
```
PASSWORD=$(kubectl -n elasticsearch get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X GET -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/_cat/nodes?v\""
oad_5m load_15m node.role master name
10.233.96.88            62          64   7    0.83    0.74     0.58 dilmrt    *      elasticsearch-es-default-1
10.233.92.41             8          63  19    2.13    1.88     1.84 dilmrt    -      elasticsearch-es-default-0
10.233.105.78            7          65  15   48.29   35.23    20.25 dilmrt    -      elasticsearch-es-default-2
```

# Autopilot

```
$ kubectl -n elasticsearch get autopilotrule
NAME                         AGE
es-data-auto-volume-resize   56m
```

```
$ kubectl get events --field-selector involvedObject.kind=AutopilotRule --all-namespaces
NAMESPACE   LAST SEEN   TYPE     REASON       OBJECT                                     MESSAGE
default     59m         Normal   Transition   autopilotrule/es-data-auto-volume-resize   rule: es-data-auto-volume-resize:pvc-627dce5b-ae6b-4f89-b3bb-96ca6eaaf59d transition from Initializing => Normal
default     59m         Normal   Transition   autopilotrule/es-data-auto-volume-resize   rule: es-data-auto-volume-resize:pvc-55cdffe0-11b9-4ab9-bbc2-ab619a6d07e7 transition from Initializing => Normal
default     59m         Normal   Transition   autopilotrule/es-data-auto-volume-resize   rule: es-data-auto-volume-resize:pvc-6487a0e3-3020-4141-8ab2-aef3af2f8c8b transition from Initializing => Normal
default     56m         Normal   Transition   autopilotrule/es-data-auto-volume-resize   rule: es-data-auto-volume-resize:pvc-22456fa5-b695-4661-b877-72d06254f53e transition from Initializing => Normal
```

# Use ES

Create index
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X PUT -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/customer?pretty&pretty\""
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "customer"
}
```

Get Indices
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X GET -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/_cat/indices?v&pretty\""
green  open   customer pjtPstlwRRK_YNfFLSKgNg   1   1          0            0       416b           208b
```

Add data
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- curl -X PUT -u "elastic:$PASSWORD" -k "https://elasticsearch-es-http:9200/customer/external/1?pretty&pretty" -H 'Content-Type: application/json' -d'{"name": "Daenerys Targaryen"}';
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}
```

![alt](https://i.imgur.com/DdwDKJW.png)

Second
```
 kubectl -n elasticsearch exec elasticsearch-es-default-0 -- curl -X PUT -u "elastic:$PASSWORD" -k "https://elasticsearch-es-http:9200/customer/external/2?pretty&pretty" -H 'Content-Type: application/json' -d'{"name": "Ryan Wallner"}';
```

Get
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- curl -X GET -u "elastic:$PASSWORD" -k "https://elasticsearch-es-http:9200/customer/external/2?pretty&pretty";
```

# PX-Backup

## Pre-exec Rule

You can fetch the password 
```
PASSWORD=$(kubectl -n elasticsearch get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'); echo $PASSWORD
```

### Examples of pre-exec rule

#### Freeze customer index
```
curl -X POST -u "elastic:$PASSWORD" -k "https://elasticsearch-es-http:9200/customer/_freeze?pretty"
```

#### Take snapshot of index
with uuid
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X PUT -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/_snapshot/es_backups/snapshot_$(uuidgen)?wait_for_completion=true&pretty\""
```

Or with current date and time.
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X PUT -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/_snapshot/es_backups/%3Csnapshot-%7Bnow%2Fd%7D%3E?wait_for_completion=true&pretty\"
```

Running the above rule will produce snapshots in the `/usr/share/elasticsearch/backups` directory which is backed by shared volume. This shared volume will also be backed up and sent to object storage as part of the backup.

To see snapshots
```
$ kubectl -n elasticsearch exec elasticsearch-es-default-0 -- ls /usr/share/elasticsearch/backups
index-1
index.latest
meta-eplvWNB0SLW29U5Pizph9w.dat
meta-jDKxIUjOQMKhTPegh27zuA.dat
snap-eplvWNB0SLW29U5Pizph9w.dat
snap-jDKxIUjOQMKhTPegh27zuA.dat
```

### Post exec

#### UnFreeze customer index
```
curl -X POST -u "elastic:$PASSWORD" -k "https://elasticsearch-es-http:9200/customer/_unfreeze?pretty"
```

## Restore

> If restoring to new cluster, make sure to use `ApplicationRegistration`. The install script automatically sets this up.

### Test restore.

Simluate disaster
```
kubectl delete ns elasticsearch
```

In PX-Backup, select the backup and click restore. Then make sure all nodes are online.
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X GET -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/_cat/nodes?v\""
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0ip             heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
10.233.96.216            23          63  10    0.39    1.05     1.35 dilmrt    -      elasticsearch-es-default-2
10.233.105.125           43          72  16    2.28    2.04     2.73 dilmrt    *      elasticsearch-es-default-0
10.233.92.44             15          63  20    2.95    3.30     3.50 dilmrt    -      elasticsearch-es-default-1
```

#### Optional restore specific indices from pre-exec snapshots 
Once Elasticsearch and all the backups are restored, you will have a running Elasticsearch cluster. However, you may wish to take the extras step by also restoring ertain indices or cluster state by restoring from a specific snapshot in the `/usr/share/elasticsearch/backups` directory.

First, get a list of snapshots
```
kubectl -n elasticsearch exec elasticsearch-es-default-0 -- /bin/sh -c "curl -X GET -u \"elastic:$PASSWORD\" -k \"https://elasticsearch-es-http:9200/_snapshot/es_backups/_all?pretty;verbose=false\""
```

Everything
```
kubectl  -n elasticsearch exec elasticsearch-es-default-0 -- curl -u "elastic:$PASSWORD" -k -X POST "https://elasticsearch-es-http:9200/_snapshot/es_backups/snapshot-a8cb6f65-6b18-4706-993c-665753664b1b-2020.07.23/_restore?pretty" -H 'Content-Type: application/json'
```

Specific Index
```
kubectl  -n elasticsearch exec elasticsearch-es-default-0 -- curl -u "elastic:$PASSWORD" -k -X POST "https://elasticsearch-es-http:9200/_snapshot/es_backups/snapshot-a8cb6f65-6b18-4706-993c-665753664b1b-2020.07.23/_restore?pretty" -H 'Content-Type: application/json' -d'{"indices": "index_1,index_2","ignore_unavailable": true,"include_global_state": false,"rename_pattern": "index_(.+)","rename_replacement": "restored_index_$1","include_aliases": false}'
'

```
