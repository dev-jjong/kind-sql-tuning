--1. SQL 처리 과정과 I/O
--1.1 SQL 파싱과 최적화
/* 1.1.1 구조적, 집합적, 선언적 질의 언어
    SQL = Sructured Query Language = 구조적 질의 언어
    SQL은 기본적으로 구조적(structured)이고 집합적(set-based)이고 선언적(declarative)인 질의 언어이다.
    절자적인 프로시저를 만들어 내는 DBMS 내부엔진 = 옵티마이저
*/

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



/*
    1.1.2 SQL 최적화
        [1] SQL 파싱
            - 파싱 트리 생성 : SQL 문을 이루는 개별 구성요소를 분석해서 파싱 트리 생성
            - Syntax 체크 : 문법적 오류가 없는지 확인
            - Semantic 체크 : 의미상 오류가 없는지 확인

        [2] SQL 최적화
            SQL 옵티마이저는 미리 수집한 시스템 및 오브젝트 통계정보를 바탕으로 다양한 실행경로를 생성해서 비교한 후 가장 효율적인 하나를 선택한다.

        [3] 로우 소스 생성
            SQL 옵티마이저가 선택한 실행경로를 실제 실행 가능한 코드 또는 프로시저 형태로 포맷팅 하는 단계



    1.1.3 SQL 옵티마이저
        [1] SQL 옵티마이저란?
            사용자가 원하는 작업을 가장 효율적으로 수행할 수 있는 최적의 데이터 엑세스 경로를 선택해주는 DBMS의 핵심 엔진

        [2] 옵티마이저 최적화 단계
            - 사용자로부터 전달받은 쿼리를 수행하는 데 후보군이 될만한 실행계획들을 찾아낸다.
            - 데이터 딕셔너리(Data Dictinary)에 미리 수집해 둔 오브젝트 통계 및 시스템 통계정보를 이용해 각 실행계획의 예상비용을 산정
            - 최저 비용을 나타내는 실행계획을 선택


    1.1.4 실행계획과 비용
        [1] 실행계획이란?
            - SQL 실행경로 미리보기
            - SQL 옵티마이저가 생성한 처리절차를 사용자가 확인할 수 있게 트리 구조로 표현한 것

*/

create table t as
select d.no, e.*
from emp e, (select rownum no from dual connect by level <= 1000) d;
select count(*) from t;
create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);

-- cost = 2
select * from t
where deptno = 10
and no = 1;

-- cost = 3
select /*+ index(t t_x02) */ * from t
where deptno = 10
and no = 1;

-- cost = 19
select /*+ full(t) */ * from t
where deptno = 10
and no = 1;

-- cost(비용)이란 쿼리를 수행하는 동안 발생할 것으로 예상되는 I/O 횟수 또는 예상 소요시간을 표헌한 값






