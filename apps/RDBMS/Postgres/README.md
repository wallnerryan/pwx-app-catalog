
# Install

Based on
 - https://postgres-operator.readthedocs.io/en/latest/

## clone repo
```
git clone https://github.com/zalando/postgres-operator.git
cd postgres-operator
```

## Deploy operator
```
kubectl create -f manifests/configmap.yaml  # configuration
kubectl create -f manifests/operator-service-account-rbac.yaml  # identity and permissions
kubectl create -f manifests/postgres-operator.yaml  # deployment
kubectl create -f manifests/api-service.yaml  # operator API to be used by UI
kubectl apply -k github.com/zalando/postgres-operator/manifests
```

## verify
`kubectl get pod -l name=postgres-operator`

## manual deployment
`kubectl apply -f ui/manifests/`

## Deploy Portworx StorageClass
`kubectl create -f ../sc.yaml`

## Deploy Postgres Cluster
`kubectl create -f ../pwx-postgres-operator-cluster.yml`

## Get Cluster
`kubectl get postgresql`

## Check PVCs
`kubectl get pvc`

## Get the Pods
```
kubectl get po -l cluster-name=pwx-pg-cluster --show-labels
```

## Access the PGO UI to view cluster
`kubectl port-forward "$(kubectl get pod -l name=postgres-operator-ui --output='name')" 8081`

Navigate to http://localhost:8081 

# Connect 

## Get the PG endpoint

> Note in order to access remotely, you will need to edit the security group for the ELB.

```
export PGHOST=$(kubectl get service pwx-pg-cluster| grep elb |  awk '{print $4}')
export PGPORT=$(kubectl get service pwx-pg-cluster| grep elb |  awk '{print $5}' | cut -d":" -f1)
echo ${PGHOST}:${PGPORT}
echo $PGHOST
```

## Get passsword
```
export PGPASSWORD=$(kubectl get secret postgres.pwx-pg-cluster.credentials -o 'jsonpath={.data.password}' | base64 --decode)
```

## Connect (if you are on mac, you can run `brew install postgresql`)
```
export PGSSLMODE=require
psql -U postgres
```

## Get Cluster Info
```
root@pwx-pg-cluster-0:/home/postgres# psql -U postgres
psql (12.1 (Ubuntu 12.1-1.pgdg18.04+1), server 11.6 (Ubuntu 11.6-1.pgdg18.04+1))
Type "help" for help.

postgres=#
postgres=# SELECT client_addr, state FROM pg_stat_replication;
  client_addr   |   state
----------------+-----------
 192.168.16.180 | streaming
 192.168.50.166 | streaming
 ```

# Cleanup 

## Delete cluster
`kubectl delete postgresql pwx-pg-cluster`

## Cleanup env
```
cd ../
rm -rf postgres-operator/
```

