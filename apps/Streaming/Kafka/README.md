# Kafka

Based on Confluent Kafka Operator
 - https://docs.confluent.io/current/installation/operator/co-quickstart.html
 - https://docs.confluent.io/5.3.0/installation/operator/co-deployment.html

## Pre-reqs

1. Kubernetes + Portworx Installed

## Prep

```
oc create -f pwx-sc.yaml

oc patch storageclass pwx-storage-class -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### Adjust security in Openshift

https://docs.confluent.io/5.3.0/installation/operator/co-deployment.html#openshift-deployment

OR

(Dev or test only!)

`oc edit scc` 
- (edit all allowHostPorts true)
- (edit all runAsUser to RunAsAny)
- (edit fsGroup to RunAsAny)


### Install

Pull this repo.
`cd pwx-app-catalog/apps/Streaming/Kafka/`

Download the Confluent Kafka Operator Bundle
```
wget https://platform-ops-bin.s3-us-west-1.amazonaws.com/operator/confluent-operator-5.5.1.tar.gz
cd <CONFLUENT_TAR_EXOPORT>/helm/
```

Edit the YAML
```
vi ../values.yaml
export VALUES_FILE="../values.yaml"
```

> Note the below snipper from `values.yaml` is what makes Kafka, ZK and other confluent components use Portworx.
```
storage:
      ##
      provisioner: kubernetes.io/portworx-volume
      reclaimPolicy: Delete
      allowVolumeExpansion: true
      parameters:
        repl: "2"
```

Install Kafka and Zookeeper
```
helm install kafka-2-operator -f $VALUES_FILE --namespace kafka-2 --set operator.enabled=true ./confluent-operator

(Remove `--set disableHostPort=true` if you have enough nodes)
helm install kafka-2-zk -f $VALUES_FILE  --namespace kafka-2 --set disableHostPort=true --set zookeeper.enabled=true ./confluent-operator

(Remove `--set disableHostPort=true` if you have enough nodes)
helm install kafka-2-kafka -f $VALUES_FILE  --namespace kafka-2 --set disableHostPort=true --set kafka.enabled=true ./confluent-operator

(Must not be using `--set disableHostPort=true` for Kakfa/ZK)
helm install kafka-2-schemaregistry -f $VALUES_FILE  --namespace kafka-2 --set disableHostPort=true --set schemaregistry.enabled=true ./confluent-operator
```

### Interact with Kafka 

Verify and Test Kafka
```
kubectl get kafka -n kafka-2 -oyaml | grep bootstrap.servers

kubectl -n kafka-2 exec -it kafka-0 bash

(kafka-0) cat << EOF > kafka.properties
bootstrap.servers=kafka:9071
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="test" password="test123";
sasl.mechanism=PLAIN
security.protocol=SASL_PLAINTEXT
EOF

(kafka-0) kafka-broker-api-versions --command-config kafka.properties --bootstrap-server kafka:9071

(kafka-0) kafka-topics --create --zookeeper zookeeper.kafka-2.svc.cluster.local:2181/kafka-kafka-2 --replication-factor 2 --partitions 1 --topic example

(kafka-0) seq 10000 | kafka-console-producer --topic example --broker-list kafka:9071 --producer.config kafka.properties

