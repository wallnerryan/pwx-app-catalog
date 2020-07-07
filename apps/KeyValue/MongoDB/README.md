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
```

Add Data
```
> db.dogs.insertOne({ "name" : "roscoe","sex" : "m", "nicknames" : ["rosc","bud","roscoe-beau"], "hight_weight" : { "h" : 28, "w" : 84}, "age" : 5}) 
```

List records
```
rs0:PRIMARY> db.dogs.find()
{ "_id" : ObjectId("5f04c85453ac9eb44782b411"), "name" : "roscoe", "sex" : "m", "nicknames" : [ "rosc", "bud", "roscoe-beau" ], "hight_weight" : { "h" : 28, "w" : 84 }, "age" : 5 }
```

Add more data
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

## admin

List mongo replset
```
rs0:PRIMARY> db.runCommand( { isMaster: 1 } )
{
	"hosts" : [
		"10.233.105.61:27017",
		"10.233.105.32:27017",
		"10.233.105.225:27017"
	],
	"setName" : "rs0",
	"setVersion" : 5,
	"ismaster" : true,
	"secondary" : false,
	"primary" : "10.233.105.61:27017",
	"me" : "10.233.105.61:27017",
	"electionId" : ObjectId("7fffffff0000000000000001"),
	"lastWrite" : {
		"opTime" : {
			"ts" : Timestamp(1594149132, 1),
			"t" : NumberLong(1)
		},
		"lastWriteDate" : ISODate("2020-07-07T19:12:12Z"),
		"majorityOpTime" : {
			"ts" : Timestamp(1594149132, 1),
			"t" : NumberLong(1)
		},
		"majorityWriteDate" : ISODate("2020-07-07T19:12:12Z")
	},
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 100000,
	"localTime" : ISODate("2020-07-07T19:12:21.985Z"),
	"logicalSessionTimeoutMinutes" : 30,
	"connectionId" : 79,
	"minWireVersion" : 0,
	"maxWireVersion" : 8,
	"readOnly" : false,
	"ok" : 1,
	"$clusterTime" : {
		"clusterTime" : Timestamp(1594149132, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1594149132, 1)
}
```
