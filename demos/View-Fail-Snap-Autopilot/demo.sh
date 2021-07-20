#!/bin/bash

########################
# include the magic
########################
. ../demo-magic-tool/demo-magic.sh

# hide the evidence
clear

# ************ VIEW ************ #

# view storage class
# view deployment.
pe "cat ../../apps/RDBMS/Postgres/SingleNode/postgres-pwx.yaml"

# deploy application
pe "kubectl create -f ../../apps/RDBMS/Postgres/SingleNode/postgres-pwx.yaml"

# (behind scened deploy statefulset for groupsnap later)
kubectl create -f ../../apps/DistributedSQL/Cassandra/cassandra-pwx.yaml

# view volume via pxctl
pe "watch kubectl get po -l app=postgres"
VOLS=`kubectl get pvc | grep postgres | awk '{print $3}'`
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
pe "kubectl exec -it ${PX_POD} -n kube-system -- /opt/pwx/bin/pxctl volume inspect $VOLS"

# insert data
POD=`kubectl get pods -l app=postgres | grep Running | grep 1/1 | awk '{print $1}'`
pe "kubectl exec ${POD} -- psql -U user -c 'create database pxdemo'" 
pe "kubectl exec ${POD} -- pgbench -U user -i -s 5 pxdemo" 
pe "kubectl exec ${POD} -- psql -U user -d pxdemo -c 'select count(*) from pgbench_accounts'" 

# ************ FAIL ************ #

# cordon node, fail app, show on new node
NODE=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $7}'`
pe "kubectl cordon ${NODE}"
POD=`kubectl get pods -l app=postgres -o wide | grep -v NAME | awk '{print $1}'`
pe "kubectl delete pod ${POD}"
pe "watch kubectl get pods -l app=postgres -o wide"

# show same data is there. (uncordon node)
kubectl uncordon ${NODE}
POD=`kubectl get pods -l app=postgres | grep Running | grep 1/1 | awk '{print $1}'`
pe "kubectl exec ${POD} -- psql -U user -d pxdemo -c 'select count(*) from pgbench_accounts'" 

# ************ GROUP SNAP ************ #

# view statefulset (cassandra)
pe "kubectl get pods -l app=cassandra"
pe "kubectl get pvc | grep cassandra"

# insert data, flush data
CASSPOD=`kubectl get pods -l app=cassandra -o wide | head -n 2 | grep -v NAME | awk '{print $1}'`
kubectl cp cass.cql default/cqlsh:/tmp/cass.cql
kubectl cp cass-select.cql default/cqlsh:/tmp/cass-select.cql
kubectl cp cass-drop.cql default/cqlsh:/tmp/cass-drop.cql
pe "kubectl exec cqlsh -- cqlsh cassandra-0.cassandra.default.svc.cluster.local --cqlversion=3.4.2 -f /tmp/cass.cql"
pe "kubectl exec ${CASSPOD} -- nodetool flush"

# take snapshot, view group snapshot
pe "cat ../../apps/DistributedSQL/Cassandra/cass-group-snap.yml"
pe "kubectl create -f ../../apps/DistributedSQL/Cassandra/cass-group-snap.yml"
pe "watch kubectl get volumesnapshots"

# drop tables
pe "kubectl exec cqlsh -- cqlsh cassandra-0.cassandra.default.svc.cluster.local --cqlversion=3.4.2 -f /tmp/cass-drop.cql"

# restore cassandra
snap1=`kubectl get volumesnapshot | sed -n '2p' |  grep -v NAME | awk '{print $1}'`
snap2=`kubectl get volumesnapshot | sed -n '3p' |  grep -v NAME | awk '{print $1}'`
snap3=`kubectl get volumesnapshot | sed -n '4p' |  grep -v NAME | awk '{print $1}'`
sed -i 's/<REPLACE-1>/'$snap1'/g' ../../apps/DistributedSQL/Cassandra/cass-vols-from-snaps.yml
sed -i 's/<REPLACE-2>/'$snap1'/g' ../../apps/DistributedSQL/Cassandra/cass-vols-from-snaps.yml
sed -i 's/<REPLACE-3>/'$snap1'/g' ../../apps/DistributedSQL/Cassandra/cass-vols-from-snaps.yml
pe "kubectl create -f ../../apps/DistributedSQL/Cassandra/cass-vols-from-snaps.yml"
pe "kubectl get pvc | grep restored"
kubectl delete statefulset cassandra
pe "kubectl create -f ../../apps/DistributedSQL/Cassandra/cass-from-snaps.yml"

# view data valid
pe "watch kubectl get pods -l app=cassandra-restored -o wide"
pe "kubectl exec cqlsh -- cqlsh cassandra-restored-0.cassandra-restored.default.svc.cluster.local --cqlversion=3.4.2 -f /tmp/cass-select.cql"

# ************ AUTOPILOT PVC ************ #

# view curent size of volume
pe "kubectl get pvc | grep postgres"

# view and apply AP rule
pe "cat  ../../apps/RDBMS/Postgres/SingleNode/postgres-ap-rule.yaml"
pe "kubectl create -f ../../apps/RDBMS/Postgres/SingleNode/postgres-ap-rule.yaml"

# run command to fill DB
pe "kubectl exec ${POD} -- pgbench -U user -i -s 75 pxdemo" 

# view output of AP rule
pe "watch kubectl get events --field-selector involvedObject.kind=AutopilotRule --all-namespaces"

# view new size of volume.
pe "kubectl get pvc | grep postgres"

# FINISH #
 