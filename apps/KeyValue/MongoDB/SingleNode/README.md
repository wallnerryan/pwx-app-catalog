# MongoDB Single Node

Based on: https://medium.com/@dilipkumar/standalone-mongodb-on-kubernetes-cluster-19e7b5896b27

```
kubectl create -f mongo-pwx.yaml
```

## Interact and add data

```
kubectl exec -it mongodb-standalone-0 sh
mongo mongodb://mongodb-standalone-0.database:27017
```

```
use training
db.auth('training','password')
db.users.insert({name: 'your name'})
show collections
db.users.find()
```

## PX-Backup

Pre
```
mongo --eval "printjson(db.fsyncLock())"
```

Post
```
mongo --eval "printjson(db.fsyncUnlock())"
```
