
# sysbench in k8s

https://www.percona.com/blog/2020/02/07/how-to-measure-mysql-performance-in-kubernetes-with-sysbench/

```
kubectl run -n <namespace> -it --rm sysbench-client --image=perconalab/sysbench:latest --restart=Never -- bash
```

(in mysql Pod)
```
mysql> create database sbtest;
```

(back in sysbench)
```
sysbench oltp_read_only --tables=10 --table_size=1000000  --mysql-host=mysql --mysql-user=root --mysql-password=password --mysql-db=sbtest  prepare
sysbench oltp_read_write --tables=10 --table_size=1000000  --mysql-host=mysql --mysql-user=root --mysql-password=password --mysql-db=sbtest  prepare
```


RO
```
sysbench oltp_read_only --tables=10 --table_size=1000000  --mysql-host=mysql --mysql-user=root --mysql-password=password --mysql-db=sbtest --time=300 --threads=16 --report-interval=1 run
```

RW
```
sysbench oltp_read_write --tables=10 --table_size=1000000  --mysql-host=mysql --mysql-user=root --mysql-password=password --mysql-db=sbtest --time=300 --threads=16 --report-interval=1 run
```

Clean
```
sysbench oltp_read_write --tables=10 --table_size=1000000  --mysql-host=mysql --mysql-user=root --mysql-password=password --mysql-db=sbtest  cleanup
```
