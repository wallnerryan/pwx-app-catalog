
#Adding data

```
create database family;

use family;

CREATE TABLE pet (name VARCHAR(20), owner VARCHAR(20),species VARCHAR(20), sex CHAR(1), birth DATE, death DATE);

INSERT INTO pet VALUES ('Roscoe','Beau','dog','m','2000-03-30',NULL);

select * from pet;
```
