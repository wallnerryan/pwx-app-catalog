Examples 

```
kubectl get po -l app=cassandra

kubectl run -i --tty --restart=Never --rm --image mikewright/cqlsh cqlsh cassandra-0.cassandra.default.svc.cluster.local -- --cqlversion=3.4.4

use newkeyspace; select * from emp;
```

Inset some data
```
INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(1,'Joe', 'Detriot', 9846022338, 60000);

select * from emp;
```

Look at the keyspace again
```
kubectl run -i --tty --restart=Never --rm --image mikewright/cqlsh cqlsh cassandra-0.cassandra.default.svc.cluster.local -- --cqlversion=3.4.4

use newkeyspace; select * from emp;
```
