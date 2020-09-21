--2 인덱스 기본
--2.1 인덱스 구조 및 탐색
-- 핵심내용 : 인덱스 탐색 과정은 수직적 탐색과 수평적 탐색, 두 단계로 이루어진다.

/* 
    2.1.1 미리 보는 인덱스 튜닝
        [1] 데이터베이스 테이블에서 데이터를 찾는 2가지 방법
            a. 테이블 전체 스캔
            b. 인덱스 이용
            
        [2] 인덱스 튜닝의 두 가지 핵심 요소
            a. 인덱스 스캔 과정에서 발생하는 비효율을 줄이는 것. (인덱스 스캔 효율화 튜닝)
            b. 테이블 액세스 횟수를 줄이는 것. (랜덤 액세스 최소화 튜닝)
            - 온라인 트랜젝션 처리(OLTP) 시스템에서는 소량 데이터를 주로 검색하므로 인덱스 튜닝이 중요하다.
            - 인덱스 스캔 효율화 튜닝과 랜덤 액세스 최소화 튜닝중에 더 중요한 것은 "랜덤 액세스 최소화 튜닝"이다.
            
        [3] SQL 튜닝은 랜덤 I/O와의 전쟁
            - 데이터베이스 성능이 느린 이유는 디스크 I/O 때문이다.
            - 인덱스를 많이 사용하는 OLTP 시스템이라면 디스크I/O 중에서도 랜덤 I/O가 특히 중요하다.
            - IOT, 클러스터, 파티션, 테이블 Prefetch, Batch I/O 등. 모두 랜덤 I/O를 줄이는데 목적이 있다.
            - NL조인이 대량 데이터 조인할 때 느린 이유도 랜덤 I/O 때문이다  -> 그래서 소트머지 조인, 해시 조인이 나옴
            
        
    2.1.2 인덱스 구조
        [1] 인덱스 란?
            - 대용량 테이블에서 필요한 데이터만 빠르게 효율적으로 엑세스하기 위해 사용하는 오브젝트
            - 데이터베이스에서도 인덱스 없이 데이터를 검색하려면, 테이블을 처음부터 끝까지 모두 읽어야 가능하다.
            - 범위 스캔이 가능한 이유는 인덱스가 정렬되어 있기 때문이다.
            
        [2] 인덱스 구조
            - 일반적으로 B*Tree 인덱스를 사용하는데 루트(Root), 브랜치(Branch), 리프(Leaf)로 나뉜다.
            - 루트와 브랜치 블록에 있는 각 레코드는 하위 블록에 대한 주소값을 같는다. 키값은 하위 블록에 저장된 키값을 범위이다.
            - LMC란?
                * 루트와 브랜치 블록에 키값을 갖지 않는 특별한 레코드
                * 자식 노드 중 가장 왼쪽 끝에 위치한 블록
            - 리프 블록에 저장된 각 레코드는 키값 순으로 정렬되어 있고, ROWID를 갖는다.
            - ROWID 란?
                * ROWID : 데이터 블록 주소 + 로우 번호
                * 데이터 블록 주소 : 데이터 파일 번호 + 블록 번호
                * 블록 번호 : 데이터파일 내에서 부여한 상대적 순번
                * 로구 번호 : 블록 내 순번
                
        [3] 인덱스 탐색 과정
            - 수직적 탐색 : 인덱스 스캔 시작지점을 찾는 과정
            - 수평적 탐색 : 데이터를 찾는 과정
            
    
    2.1.3 인덱스 수직적 탐색
        [1] 인덱스 수직적 탐색 이란?
            - 인덱스 스캔 시작지점을 찾는 과정
            - 조건을 만족하는 첫 번째 레코드를 찾는 과정이다
            - 루트(Root) 블록에서부터 시작한다.
            - 루트를 포함해 브랜치(Branch) 블록에 저장된 각 인덱스 레코드는 하위 블록에 대한 주소값을 갖는다.
            - 이동한 브랜치 블록에 찾고자 하는 값과 정확히 일치하는 레코드가 있어도 해당 레코드로 찾으면 안된다.
              바로 그 직전 레코드로 찾아가야한다. 
             
    2.1.4 인덱스 수평적 탐색 
        [1] 인덱스 수평적 탐색 이란?
            - 수직적 탐색을 통해 스캔 시작점을 찾았으면, 찾고자 하는 데이터가 더 안 나타날 때까지 인덱스 리프 블록을 수평적으로 스캔한다.
            - 인덱스에서 본격적으로 데이터를 찾는 과정
            - 인덱스 리프 블록끼리는 서로 앞뒤 블록에 대한주소값을 갖는다. (양방향 연결 리스트 구조)
            
        [2] 인덱스를 수평적으로 탐색하는 이유
            a. 조건절을 만족하는 데이터를 모두 찾기 위해서
            b. ROWID를 찾기 위해서
            
    2.1.5 결합 인덱스 구조와 탐색
        [1] 결합 인덱스 란?
            - 두 개 이상 컬럼을 결합해서 인덱스를 만들 수도 있다.
            - 인덱스를 [고객명+성별]으로 구성하든, [성별+고객명]으로 구성하든 읽는 인덱스 블록 개수는 같다.
            - 인덱스를 어떻게 구성하든 블록 I/O개수가 같으므로 성능도 같다.
        
        [2] B*Tree 인덱스
            - DBMS가 사용하는 B*Tree 인덱스는 엑셀처럼 평면 구조가 아니다. (다단계 구조이다)
            - Balancded는 어떤 값으로 탐색하더라도 인덱스 루트에서 리프 블록에 도달하기까지 읽는 블록 수가 같음을 의미한다.
            - 즉, 루트로부터 모든 리프 블록까지의 높이(Height)는 항상 같다.

*/

