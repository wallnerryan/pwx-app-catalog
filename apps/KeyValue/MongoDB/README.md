## MongoDB with Portworx

```
kubectl create -f mongo-pwx.ym [-n <namespace>]
```

## Example Data

Exec into pod
```
mongo
> use pets

> db.dogs.insertOne({ "name" : "roscoe","sex" : "m", "nicknames" : ["rosc","bud","roscoe-beau"], "hight_weight" : { "h" : 28, "w" : 84}, "age" : 5}) 
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
