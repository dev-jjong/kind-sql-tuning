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
        [1] DB 버커캐시
            - 데이터 캐시
            - 디스크에서 어렵게 읽은 데이터 블록을 캐싱해 둠으로써 같은 블록에 대한 반복적인 I/O Call을 줄이는 데 목적
            - SQL을 수행하는 과정에 계속해서 데이터 블록을 읽는데, 자주 읽는 블록을 매번 디스크에서 읽는 것은 매우 비효율적이기 때문에 데이터 캐싱 메커니즘이 필수이다.
        
        [2] 논리적 I/O
            - SQL문을 처리하는 과정에 메모리 버퍼캐시에서 발생한 총 블록 I/O를 의미
            - 일반적으로 메모리 I/O 라고도 한다
            - 메모리 I/O는 전기 신호라서 빠르다
            * Direct path Read 방식으로 읽는 경우를 제외하면 모든 블록은 DB 버퍼캐시를 경유해서 읽는다. 따라서 논리적 I/O 횟수는 DB버커캐피에서 블록을 읽은 횟수와 일치한다.
            
        [3] 물리적 I/O
            - 디스크에서 발생한 총 블록 I/O를 의미
            - 디스크 I/O라고도 한다.
            - 디스크 I/O는 액세스 암(Arm)을 통해 물리적 작용이 일어나므로 메모리I/O에 비해 상당히 느리다. 보통 10,000배쯤 느리다. 경합이 심할때는 더 느리다.
            * SQL 처리 도중 읽어야 할 블록을 버퍼캐시에서 찾지 못할 때만 디스크를 액세스하므로 논리적 I/O중 일부를 물리적으로 I/O한다
            
        [4] 버퍼캐시 히트율 (Buffer Cache Hit Ratio)
            - 읽은 전체 블록 중에서 물리적인 디스크 I/O를 수반하지 않고 곧바로 메모리에서 찾은 비율
            - BCHR = (캐시에서 곧바로 찾은 블록 수 / 총 읽은 블록 수) X 100
                   = ( ( 논리적 I/O - 물리적 I/O) / 논리적 I/O) X 100
                   = ( 1 - (물리적 I/O) / (논리적 I/O) )  X 100
        
        [5] 논리적 I/O를 줄임으로써 물리적 I/O를 줄이는 것이 곧 SQL 튜닝이다.
        
    1.3.6 Single Block I/O vs MultiBlock I/O
        [1] 캐시에서 찾지 못한 데이터 블록은 I/O Call을 통해 디스크에서 DB버퍼캐시로 적재하고서 읽는다
        
        [2] Single Block I/O
            - 한 번에 한 블록씩 요청해서 메모리에 적재하는 방식
            - 인덱스를 이용할 때는 기본적으로 인덱스와 테이블 블록 모두 Single Block I/O 방식을 사용한다.
            
        [3] MultiBlock I/O
            - 한 번에 여러 블록씩 요청해서 메모리에 적재하는 방식
            - 인덱스를 이용하지 않고 테이블 전체를 스캔할 때 사용한다.
            - 테이블이 클수록 Multiblock I/O 단위도 크면 좋다.
            - 캐시에서 찾지 못한 특정 블록을 읽으려고 I/O Call 할 때 디스크 상에 그 블록과 인접한 블록들을 한꺼번에 읽어 캐시에 미리 적재한다.
            * 인접한 블록이란 같은 익스텐트에 속한 블록을 의미한다. (즉 익스텐트 경계를 넘지못한다.)
            
            
    1.3.7 Table Full Scan vs Index Range Scan
        [1] Table Full Scan
            - 테이블 전체를 스캔해서 읽는 방식
            - 시퀀셜 엑세스와 Multiblock I/O 방식으로 디스크를 읽는다.
            * 주의: 수십~수백 건의 소량 데이터 찾을 때 수백만~수천만 건 데이터를 스캔하는 건 비효율적이다.
        
        [2] Index Range Scan
            - 인덱스를 이용해서 읽는 방식
            - ROWID를 이용해 테이블 레코드로 찾아간다.
            - 랜덤 엑세스와 Single Block I/O 방식으로 디스크 블록을 읽는다.
            * 주의: 많은 데이터를 읽을 때 Table Full Scan 보다 불리하다.
            
            
    1.3.8 캐시 탐색 메커니즘
        [1] Direct Path I/O를 제외한 모든 블록 I/O는 메모리 버퍼캐시를 경유한다.
        
        [2] 메모리 공유자원에 대한 엑세스 직렬화
            - 자원을 공유하는 것처럼 보여도 내부에선 한 프로세스씩 순차적으로 접근하도록 구현해야 하며, 이를 위해 직렬화(serialization) 메커니즘이 필요하다
            
        [3] 래치(Latch)
            - 같이 사용하는 것처럼 보이지만, 특정 순강에는 한 프로세스만 사용할 수 있다. 이런 줄서기가 가능하도록 하지원하는 매커니즘이다.
            
        [4] 캐시버퍼 체인 래치
            - 해시 체인을 스캔하는 동안 다른 프로세스가 체인 구조를 변경하는 일이 생기면 안되기 때문에 존재한다.
            
        [5] SGA를 구성하는 서브 캐시하다 별도의 래치가 존재한다.
        
        [6] 버퍼 Lock
            - 캐시버퍼 체인 패치를 해제하기 전에 버퍼 헤더에 Lock을 설정함으로써 버퍼블록 자체에 대한 직렬화 문제를 해결
            
        [7]  직렬화 메커니즘에 의한 캐시 경합을 줄이려면, SQL 튜닝을 통해 쿼리 일량(논리적I/O) 자체를 줄여야 한다.

*/