--2.2 인덱스 기본 사용 방법
-- 핵심내용 : 인덱스 기본 사용법은 인덱스를 Range Scan 하는 방법을 의미한다

/*
    2.2.1 인덱스를 사용한다는 것
        - 인덱스 컬럼을 가공해도 인덱스를 사용할 수는 있지만, 스캔 시작점을 찾을 수 없고 멈출 수도 없어 리프 블록 전체를 스캔해야만한다.
        
    2.2.2 인덱스를 Range Scan 할 수 없는 이유
        [1] 인덱스 컬럼을 가공했을 때 인덱스를 정상적으로 사용할 수 없는 이유는 인덱스 스캔 시작점을 찾을 수 없기 때문이다.
        
        [2] 인덱스를 사용할 수 없는 CASE
            - where substr(생년월일, 5, 2) = '05'
            - where nvl(주문수량, 0) < 100
            - where 업체명 like '%대한%'
            - where (전화번호 = :tel_no or 고객명 = :cust_nm)
            - where 전화번호 in (:tel_no1, :tel_no2)
            
        [3] OR Expansion 이란?
            - OR 조건식을 SQL 옵티마이저가 아래 형태로 변환하는 걸 말한다.
            - 아래 예제를 보자
                
*/
set autotrace on explain;

create index e_x01 on emp(ename);
create index e_x02 on emp(job);

-- or 조건이라 index를 사용할 수 없어서 table full scan이 일어난다
select *
from emp
where (ename = 'ALLEN' or job = 'PRESIDENT');
/*--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     4 |    84 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     4 |    84 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------*/


-- OR Expansion 방법1. union all
select *
from emp
where ename = 'ALLEN'
union all
select *
from emp
where job = 'PRESIDENT'
and (ename <> 'ALLEN' or ename is null);
/*--------------------------------------------------------------------------------------
| Id  | Operation                    | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |       |     4 |    84 |     4   (0)| 00:00:01 |
|   1 |  UNION-ALL                   |       |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| EMP   |     1 |    21 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | E_X01 |     1 |       |     1   (0)| 00:00:01 |
|*  4 |   TABLE ACCESS BY INDEX ROWID| EMP   |     3 |    63 |     2   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN          | E_X02 |     3 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------*/


-- OR Expansion 방법2. use_concat 힌트를 줘서 위의 방법1을 유도한다.
select /*+ use_concat */ *
from emp
where (ename = 'ALLEN' or job = 'PRESIDENT');
/*--------------------------------------------------------------------------------------
| Id  | Operation                    | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |       |     4 |    84 |     4   (0)| 00:00:01 |
|   1 |  CONCATENATION               |       |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| EMP   |     1 |    21 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | E_X01 |     1 |       |     1   (0)| 00:00:01 |
|*  4 |   TABLE ACCESS BY INDEX ROWID| EMP   |     3 |    63 |     2   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN          | E_X02 |     3 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------*/



