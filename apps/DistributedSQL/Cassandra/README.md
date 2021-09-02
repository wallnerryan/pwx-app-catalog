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
    emp_phone, emp_sal) VALUES(2,'Joe', 'Detriot', 9846022338, 60000);
    
INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(3,'Jane', 'Seattle', 9846022338, 90000);
    
INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(4,'Mary', 'Seattle', 9877840098, 100000);

INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(4,'Sarah', 'Boston', 2549880091, 76000);

select * from emp;
```

Look at the keyspace again
```
kubectl run -i --tty --restart=Never --rm --image mikewright/cqlsh cqlsh cassandra-0.cassandra.default.svc.cluster.local -- --cqlversion=3.4.4

use newkeyspace; select * from emp;
```

## Pre and Post Hook Rules for PX-Backup

### Pre
```
nodetool flush
# or
nodetool flush -- <keyspace>
```

### Post
```
nodetool verify
# or 
nodetool verify -- <keyspace>
```

## Datastax Operator

Install operator via operatorhub or https://github.com/datastax/cass-operator/tree/master/docs/user 

`oc create -f datastax-operator-cassandra-datacenter.yaml -n db-ops`
