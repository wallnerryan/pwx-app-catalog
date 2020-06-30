Examples 

```
kubectl get po -l app=cassandra

kubectl run -i --tty --restart=Never --rm --image mikewright/cqlsh cqlsh cassandra-0.cassandra.default.svc.cluster.local -- --cqlversion=3.4.4

CREATE KEYSPACE newkeyspace WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3};

use newkeyspace;

CREATE TABLE emp(
  emp_id int PRIMARY KEY,
  emp_name text,
  emp_city text,
  emp_sal varint,
  emp_phone varint
  );

INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(1,'Jim', 'Salt Lake', 9848022338, 50000);
    
select * from emp;
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