/*
    2.2.2 인덱스를 Range Scan 할 수 없는 이유 (이어서...)
        [4] In-List Iterator 방식
            - In-List 개수 만큼 index Range Scan을 반복하는 것이다.
            - 아래 예제를 보자
*/

-- 이름이 ALLDN 이거나 KING 인사람 찾기시 INLIST ITERATOR가 동작한다.
select *
from emp
where ename in ('ALLEN', 'KING');
/*--------------------------------------------------------------------------------------
| Id  | Operation                    | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |       |     2 |    42 |     2   (0)| 00:00:01 |
|   1 |  INLIST ITERATOR             |       |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| EMP   |     2 |    42 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | E_X01 |     2 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------*/



/*
    2.2.3 더 중요한 인덱스 조건
        - 인덱스 선두 컬럼이 가공되지 않은 상태로 조건절에 있으면 인덱스 Range Scan은 무조건 가능하다.
            하지만 인덱스를 Range Scan 한다고해서 항상 성능이 좋은 건 아니라는 사실이다.
        - 인덱스를 정말 잘 타는지는 인덱스 리프 블록에서 스캔하는 양을 따져봐야 알 수 있다.
        
    2.2.4 인덱스를 이용한 소트 연산 생략
        - 인덱스가 정렬돼 있기 때문에 Range Scan이 가능하고, 소트 연산 생략 효과도 부수적으로 얻게 된다.

*/

create table 상태변경이력(장비번호 varchar2(1), 변경일자 varchar2(8), 변경순번 number);
insert into 상태변경이력 values('A', '20180404', 000001);
insert into 상태변경이력 values('A', '20180405', 000001);
insert into 상태변경이력 values('A', '20180406', 000001);
insert into 상태변경이력 values('A', '20180407', 000001);
insert into 상태변경이력 values('A', '20180407', 000002);
insert into 상태변경이력 values('A', '20180407', 000003);
insert into 상태변경이력 values('B', '20180505', 031583);
insert into 상태변경이력 values('C', '20180316', 000001);
insert into 상태변경이력 values('C', '20180316', 000002);
insert into 상태변경이력 values('C', '20180316', 000003);
insert into 상태변경이력 values('C', '20180316', 002223);
insert into 상태변경이력 values('C', '20180316', 003333);
insert into 상태변경이력 values('C', '20180428', 000001);
insert into 상태변경이력 values('C', '20180428', 000002);
commit;

create index 상태변경이력_PK on 상태변경이력(장비번호, 변경일자, 변경순번);

-- 생성된 인덱스 덕분에 order by가 있지만 소트 연산이 생략되었다.
select * 
from 상태변경이력
where 장비번호 ='C'
and 변경일자 ='20180316'
order by 변경순번;
/*------------------------------------------------------------------------------
| Id  | Operation        | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |           |     5 |   105 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| 상태변경이|     5 |   105 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------*/


drop index 상태변경이력_PK;

-- 인덱스를 삭제해보고 다시 쿼리 call 하니 SORT ORDER BY 연산이 생긴걸 볼수있다.
select * 
from 상태변경이력
where 장비번호 ='C'
and 변경일자 ='20180316'
order by 변경순번;
/*-----------------------------------------------------------------------------
| Id  | Operation          | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |        |     5 |   105 |     4  (25)| 00:00:01 |
|   1 |  SORT ORDER BY     |        |     5 |   105 |     4  (25)| 00:00:01 |
|*  2 |   TABLE ACCESS FULL| 상태변 |     5 |   105 |     3   (0)| 00:00:01 |
-----------------------------------------------------------------------------*/

create index 상태변경이력_PK on 상태변경이력(장비번호, 변경일자, 변경순번);

-- 다시 인덱스 생성하고 변경순번으로 DESC를 해보자
select * 
from 상태변경이력
where 장비번호 ='C'
and 변경일자 ='20180316'
order by 변경순번 DESC;
/*-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           |     5 |   105 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN DESCENDING| 상태변경이|     5 |   105 |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------*/


/*
    2.2.5 ORDER BY 절에서 컬럼 가공
        - 조건절이 아닌 ORDER BY 또는 SELECT-LIST에서 컬럼을 가공함으로 인해 인덱스를 정상적으로 사용할 수 없는 경우도 있다.

*/

