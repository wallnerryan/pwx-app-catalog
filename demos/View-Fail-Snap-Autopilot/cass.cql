CREATE KEYSPACE newkeyspace WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 3};

USE newkeyspace;

CREATE TABLE emp(
  emp_id int PRIMARY KEY,
  emp_name text,
  emp_city text,
  emp_sal varint,
  emp_phone varint
  );

INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(1,'Jim', 'Salt Lake', 9848022338, 50000);

INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(2,'Joe', 'Detriot', 9846022338, 60000);
    
INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(3,'Jane', 'Seattle', 9846022338, 90000);
    
INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(4,'Mary', 'Seattle', 9877840098, 100000);

INSERT INTO emp (emp_id, emp_name, emp_city,
    emp_phone, emp_sal) VALUES(4,'Sarah', 'Boston', 2549880091, 76000);

SELECT * FROM emp;