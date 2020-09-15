--1.1.1 구조적, 집합적, 선언적 질의 언어

-- 아래 2개의 테이블 생성, 테스트 데이터 insert
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
insert into EMP values(7499, 'ALLEN', 'SALESMAN', 30);
insert into EMP values(7521, 'WARD', 'SALESMAN', 30);
insert into EMP values(7566, 'JONES', 'MANAGER', 20);
insert into EMP values(7654, 'MARTIN', 'SALESMAN', 30);
insert into EMP values(7698, 'BLAKE', 'MANAGER', 30);
insert into EMP values(7782, 'CLARK', 'MANAGER', 10);
insert into EMP values(7788, 'SCOTT', 'ANALYST', 20);
insert into EMP values(7839, 'KING', 'PRESIDENT', 10);
insert into EMP values(7844, 'TURNER', 'SALESMAN', 30);
insert into EMP values(7876, 'ADAMS', 'CLERK', 20);
insert into EMP values(7900, 'JAMES', 'CLERK', 30);
insert into EMP values(7902, 'FORD', 'ANALYST', 20);
insert into EMP values(7934, 'MILLER', 'CLERK', 10);
commit;
select * from EMP;


create table t
as
select d.no, e.*
from scott.emp
;


select * from scott.emp;