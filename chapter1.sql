--1.1.1 구조적, 집합적, 선언적 질의 언어
create table DEPT(DEPTNO number primary key, DNAME varchar2(50) not null, LOC varchar2(50));
insert into DEPT values(10, 'ACCOUNTING', 'NEW YORK');
insert into DEPT values(20, 'RESEARCH', 'DALLAS');
insert into DEPT values(30, 'SALES', 'CHICAGO');
insert into DEPT values(40, 'OPERATIONS', 'BOSTON');
commit;
select * from DEPT;


create table EMP(EMPNO number primary key, ENAME varchar2(20) not null, JOB varchar2(30), DEPTNO number, 
    CONSTRAINT FK_DEPTNO FOREIGN KEY(DEPTNO) REFERENCES DEPT(DEPTNO));
insert into EMP values(7369, 'SMITH', 'CLERK', 20);
commit;
select * from EMP;


--1.1.4 실행계획과 비용
create table t
as
select d.no, e.*
from scott.emp
;


select * from scott.emp;