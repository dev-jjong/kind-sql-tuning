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






