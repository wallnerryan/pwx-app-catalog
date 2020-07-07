## MongoDB with Portworx

```
kubectl create ns mongo-1
kubectl create -f mongo-pwx.ym -n mongo-1
```

> If you want to use different NS, update the ClusterRoleBinding namespace

## Example Data

Exec into pod
```
kubectl exec  -it -n mongo-1  mongo-0 bash
```

Access database
```
mongo
> use pets

> db.dogs.insertOne({ "name" : "roscoe","sex" : "m", "nicknames" : ["rosc","bud","roscoe-beau"], "hight_weight" : { "h" : 28, "w" : 84}, "age" : 5}) 
```

List records
```
rs0:PRIMARY> db.dogs.find()
{ "_id" : ObjectId("5f04c85453ac9eb44782b411"), "name" : "roscoe", "sex" : "m", "nicknames" : [ "rosc", "bud", "roscoe-beau" ], "hight_weight" : { "h" : 28, "w" : 84 }, "age" : 5 }
```


```
> db.dogs.insertOne({ "name" : "leo","sex" : "m", "nicknames" : ["lee"], "hight_weight" : { "h" : 30, "w" : 89}, "age" : 2}) 
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
