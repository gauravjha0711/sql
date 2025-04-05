CREATE DATABASE temp1;
DROP DATABASE temp1;
create database temp2;
DROP DATABASE temp2;

CREATE DATABASE college;
USE college;

CREATE TABLE student(
	id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT NOT NULL
);

INSERT INTO student VALUES(1,"Gaurav jha",20);
INSERT INTO student VALUES(2,"Ashish Jha",19);
INSERT INTO student VALUES(3,"Roushan Singh",18);

SELECT * FROM student;