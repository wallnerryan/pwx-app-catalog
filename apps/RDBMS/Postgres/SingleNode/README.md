# Single Instance Postgres Database with Portworx

```
kubectl create -f postgres-pwx.yaml
```

## Data

```
psql -c "create database test;"

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

```
