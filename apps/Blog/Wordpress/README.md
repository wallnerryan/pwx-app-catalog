

# CREATE WORDPRESS WITH PORTWPORX

### Steps

`kubectl create secret generic mysql-pass --from-file=mysqlpasswd.txt -n wordpress`

`kubectl create -f wordpress-mysql-vols.yaml -n wordpress`

`kubectl create -f wp-mysql.yaml -n wordpress`

`kubectl create -f wordpress.yaml -n wordpress`

### Inspect Elements

```
$ kubectl get svc -n wordpress
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
wordpress         NodePort    10.233.33.159   <none>        80:30941/TCP   4m56s
wordpress-mysql   ClusterIP   10.233.16.59    <none>        3306/TCP       8m50s

$ kubectl get pvc -n wordpress
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS               AGE
mysql-pvc-1   Bound    pvc-d9c8a01c-75ea-4fca-9bd4-5230ace1779b   5Gi        RWO            portworx-sc-repl3          28m
wp-pv-claim   Bound    pvc-31518c44-bc86-4726-aea3-5db94c33f1db   5Gi        RWX            portworx-sc-repl3-shared   28m
```