-- order by 절을 가공했기 때문에 sort by 연산이 일어났다
-- 인덱스에는 가공하지 않은 상태로 값을 저장했는데, 가공한 값 기준으로 정렬해 달라고 요청했기 때문에 소트 연산이 일어남
select * 
from 상태변경이력
where 장비번호 ='C'
order by 변경일자 || 변경순번;
/*-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     7 |   147 |     2  (50)| 00:00:01 |
|   1 |  SORT ORDER BY    |           |     7 |   147 |     2  (50)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN| 상태변경이|     7 |   147 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------*/



-- 재밋는 튜닝 사례
create table 주문(주문번호 number, 업체번호 number, 주문금액 number, 주문일자 varchar2(8));
insert into 주문 values(1, 1,100000, '20200921');
insert into 주문 values(2, 2,200000, '20200921');
insert into 주문 values(3, 3,300000, '20200921');
insert into 주문 values(4, 4,400000, '20200921');
commit;
create index 주문_idx_01 on 주문(주문일자, 주문번호);


set autotrace on explain;

SELECT *
FROM (
    SELECT 
        TO_CHAR(A.주문번호, 'FM000000') AS 주문번호, A.업체번호, A.주문금액
    FROM 주문 A
    WHERE A.주문일자 = '20200921'
    AND A.주문번호 > 0
    ORDER BY 주문번호)
WHERE ROWNUM <= 30;

-- 인덱스를 탔지만 아래 sort by 연산이 일어났다. 원인이 무엇일까??
/*--------------------------------------------------------------------------------------------
| Id  | Operation                      | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |           |     4 |   124 |     3  (34)| 00:00:01 |
|*  1 |  COUNT STOPKEY                 |           |       |       |            |          |
|   2 |   VIEW                         |           |     4 |   124 |     3  (34)| 00:00:01 |
|*  3 |    SORT ORDER BY STOPKEY       |           |     4 |   180 |     3  (34)| 00:00:01 |
|   4 |     TABLE ACCESS BY INDEX ROWID| 주문      |     4 |   180 |     2   (0)| 00:00:01 |
|*  5 |      INDEX RANGE SCAN          | 주문_IDX_0|     1 |       |     1   (0)| 00:00:01 |

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
---------------------------------------------------------------------------------------------*/


-- order by절 주문번호에 A(주문 테이블 별명)을 붙여주기면 하면 된다.
SELECT *
FROM (
    SELECT 
        TO_CHAR(A.주문번호, 'FM000000') AS 주문번호, A.업체번호, A.주문금액
    FROM 주문 A
    WHERE A.주문일자 = '20200921'
    AND A.주문번호 > 0
    ORDER BY A.주문번호)
WHERE ROWNUM <= 30;
/*-------------------------------------------------------------------------------------------
| Id  | Operation                     | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |           |     4 |   124 |     2   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY                |           |       |       |            |          |
|   2 |   VIEW                        |           |     4 |   124 |     2   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| 주문      |     4 |   180 |     2   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | 주문_IDX_0|     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------*/



/*
    2.2.6 SELECT-LIST에서 컬럼 가공
        - 인덱스를 [장비번호+변경일자+변경순번] 으로 구성하면, 아래와 같이 변경순번 최소값을 구할 때도 옵티마이저는 정렬 연산을 따로
            수행하지 않는다.
        - 수직적 탐색을 통해 조건을 만족하는 가장 왼쪽 지점으로 내려가서 첫 번째 읽는 레코드가 바로 최소값이기 때문이다.      
*/
-- 인덱스로 인해 sort by 연산이 생략되고 FIRST ROW 연산이 되었다.
SELECT MIN(변경순번)
FROM 상태변경이력
WHERE 장비번호 ='C'
AND 변경일자 = '20180316';
/*------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |    14 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE              |           |     1 |    14 |            |          |
|   2 |   FIRST ROW                  |           |     1 |    14 |     1   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN (MIN/MAX)| 상태변경이|     1 |    14 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------*/

-- 최대값을 찾을때도 마찬가지이다.
SELECT MAX(변경순번)
FROM 상태변경이력
WHERE 장비번호 ='C'
AND 변경일자 = '20180316';
/*------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |    14 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE              |           |     1 |    14 |            |          |
|   2 |   FIRST ROW                  |           |     1 |    14 |     1   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN (MIN/MAX)| 상태변경이|     1 |    14 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------*/



