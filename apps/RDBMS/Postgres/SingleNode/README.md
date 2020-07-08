# Single Instance Postgres Database with Portworx

```
kubectl create -f postgres-pwx.yaml
```

## Data

```
psql -c "create database test;"

(or) 

\c test;

psql test -c "
create table posts (
  id integer,
  title character varying(100),
  content text,
  published_at timestamp without time zone,
  type character varying(100)
);

insert into posts (id, title, content, published_at, type) values
(100, 'New Post', 'Epic SQL Content', '2018-01-01', 'SQL'),
(101, 'Second post', 'PostgreSQL is awesome!', now(), 'PostgreSQL');
"

user=# select * from posts;
 id  |    title    |        content         |        published_at        |    type
-----+-------------+------------------------+----------------------------+------------
 100 | New Post    | Epic SQL Content       | 2018-01-01 00:00:00        | SQL
 101 | Second post | PostgreSQL is awesome! | 2020-07-08 20:49:21.634533 | PostgreSQL
(2 rows)

```

### PX-Backup Rules

Pre
```
PGPASSWORD=$POSTGRES_PASSWORD; psql -U "$POSTGRES_USER" -c "CHECKPOINT";'
```

Post
```
None
```
