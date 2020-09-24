--3 인덱스 튜닝
--3.1 테이블 액세스 최소화
-- 핵심내용 : SQL 튜닝은 랜덤 I/O와의 전쟁이다.

/*
    3.1.1 테이블 랜덤 액세스
        [1] 인덱스 튜닝의 2가지 사실
            - 아무리 데이터가 많아도 인덱스를 사용하니까 데이터가 근방 조회된다는 사실
            - 대량 데이터를 조회할 때 인덱스를 사용하니 테이블 전체를 스캔할 때보다 훨씬 느리다는 사실
            
        [2] 인덱스 ROWID는 물리적주소? 논리적주소?
            - SQL이 참조하는 컬럼을 인덱스가 모두 포함하는 경우가 아니라면, 인덱스를 스캔한 후에 반드시 테이블을 액세스한다.
                (실행계획에 TABLE ACCESS BY INDEX ROWID 라고 표시된다)
            - 인덱스를 스캔하는 이유는 검색 조건을 만족하는 소량을 데이터를 인덱스에서 빨리 찾고 거기서 테이블 레코드를 찾아가기 위한
                주소값(ROWID)를 얻으려는 데 있다.
            - 인덱스 ROWID는 논리적 주소다. 디스크 상에서 테이블 레코드를 찾아가기 위한 위치 정보를 담는다.
            
        [3] 메인 메모리 DB와 비교
            - 메인 메모리 DB(MMDB)란? 
                데이터를 모두 메모리에 로드해 놓고 메모리를 통해서만 I/O를 수행하는 DB
            - 반면 오라클은 테이블 블록이 수시로 버퍼캐시에 밀려났다가 다시 캐핑되며, 그때마다 다른 공간에 캐싱되기 때문에 인덱스에서
                포인터로 직접 연결할 수 없는 구조이다.
            - 즉, 메모리 주소 정보(포인터)가 아닌 디스크 주소 정보(DBA)를 이용해 해시 알고리즘으로 버퍼 블록을 찾아간다
            
        [4] I/O매커니즘 복습
            - 인덱스로 테이블 블록을 액세스할 때는 리프 블록에서 읽은 ROWID를 분해해서 DBA 정보를 얻고, 테이블을 Full Scan 할 때는
                익스텐트 맵을 통해 읽을 블록들의 DBA 정보를 얻는다.
            - ROWID가 가리키는 테이블 블록을 버퍼캐시에서 먼저 찾아보고, 못 찾을 때만 디스크에서 블록을 읽는다.
                물론 버퍼캐피에 적재한 후에 읽는다.
            - 설령 모든 데이터가 캐싱돼 있더라도 테이블 레코드를 찾기 위해 매번 DBA해싱과 래치 획득 과정을 반복해야 한다.
                동시 액세스가 심할때는 캐시버퍼 체인 래치와 버퍼 Lock에 대한 경합까지 발생한다.
                즉, 인덱스 ROWID를 이용한 테이블 액세스는 생각보다 고비용 구조이다
            
        [5] 인덱스 ROWID는 우편주소
            - 디스크 DB가 사용하는 ROWID를 우편주소에, 메인 메모리 DB가 사용하는 포인터를 전화번호에 비유할 수 있다.
                전화통신은 물리적으로 연결된 통신망을 이용하므로 곧바로 상대방과 통화할 수 있다.
                반면, 우편번호는 봉투에 적힌 대로 우체부 아저씨가 일일이 찾아다니는 구조라고 생각하면 된다.
                

    3.1.2 인덱스 클러스터링 팩터 (CF)
        - 특정 컬럼을 기준으로 같은 값을 갖는 데이터가 서로 모여있는 정도
        - 군집성 계수도 한다.
        - CF가 좋은 컬럼에 생성한 인덱스를 검색 효율이 좋다고 헀는데, 이는 테이블 액세스량에 비해 블록 I/O가 적게 발생함을 의미한다.
        - CF가 좋으면 버퍼 Pinning으로 인해 래치 획득과 해시 체인 스캔 과정을 생략하고 바로 테이블을 읽기 때문에 빠르다.
        - 버퍼 Pinning이란? 
            인덱스 ROWID로 테이블을 액세스할 때, 오라클은 래치 획득과 해시 체인 스캔 과정을 거쳐 어렵게 찾아간 테이블 블록에 대한 
            포인터(메모리 주소값)를 바로 해제하지 않고 일단 유지하는 것
        - CF가 안 좋은 인덱스를 사용하면 테이블을 액세스하는 횟수만큼 고스란히 블록 I/O가 발생한다.
        
    3.1.3 인덱스 손익분기점
        [1] 인덱스 손익분기점이란?
            - Index Range Scan에 의한 테이블 액세스가 Table Full Scan보다 느려지는 지점
            - 인덱스를 이용해 테이블을 액세스할 때는 전체 1,000만건 중 몇 건을 추출하느냐에 따라 성능이 크게 달라진다
        
        [2] 인덱스를 이용한 테이블 엑세스가 Table Full Scan 보다 더 느려지는 이유
            - Table Full Scan은 시퀀셜 액세스인 반면, 인덱스 ROWID를 이용한 테이블 액세스는 랜덤 액세스 방식이다
            - Table Full Scan은 Multiblock I/O인 반면, 인덱스 ROWID를 이용한 테이블 액세스는 Single Block I/O 방식이다
            
        [3] 온라인 프로그램 튜닝 vs 배치 프로그램 튜닝
            - 온라인 프로그램은 보통 소량 데이터를 읽고 갱신하므로 인덱스를 효과적으로 활용하는 것이 중요하다. (NL조인을 사용한다)
            - 대량 데이터를 읽고 갱신하는 배치(Batch) 프로그램은 항상 전체범위 처리 기준으로 튜닝해야한다. 즉, 처리대상 집합 중 일부를 빠르게 하는게 아니라
                전체를 빠르게 처리하는 것을 목표로 삼아야 한다 (Full Scan과 해시 조인이 유리하다)

*/