-- 아래와 같이 작성하면 정렬을 생략할 수 없다.
-- 인덱스에는 문자열 기준으로 정렬돼 있는데, 이를 숫자값으로 바꾼 값 기준으로 최종 변경순번을 요구하기 때문이다.
SELECT NVL(MAX(TO_NUMBER(변경순번)), 0)
FROM 상태변경이력
WHERE 장비번호 ='C'
AND 변경일자 = '20180316';
/*-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     1 |    14 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE   |           |     1 |    14 |            |          |
|*  2 |   INDEX RANGE SCAN| 상태변경이|     2 |    28 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------*/


-- 아래처럼 max를 먼저하고 to_number를 하면 sort연산이 생략된다.
SELECT NVL(TO_NUMBER(MAX(변경순번)), 0)
FROM 상태변경이력
WHERE 장비번호 ='C'
AND 변경일자 = '20180316';
/*------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |    14 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE              |           |     1 |    14 |            |          |
|   2 |   FIRST ROW                  |           |     1 |    14 |     1   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN (MIN/MAX)| 상태변경이|     1 |    14 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------*/




CREATE TABLE 장비(장비번호 varchar2(1), 장비명 varchar2(20), 장비구분코드 varchar(10), 상태코드 varchar2(1));
INSERT INTO 장비 values('A', '마우스', 'A001', 'Y');
INSERT INTO 장비 values('B', '키보드', 'A001', 'Y');
INSERT INTO 장비 values('C', '책상', 'A002', 'Y');
INSERT INTO 장비 values('D', '선풍기', 'A003', 'Y');
INSERT INTO 장비 values('E', '칠판', 'A004', 'N');
INSERT INTO 장비 values('F', '거치대', 'A004', 'Y');
INSERT INTO 장비 values('G', '전화기', 'A004', 'Y');
commit;

-- 장비구분코드 = 'A001'에 해당하는 장비들의 최종 변경일자를 스칼라 서브쿼리로 조회해보자
-- 정렬된 index에서 max값을 가져왔다.
SELECT 장비번호, 장비명, 상태코드, (SELECT MAX(변경일자) FROM 상태변경이력 WHERE 장비번호 = P.장비번호) 최종변경일자
FROM 장비 P
WHERE 장비구분코드 ='A001';
/*------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     2 |    46 |     3   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE              |           |     1 |    11 |            |          |
|   2 |   FIRST ROW                  |           |     1 |    11 |     1   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN (MIN/MAX)| 상태변경이|     1 |    11 |     1   (0)| 00:00:01 |
|*  4 |  TABLE ACCESS FULL           | 장비      |     2 |    46 |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------------------*/


-- 위에 쿼리에 최종변경순번도 가져오고 싶으면 어떻게 될까?
-- 스칼라서브 쿼리를 추가로 작성하는건 테이블을 여러번 읽어야 하므로 비효율적이다.
-- 그래서 아래처럼 하는 경우도 있다
SELECT 장비번호, 장비명, 상태코드
    , SUBSTR(최종이력, 1, 8) 최종번경일자
    , SUBSTR(최종이력, 9) 최종변경순번
FROM ( SELECT 장비번호, 장비명, 상태코드, (SELECT MAX(변경일자||변경순번) FROM 상태변경이력 WHERE 장비번호 = P.장비번호) 최종이력
        FROM 장비 P
        WHERE 장비구분코드 ='A001');
-- 위와 같은 쿼리는 장비당 이력이 많다면 문제가 되는 쿼리다. 
-- 결론으로 해책은  Top N 알고리즘이다!!


/*
    2.2.7 자동형변환
        [1] 핵심
        * 오라클에서 숫자형과 문자형이 만나면 문자형을 숫자형으로 자동 형변환된다.
        * 날짜형(가입일자)과 문자형('01-JAN-2018')이 만나면 날짜형으로 자동 형변환된다.
        * 하지만 성능에 문제가 없더라도 자동형변환을 맹신하지말자!!
            (예를들면 날짜 형식이 다르게 설정된 환경에서 자동형변환이 되면 오류가 날 수 있다. 날짜 형식을 정확히 지정해서 형변환하자!)
            
        [2] 핵심 예제
*/

ALTER TABLE 고객 ADD (생년월일 varchar2(8));
UPDATE 고객 SET 생년월일 = '19870213' WHERE 고객ID = 'C003';
commit;


