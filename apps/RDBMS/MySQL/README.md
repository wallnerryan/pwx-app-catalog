
#Adding data

```
create database family;

use family;

CREATE TABLE pet (name VARCHAR(20), owner VARCHAR(20),species VARCHAR(20), sex CHAR(1), birth DATE, death DATE);

INSERT INTO pet VALUES ('Roscoe','Beau','dog','m','2000-03-30',NULL);

INSERT INTO pet VALUES ('Leo','Mike','dog','m','2001-05-28',NULL);

select * from pet;
```


Backup Rules

Pre
```
mysql --user=root --password=$MYSQL_ROOT_PASSWORD -Bse 'FLUSH TABLES WITH READ LOCK;system ${WAIT_CMD};'
```

Post
```
mysql --user=root --password=$MYSQL_ROOT_PASSWORD -Bse 'FLUSH LOGS; UNLOCK TABLES;'
```