-- 테스트 데이터 만들기 (아래 예제는 실행하지 말자.. 그냥 참고로만 끄적거려봄)
CREATE TABLE t1 
AS
SELECT * FROM all_objects;
CREATE INDEX t1_idx on t1(object_name);

CREATE TABLE t2 
AS
SELECT * FROM all_objects;
CREATE INDEX t2_idx on t2(object_name);

SELECT * FROM t1;
SELECT * FROM t2;

set autotrace on explain;

SELECT A.OBJECT_NAME, A.SUBOBJECT_NAME, A.OBJECT_ID, A.OBJECT_TYPE, A.DATA_OBJECT_ID, B.STATUS
FROM t1 A, t2 B
WHERE A.OBJECT_TYPE = 'TABLE'
AND B.OBJECT_NAME = A.OBJECT_NAME;
/*---------------------------------------------------------------------------------------
| Id  | Operation                    | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |        |     7 |   651 |     5   (0)| 00:00:01 |
|*  1 |  HASH JOIN                   |        |     7 |   651 |     5   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| T2     |     2 |    44 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | T2_IDX |     2 |       |     1   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| T1     |     3 |   213 |     3   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN          | T1_IDX |     3 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------*/

create index t1_idx_02 on t1(object_type);
create index t2_idx_02 on t2(object_type);
SELECT A.OBJECT_NAME, A.SUBOBJECT_NAME, A.OBJECT_ID, A.OBJECT_TYPE, A.DATA_OBJECT_ID, B.STATUS
FROM t1 A, t2 B
WHERE A.OBJECT_TYPE = 'TABLE'
AND B.OBJECT_NAME = A.OBJECT_NAME;
/*---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |  3089 |   280K|   110   (0)| 00:00:02 |
|*  1 |  HASH JOIN         |      |  3089 |   280K|   110   (0)| 00:00:02 |
|*  2 |   TABLE ACCESS FULL| T1   |  1483 |   102K|    55   (0)| 00:00:01 |
|   3 |   TABLE ACCESS FULL| T2   | 16456 |   353K|    55   (0)| 00:00:01 |
---------------------------------------------------------------------------*/


