# MongoDB Single Node

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