(kafka-0) kafka-console-consumer --from-beginning --topic example --bootstrap-server  kafka:9071 --consumer.config kafka.properties
9997
9998
9999
10000
^CProcessed a total of 10000 messages
```

### PX Persistence 
```
$ oc get pvc -n kafka-2
NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                        AGE
data-zookeeper-0     Bound    pvc-09ed87fa-e631-11ea-821b-02815434edc7   10Gi       RWO            zookeeper-standard-ssd-us-east-1a   24m
data-zookeeper-1     Bound    pvc-0a676873-e631-11ea-821b-02815434edc7   10Gi       RWO            zookeeper-standard-ssd-us-east-1b   24m
data-zookeeper-2     Bound    pvc-0ae1eb68-e631-11ea-821b-02815434edc7   10Gi       RWO            zookeeper-standard-ssd-us-east-1c   24m
data0-kafka-0        Bound    pvc-61a56508-e631-11ea-821b-02815434edc7   10Gi       RWO            kafka-standard-ssd-us-east-1a       21m
data0-kafka-1        Bound    pvc-61e223a3-e631-11ea-821b-02815434edc7   10Gi       RWO            kafka-standard-ssd-us-east-1b       21m
data0-kafka-2        Bound    pvc-621f3149-e631-11ea-821b-02815434edc7   10Gi       RWO            kafka-standard-ssd-us-east-1c       21m
txnlog-zookeeper-0   Bound    pvc-0a2ac76d-e631-11ea-821b-02815434edc7   10Gi       RWO            zookeeper-standard-ssd-us-east-1a   24m
txnlog-zookeeper-1   Bound    pvc-0aa4e801-e631-11ea-821b-02815434edc7   10Gi       RWO            zookeeper-standard-ssd-us-east-1b   24m
txnlog-zookeeper-2   Bound    pvc-0b1e9130-e631-11ea-821b-02815434edc7   10Gi       RWO            zookeeper-standard-ssd-us-east-1c   24m

$ PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
$ alias pxctl="kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl "
$ pxctl v l
ID            NAME                        SIZE    HA    SHARED    ENCRYPTED    IO_PRIORITY    STATUS            SNAP-ENABLED
845057556591530132    pvc-09ed87fa-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.47.151    no
274002250613238302    pvc-0a2ac76d-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.47.151    no
929171854431635293    pvc-0a676873-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.52.1    no
514842787498963913    pvc-0aa4e801-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.52.1    no
108612170051030261    pvc-0ae1eb68-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.54.68    no
99290045691227076    pvc-0b1e9130-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.54.68    no
805236943065356327    pvc-61a56508-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.54.68    no
635612394401870767    pvc-61e223a3-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.47.151    no
1131314729577242242    pvc-621f3149-e631-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.52.1    no
204180338036835574    pvc-81c6da45-e622-11ea-821b-02815434edc7    10 GiB    2    no    no        LOW        up - attached on 172.31.43.162    no
```

### Application Registration
```
kafkaclusters.cluster.confluent.com
zookeeperclusters.cluster.confluent.com             

oc create -f kafka-appreg.yaml

oc create -f zk-appreg.yaml

$ oc get applicationregistration
NAME        AGE
cassandra   2h
couchbase   2h
ibm         2h
kafka       13s
redis       2h
weblogic    2h
zookeeper   9s
```

## Backup

Confluent Kafka Backed up with PX-Backup

![alt](https://i.imgur.com/HMbHdcI.png)

![alt](https://i.imgur.com/MAyZ3ab.png)

## Restore

### Adjust security in Openshift

https://docs.confluent.io/5.3.0/installation/operator/co-deployment.html#openshift-deployment

OR

(Dev or test only!)

`oc edit scc` 
- (edit all allowHostPorts true)
- (edit all runAsUser to RunAsAny)
- (edit fsGroup to RunAsAny)

### Restore using PX-Backup

Select destination cluster and start the restore job.

![alt](https://i.imgur.com/03qoI41.png)

![alt](https://i.imgur.com/AFkt0sA.png)

![alt](https://i.imgur.com/ozmhMk9.png)

### Test the restore worked

```
kubectl exec -it kafka-0 -n kafka-2 -- bash
(kafk-0) kafka-console-consumer --from-beginning --topic example --bootstrap-server  kafka:9071 --consumer.config kafka.properties
```

### Cleanup Distination (restored)

```
$ oc -n kafka-2 delete zookeepercluster.cluster.confluent.com/zookeeper kafkacluster.cluster.confluent.com/kafka
$ oc delete crd zookeeperclusters.cluster.confluent.com kafkaclusters.cluster.confluent.com
$ oc delete ns kafka-2
```

You may also troubleshoot using https://access.redhat.com/solutions/4165791. If you delete namespace before CRDs or Finalizers it can get stuck `Terminating`