/*
        [4] 파티션 활용 전략이 중요한 이유
            - 대량 배치 프로그램에선 익엑스보다 Full Scan이 효과적이지만, 초대용량 테이블을 Full Scan 하면 상당히
                오래 기다려야하고 시스템에 주는 부담도 크다. 그래서 파티션 활용 전략이 중요한거고 병렬처리까지 해주면 더 좋다.
            - 즉, 테이블 파티셔닝을 하는 이유는 결국 Full Scan을 빠르게 처리하기 위해서 이다.
            
    
    3.1.4 인덱스 컬럼 추가
        [1] 테이블 액세스 최소화를 위해 가장 일반적으로 사용하는 튜닝 기법은 인덱스에 컬럼을 추가하는 것이다.
          

*/

-- EMP테이블의 안쓰는 인덱스 삭제
drop index E_X01;
drop index E_X02;
drop index EMP_X02;
drop index EMP_DEPTNO_NO;
drop index EMP_ENAME_SAL_IDX;

-- 아래 인덱스 생성
create index EMP_X01 on EMP(DEPTNO, JOB);

select /*+ index(emp emp_x01) */* 
from emp
where deptno = 30
and sal >= 2000;
/*---------------------------------------------------------------------------------------
| Id  | Operation                   | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |         |     4 |    96 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP     |     4 |    96 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | EMP_X01 |     6 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------*/


/*
        [2] 위의 예제에서 인덱스를 새로 만들어야겠지만 이런 식으로 인덱스를 추가하다 보면 테이블마다 인덱스가 수십 개씩 달려 배보다
            배꼽이 더 커지게 된다. 인덱스 관리 비용이 증가함은 물론 DML 부하에 따른 트랜잭션 성능 저하가 생길 수 있다.
            ※ 이럴 때, 기존 인덱스에 SAL 컬럼을 추가하는 것만으로 큰 효과를 얻을 수 있다. 
            (인덱스 스캔량은 줄지 않지만, 테이블 랜덤 액세스 횟수를 줄여주기 때문)
*/

alter session set sql_trace = true;
select * from emp where empno = 7900;
select * from dual;
alter session set sql_trace = false;


select value from v$diag_info where name = 'Diag Trace';  -- /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace
select value from v$diag_info where name = 'Default Trace File';  -- /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_ora_19199.trc