-- 옵티마지어가 생년월일을 형변환헀고, 결과적으로 인덱스 컬럼이 가공됐기 때문에 인덱스를 Range Scan 할 수 없다.
SELECT * FROM 고객 WHERE 생년월일 = 19870213;
/*                                                                                                                                                                                                                                                                                     
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    23 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| 고객 |     1 |    23 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
   1 - filter(TO_NUMBER("생년월일")=19870213)
*/

ALTER TABLE 고객 ADD (고객번호 NUMBER);
UPDATE 고객 SET 고객번호 = 9410 WHERE 고객ID = 'C003';
commit;

-- LIKE 자체가 문자열 비교 연산자이므로 이때는 문자형 기준으로 숫자형 컬럼이 변환된다.
SELECT * FROM 고객 WHERE 고객번호 LIKE '9410%';
/*--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    23 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| 고객 |     1 |    23 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------

PLAN_TABLE_OUTPUT                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
   1 - filter(TO_CHAR("고객번호") LIKE '9410%')
*/



/*
        [3] 자동 형변환 주의사항
*/

-- 문자형 컬럼에 숫자로 변환할 수 없는 문자열이 입력되면 쿼리수행 도중 에러 발생
SELECT * FROM 고객 WHERE 고객번호 = '9410g';
/*ORA-01722: 수치가 부적합합니다
01722. 00000 -  "invalid number"
*Cause:    The specified number was invalid.
*Action:   Specify a valid number.
*/


ALTER TABLE EMP ADD (SAL NUMBER DEFAULT 0);
UPDATE EMP SET SAL = round(DBMS_RANDOM.VALUE(1, 5))*1000;
UPDATE EMP SET SAL = 10000 WHERE JOB ='PRESIDENT';
UPDATE EMP SET SAL = 850 WHERE ENAME ='SCOTT';
commit;
SELECT * FROM EMP;

-- 에러가 아니라 결과 오류가 생기는 경우도있다(더 안좋음)
-- 아래 쿼리를 보면 PRESIDENT를 제외한 MAX값이 850밖에 안나온다.
select round(avg(sal)) avg_sal
        ,min(sal) min_sal
        ,max(sal) max_sal
        ,max(decode(job, 'PRESIDENT', NULL, sal)) max_sal2
from emp;

-- 밑에 쿼리 결과를 보면 PRESIDENT를 제외하고 SAL높은 사람이 7000 이다.
select *
from emp
where job <> 'PRESIDENT'
order by sal desc;
/*
     EMPNO ENAME                JOB                                DEPTNO        SAL
---------- -------------------- ------------------------------ ---------- ----------
      7934 MILLER               CLERK                                  10       4000
      7369 SMITH                CLERK                                  20       4000
      7902 FORD                 ANALYST                                20       4000
      7566 JONES                MANAGER                                20       4000
      7844 TURNER               SALESMAN                               30       4000
      7900 JAMES                CLERK                                  30       4000
      7698 BLAKE                MANAGER                                30       3000
      7521 WARD                 SALESMAN                               30       3000
      7499 ALLEN                SALESMAN                               30       2000
      7876 ADAMS                CLERK                                  20       1000
      7654 MARTIN               SALESMAN                               30       1000
      7782 CLARK                MANAGER                                10       1000
      7788 SCOTT                ANALYST                                20        850
*/

-- decode(a,b,c,d)를 처리할 때 'a = b'이면 c를 반환하고 아니면 d를 반환한다. 이때 반환되는 데이터 타입은 세 번째인자 c에 의해 결정된다.
-- 따라서 c가 문자형(null도 문자형으로 인식한다)이고 d가 숫자형이면, d는 문자형으로 변환된다.
-- 문자형으로 변환했을때 PRESIDENT를 제외한 850이 가장 크기 때문에 저렇게 나온다.

/*
    결론 : 자동 형변환에 의존하지 말고, 인덱스 컬럼 기준으로 반대편 컬럼 또는 값을 정확히 형변환해 주어야 한다!!

*/


--2.3 인덱스 확장기능 사용법

/* 
    2.3.1 Index Range Scan
        - B*Tree인덱스의 가장 일반적으로 정상적인 형태의 엑세스 방식
        - 인덱스 루트에서 리프 블록까지 수직적으로 탐색한 후에 '필요한 범위(Range)만' 스캔한다.
        - 인덱스를 Range Scan 하려면 선두 컬럼을 가공하지 않은 상태로 조건절에 사용해야 한다.
*/

