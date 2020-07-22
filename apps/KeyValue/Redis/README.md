# Redis Guestbook App on Portworx

Adapted from: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/ 

## Install

```
$ kubectl create ns redisapp
$ kubectl create -f redisapp.yam -n redisapp
```

## Monitor

Get portworx volumes
```
$ kubectl get pvc -n redisapp
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
px-redis-conf   Bound    pvc-49a95f74-1d2c-49b2-a4b1-e12178172a6c   1Gi        RWO            px-repl3-sc    27s
px-redis-data   Bound    pvc-ee4c0ff0-c9c2-4a2e-96d2-266ed923a244   1Gi        RWO            px-repl3-sc    27s
```

## Use

Get services
```
$ kubectl get svc -n redisapp
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
frontend       NodePort    10.233.44.136   <none>        80:32102/TCP   43s
redis-master   ClusterIP   10.233.42.227   <none>        6379/TCP       43s
redis-slave    ClusterIP   10.233.50.10    <none>        6379/TCP       43s
```

Access `http://<node-ip>:<frontend>` OR `http://<node-ip>:32102` in above example.

![Imgur](https://i.imgur.com/tNnY5zS.png)
