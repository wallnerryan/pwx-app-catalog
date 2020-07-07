## MongoDB with Portworx

```
kubectl create -f mongo-pwx.ym [-n <namespace>]
```

## Backup Rules

Pre
```
mongo --eval "printjson(db.fsyncLock())"
```

Post
```
mongo --eval "printjson(db.fsyncUnlock())"
```