/*
        [3] 인덱스 클러스터링 팩터 효과 확인
            - 클러스터링 팩터가 좋은 인덱스를 이용하면, 테이블 액세스량에 비해 블록 I/O가 훨씬 적게 발생한다.



    3.1.5 인덱스만 읽고 처리
        [1] Covered 쿼리, Covered 인덱스란?
            테이블 랜덤 액세스가 아무리 많아도 필터 조건에 의해 버려지는 레코드가 거의 없다면 거기에 비효율은 없다.
            이럴 때는 쿼리에 사용된 컬럼을 모두 인덱스에 추가해서 테이블 액세스가 아예 발생하지 않게 하는 방법을 고려해볼 수있다.
            이렇게 인덱스만 읽어서 처리하는 쿼리를 'Covered 쿼리'라고 한다.
            그 쿼리에 사용한 인덱스를 'Covered 인덱스'라고 한다.
        
        [2] Covered 인덱스 단점
            - 추가해야 할 컬럼이 많아지면 실제 적용하기 곤란하다
            
        [3] Include 인덱스
            - SQL Server용으로 인덱스 키 외에 미리 지정한 컬럼을 리프 레벨에 함께 저장하는 기능이다.
            - 인덱스를 생성할 때 include 옵션을 지정하면 된다.
                create index emp_x01 on emp(deptno) include (sal)
            - include 인덱스는 순전히 테이블 랜덤 액세스를 줄이는 용도로 개발되었다. (소트생략 불가)
            
            
    3.1.6 인덱스 구조 테이블
        [1] IOT(Index-Organized Table)
            - 랜덤 액세스가 아예 발생하지 않도록 테이블을 인덱스 구조로 생성한 것
            - 테이블을 찾아가기 위한 ROWID를 갖는 일반 인덱스와 달리 IOT는 그 자리에 테이블 데이터를 갖는다.
                즉, 테이블 블록에 있어야 할 데이터를 인덱스 리프 블록에 모두 저장하고 있다.
            - IOT는 인덱스 구조 테이블이므로 정렬 상태를 유지하며 데이터를 입력한다.
            - MS-SQL Server에서는 클러스터형(Clustered) 인덱스라고 부른다
          
        [2] 사용법
            create table index_org_t (a number, b varchar2(10), constraint index_org_t_pk primary key (a) )
            organization index ; 
            
        [3] IOT 장점
            - IOT는 인위적으로 클러스터링 팩터를 좋게 만드는 방법중 하나이다.
            - 같은 값을 가진 레코드들이 100% 정렬된 상태로 모여 있으므로 랜덤 액세스가 아닌 시퀀셜 방식으로 데이터를 액세스한다.
            - BETWEEN이나 부등호 조건으로 넓은 범위를 읽을 때 유리하다
            
    3.1.7 클러스터 테이블
        [1] 인덱스 클러스터 테이블
            - 클러스터 키(ex/ deptno) 값이 같은 레코드를 한 블록에 모아서 저장하는 구조이다.
                한 블록에 모두 담을 수 없을 때는 새로운블록을 할당해서 '클러스터 체인'으로 연결한다.
            - 여러 테이블 레코드를 같은 블록에 저장할 수도 있는데, 이를 '다중 테이블 클러스터'라고 부른다.
            - 오라클 클러스터는 키 같이 같은 데이터를 같은 공간에 저장해 둘 뿐, 정렬하지 않는다.
            ※ 클러스터에 도달해서는 시퀀셜 방식으로 스캔하기 때문에 넓은 범위를 읽더라도 비효율이 없다는게 핵심 원리이다.
            
            
            - 사용법 : 아래참조

*/
-- 클러스터 생성
create cluster c_dept# (deptno number(2) ) index;

-- 클러스터에 테이블을 담기전에 꼭 '클러스터 인덱스'를 반드시 정의해야 한다.
-- 클러스터 인덱스는 데이터 검색 용도로 사용할 뿐아니라 데이터가 저장될때 위치를 찾을 때도 사용하기 때문이다.
create index c_dept#_idx on cluster c_dept#;

-- 클러스터 테이블 생성
create table dept2 (
    deptno number(2) not null
    , dname varchar2(14) not null
    , loc varchar2(13) )
cluster c_dept#(deptno);


select * from dept2 where deptno = 1;
/*------------------------------------------------------------------------------------
| Id  | Operation            | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |             |     1 |    30 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS CLUSTER| DEPT2       |     1 |    30 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN  | C_DEPT#_IDX |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------*/


/*
        [2] 해시 클러스터 테이블
            - 해시 클러스터는 인덱스를 사용하지 않고 해시 알고리즘을 사용해 클러스를 찾아간다.
            - 사용법 : 아래 참조

*/

create cluster c_dept#2 (deptno number(2) ) hashkeys 4;
create table dept3 (
    deptno number(2) not null
    , dname varchar2(14) not null
    , loc varchar2(13) )
cluster c_dept#2(deptno);

select * from dept3 where deptno = 1;
/*----------------------------------------------------------------
| Id  | Operation         | Name  | Rows  | Bytes | Cost (%CPU)|
----------------------------------------------------------------
|   0 | SELECT STATEMENT  |       |     1 |    30 |     0   (0)|
|*  1 |  TABLE ACCESS HASH| DEPT3 |     1 |    30 |            |
----------------------------------------------------------------*/



