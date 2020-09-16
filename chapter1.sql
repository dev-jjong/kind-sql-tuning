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

-- 실행계획 자동 추척을 켠다. 
set autotrace on explain;

-- 쿼리 블록을 선택 후 F5를 눌러야 실행계획이 오토 트레이스된다. 
select * from t
where deptno = 10
and no = 1;
/*-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |     3 |   204 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |     3 |   204 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_X01 |     5 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------*/


select /*+ index(t t_x02) */ * from t
where deptno = 10
and no = 1;
/*-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |     3 |   204 |     3   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |     3 |   204 |     3   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_X02 |     1 |       |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------*/


select /*+ full(t) */ * from t
where deptno = 10
and no = 1;
/*--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     3 |   204 |    19   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| T    |     3 |   204 |    19   (0)| 00:00:01 |
--------------------------------------------------------------------------*/

-- cost(비용)이란 쿼리를 수행하는 동안 발생할 것으로 예상되는 I/O 횟수 또는 예상 소요시간을 표헌한 값


/*
    1.1.5 옵티마이저 힌트
        [1] 힌트 사용법
            주석 기호에 +를 붙힌다.  / *+   * /
            --+ 도 가능은 하나 개행으로 인해 쿼리 오류가 발생할 수 있으니 사용하지 말자
            
        [2] 힌트 사용시 주의사항
            - 힌트 안에 인자를 나열할 땐 ,(콤마)를 사용할 수 있지만, 힌트와 힌트 사이에 사용하면 안된다.
            - 테이블명을 지정할 때 스키마명까지 명시하면 안된다.   ex)   FULL(SCOTT.EMP) -> 무효
            - FROM 절 테이블명에 ALIAS를 지정했다면, 힌트에도 반드시 ALIAS를 사용한다.
            - 기왕에 힌트를 쓸 거면, 빈틈없이 기술하자

*/


-- 1.2 SQL 공유 및 재사용
/*
    1.2.1 소프트 파싱 vs 하트 파싱
        [1] SGA(System Global Area)란?
            서버 프로세스와 백그라운드 프로세스가 공통으로 엑세스하는 데이터와 제어 구조를 캐싱하는 메모리 공간
        [2] 라이브러리 캐시(Library Cache)란?
            - SQL파싱, 최적화, 로우 소스 생성 과정을 거쳐 생성한 내부 프로시저를 반복 재사용할 수 있도록 캐싱해 두는 메모리 공간
            - SGA(System Global Area)의 구성요소중에 하나이다.
        [3] 소프트 파싱
            SQL을 캐시에서 곧바로 실행단계로 넘어가는 것
        [4] 하드 파싱
            - 찾는데 실패해 최적화 및 로우 소스 생성 단계까지 모두 거치는 것
            - 하드 파싱은 CPU를 많이 소비하는 작업
        [5] 옵티마이저가 사용하는 정보
            - 테이블, 컬럼, 인덱스 구조에 관련 기본 정보
            - 오브젝트 통계 : 테이블 통계, 인덱스 통계, (히스토그램을 포함한) 컬럼 통계
            - 시스템 통계 : CPU 속도, Single Block I/O 속도, Multiblock I/O 속도
            - 옵티마이저 관련 파라미터
        
    1.2.2 바인드 변수의 중요성
        [1] 이름없는 SQL 문제
            - SQL은 이름이 따로 없다. SQL 자체가 이름이기 때문에 텍스트중 작은 부분이라도 수정되면 그 순간 다른 객체가 새로 탄생하는 구조
            - 바인드 변수가 없으면 계속해서 하드 파싱이 일어난다
        [2] 바인드 변수란
            - 파라미터 Driven 방식으로 SQL을 작성하는 방법
            - 바인드 변수를 사용하면 SQL에 대한 하드파싱은 최초 한 번만 일어나고, 캐싱된 SQL을 재사용한다.
*/


-- 1.3 데이터 저장 구조 및 I/O 매커니즘
/*
    1.3.1 SQL이 느린 이유
        [1] I/O란?
            - I/O = 잠(SLEEP)
            - 프로세스가 일하지 않고 잠을 자는 이유는 I/O가 가장 대표적이고 절대 비중을 차지한다.
            - 디스크 I/O가 SQL 성능을 좌우한다.
        [2] 프로세스 생명주기
            - 생성(new) 이후 종료(terminated)전까지 준비(ready)와 실행(running)과 대기(waiting) 상태를 반복
            - 실행 중인 프로세서는 interrupt에 의해 수시로 실행 준비 상태(Runnable Queue)로 전환했다가 다시 실행 상태로 전환한다.
            - 여러 프로세스가 하나의 CPU를 공유할 수 있지만, 특정 순간에는 하나의 프로세스만 CPU를 사용할 수 있기 때문에 이런 매커니즘이 필요하다.
            
            
    1.3.2 데이터베이스 저장 구조
        [1] 블록
            - 데이터를 읽고 쓰는 단위
            - DB2, SQL Server에서는 블록 대신 페이지(page)라는 용어로 사용
            - 한 블록은 하나의 테이블이 독점한다. 즉, 한 블록에 저정된 레코드는 모두 같은 테이블 레코드이다.
            - DBA(Data Block Address)이란?
                * 모든 데이터 블록이 디스크 상에서 몇 번 데이터파일의 몇 번째 블록인지를 나타내는 자신만의 고유한 값을 같는 것
                * 인덱스를 이용해 테이블 레코드를 읽을 때는 인덱스 ROWID를 이용한다. ROWID는 DBA+로우 번호(블록 내 순번)으로 구성된다.
        [2] 익스텐트
            - 공간을 확장하는 단위, 연속된 블록의 집합
            - 한 익스텐드는 하나의 테이블이 독점한다. 즉, 한 익스텐드에 담긴 블록은 모두 같은 테이블 블록이다.
        [3] 세그먼트
            - 데이터 저장공간이 필요한 오브젝트(테이블, 인덱스, 파티션, LOB 등.)
        [4] 테이블스페이스
            - 세그먼트를 담는 콘테이너
        [5] 데이터 파일
            - 디스크 상의 물리적인 OS 파일
            - 하나의 테이블스페이스를 여러 데이터파일로 구성하면, 파일 경합을 줄이기 위해 DBMS가 데이터를 가능한 한 여러 데이터파일로 분산해서 저장한다
            
            
    1.3.3 블록 단위 I/O
        - 블록은 DBMS가 데이터를 읽고 쓰는 단위
        - 데이터 I/O 단위가 블록이므로 특정 레코드 하나를 읽고 싶어도 해당 블록을 통째로 읽는다.
        
    1.3.4 시퀀셜 엑섹스 vs 램덤 엑세스
        [1] 시퀸셜 엑세스
            - 논리적 물리적으로 연결된 순서에 따라 차례대로 블록을 읽는 방식
            - 멀티 I/O 가능 (빠르다)
        [2] 랜덤 엑세스
            - 논리적, 물리적인 순서를 따르지 않고, 레코드 하나를 읽기 위해 한 블록씩 접근(=touch)하는 방식
            - 싱글 I/O만 가능(느리다)
            
    1.3.5 논리적 I/O vs 물리적 I/O
    
            

*/






