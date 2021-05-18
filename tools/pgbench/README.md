
# Use pgbench

Enter Postgres Database Pod
```
root@postgres-777dd9b54f-r4qfv:/# su postgres
$ psql	
psql (10.1)
Type "help" for help.

postgres=# 
```

Create test DB
```
postgres=# create database testdb;
CREATE DATABASE
postgres=# # \q
```

Initialize
```
root@postgres-777dd9b54f-r4qfv:/# pgbench -U postgres -i -s 50 -n testdb
or
root@postgres-777dd9b54f-r4qfv:/# pgbench -i -s 50 -n testdb

```

Run Test
```
root@postgres-777dd9b54f-r4qfv:/# pgbench -U postgres -c 10 -j 2 -t 10000 testdb
or
root@postgres-777dd9b54f-r4qfv:/# pgbench -U postgres -c 10 -j 2 -T 600 testdb
or
root@postgres-777dd9b54f-r4qfv:/# pgbench -c 10 -j 2 -T 600 testdb
```

## Params
-c number of clients: 10
-j number of threads: 2
-t number of transactions per client: 10000
-T numbers of seconds to run (cannot use -t at same time)