set autotrace on;
create index EMP_DEPTNO_NO on emp(deptno);

select * from emp where deptno = 20;
/*---------------------------------------------------------------------------------------------
| Id  | Operation                   | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |               |     5 |   105 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP           |     5 |   105 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | EMP_DEPTNO_NO |     5 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------*/



/* 
    2.3.2 Index Full Scan
        [1] Index Full Scan 이란?
            - 수직적 탐색없이 인덱스 리프 블록을 처음부터 끝까지 수평적으로 탐색하는 방식
            - Index Full Scan은 대개 데이터 검색을 위한 최적의 인덱스가 없을 때 차선으로 선택된다.
            
*/

create index EMP_ENAME_SAL_IDX on emp(ename, sal);

select * from emp
where sal > 2000
order by ename;
/*-------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                   |     1 |    21 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP               |     1 |    21 |     2   (0)| 00:00:01 |
|*  2 |   INDEX FULL SCAN           | EMP_ENAME_SAL_IDX |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------*/


/* 
        [2] Index Full Scan 효용성
            - 데이터 저장 공간은 '가로 x 세로' 즉, '컬럼 길이 x 레코드 수'에 의해 결정되므로 인덱스가 차지하는 면적은
                테이블보다 훨씬 적다.
            -  찾고자 하는 데이터가 전체 중 극히 일부라면 Table Full Scan 보다는 Index Full Scan을 통한 필러링이 효과적이다.
            
        [3] 인덱스를 이용한 소트 연산 생략
            - Index Full Scan하면 Range Scan과 마찬가지로 결과집합이 인덱스 컬럼 순으로 정렬된다.
        
        [4] Index Full Scan시 주의점
            - 아래 예제를 확인하자
*/

-- 대부분 사원이 SAL > 1000 조건을 만족하는 상황에서 Index Full Scan을 하면, 
-- 거의 모든 레코드에 대해 테이블 엑세스가 발생하므로 Table Full Scan 보다 오히려 불리하다.
-- first_rows 힌트 : 소트 연산을 생략함으로써 전체 집합 중 처음 일부를 빠르게 출력할 목적으로 옵티마이저가 Index Full Scan 방식을 선택한 것이다.
drop index E_X01;

select /*+ first_rows */ *
from emp
where sal > 1000
order by ename;
/*-------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                   |     1 |    21 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP               |     1 |    21 |     2   (0)| 00:00:01 |
|*  2 |   INDEX FULL SCAN           | EMP_ENAME_SAL_IDX |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------*/


/*
    2.3.3 Index Unique Scan
        - 수직적 탐색만으로 데이터를 찾는 스캔 방식
        - Unique 인덱스를 '=' 조건으로 탐색하는 경우에 작동
        - Unique 인덱스가 존재하는 컬럼은 중복 값이 입력되지 않게 DBMS가 데이터 정합성을 관리해 준다.
*/

/* 
아래 구문은 이미 pk설정 및 pk_index가 존재하여 주석처리
create unique index pk_emp on emp(empno);
alter table emp add
constraint pk_emp primary key(empno) using index pk_emp;
*/

select empno, ename from emp where empno = 7788;
/*-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |     1 |    10 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP         |     1 |    10 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | SYS_C003980 |     1 |       |     0   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------*/

/*
    2.3.4 Index Skip Scan
        [1] Index Skip Scan 정의
            - 인덱스 선두 컬럼이 조건절에 없어도 인덱스를 활용하는 새로운 스캔 방식
            - 인덱스 선두 컬럼을 조건절에 사용하지 않으면 옵티마이저는 기본적으로 Table Full Scan을 선택한다.
                Table Full Scan 보다 I/O를 줄일 수 있거나 정렬된 결과를 쉽게 얻을 수 있다면 , Index Skip Scan을 사용하기도 한다.
            - 인덱스 선투 컬럼의 Distinct Value 개수가 적고(성별) 후행 컬럼의 Distinct Value 개수가 많을 때(고객번호) 유용하다.
            - index_ss, no_index_ss 힌트
            - index Skip Scan은 루트 또는 브랜치 블록에서 읽은 컬럼 값 정보를 이용해 조건절에 부합하는 레코드를 포함할 '가능성이 있는' 
                리프 블록만 골라서 액세스하는 스캔 방식이다.
        
*/

CREATE TABLE 사원(성별 varchar2(3), 연봉 number);
INSERT INTO 사원 VALUES('남', 800);
INSERT INTO 사원 VALUES('남', 1500);
INSERT INTO 사원 VALUES('남', 5000);
INSERT INTO 사원 VALUES('남', 8000);
INSERT INTO 사원 VALUES('남', 10000);
INSERT INTO 사원 VALUES('여', 3000);
INSERT INTO 사원 VALUES('여', 5000);
INSERT INTO 사원 VALUES('여', 7000);
INSERT INTO 사원 VALUES('여', 10000);
commit;

CREATE INDEX 사원_IDX ON 사원(성별, 연봉);

-- 성별+연봉으로 조회할 경우 Range Scan이 정상 작동한다.
select * from 사원 where 성별 = '남' and 연봉 between 2000 and 4000;
/*---------------------------------------------------------------------------
| Id  | Operation        | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT |        |     1 |    16 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| 사원_ID|     1 |    16 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------*/


-- 이번에는 성별을 제외한 연봉만 조회 할 경우 Skip Scan을 유도해보자
select *
from 사원
where 연봉 between 2000 and 4000;
/*---------------------------------------------------------------------------
| Id  | Operation        | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT |        |     1 |    16 |     1   (0)| 00:00:01 |
|*  1 |  INDEX SKIP SCAN | 사원_ID|     1 |    16 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------*/

/*
        [2] Index Skip Scan이 작동하기 위한 조건
            a. Distinct Value 개수가 적은 선두 컬럼이 조건절에 없고 후헹 컬럼의 Distinct Value 개수가 많을 때 효과적이다.
            
            b. 일변업종별거래_PK : 업종유형코드 + 업종코드 + 기준일자
                - 위에 인덱스에서 업종유형코드 + 기준일자로 조회하여도 ISS가 가능 (단 업종코드가 Distinct Value가 적어야함)
                - 위에 인덱스에서 기준일자만 조회하여도 ISS가 가능 (단 업종코드가 Distinct Value가 적어야함)
                
        [3] 인덱스는 기본적으로 최적의 Index Range Scan을 목표로 설계해야 하며, 수행 횟수가 적은 SQL을 위해 인덱스를 추가하는 것이
                비효율적 일 때 이들 스캔방식을 차선책으로 활용하는 전략이 바람직하다.
           
           
           
    2.3.5 Index Fast Full Scan
        - Index Fast Full Scan은 Index Full Scan보다 빠르다
        - 빠른 이유는 논리적인 인덱스 트리 구조를 무시하고 인덱스 세그먼트 전체를 Multiblock I/O방식으로 스캔하기 때문이다.
        - index_ffs, no_index_ffs 힌트
        - Multiblock I/O 방식을 사용하므로 디스크로부터 대량의 인덱스 블록을 읽어야 할 때 큰효과를 발휘한다.
        ※ 쿼리에 사용한 컬럼이 모두 인덱스가 포함돼 있을 때만 사용할 수 있다.
        - 인덱스가 파티션 돼 있지 않더라고 병렬쿼리가 가능하다.(이 때는 Direct Path I/O 방식 사용)
        
    2.3.6 Index Range Scan Descending
        - 인덱스를 뒤에서 부터 앞으로 읽어준다.
*/


select * from emp where empno > 0 order by empno desc;
/*--------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |    14 |   294 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID | EMP         |    14 |   294 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN DESCENDING| SYS_C003980 |    14 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------*/


-- Max 값을 구하고자 할 때도 해당 컬럼에 인덱스가 있으면 인덱스를 뒤에서부터 읽어서 한건만 읽고 멈추는 실행계획이 작동한다.
create index emp_x02 on emp(deptno, sal);

select deptno, dname, loc
        ,(select max(sal) from emp where deptno = d.deptno)
from dept d;
/*----------------------------------------------------------------------------------------
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |     4 |    80 |     3   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE              |         |     1 |    16 |            |          |
|   2 |   FIRST ROW                  |         |     1 |    16 |     1   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN (MIN/MAX)| EMP_X02 |     1 |    16 |     1   (0)| 00:00:01 |
|   4 |  TABLE ACCESS FULL           | DEPT    |     4 |    80 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------*/

