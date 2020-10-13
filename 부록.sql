-- [1] DBMS_XPLAN 패키지

/*
    a. 예상 실행계획 출력
        - dbms_xplan.display('[plan_table]','[statement_id]','[option]');
        - statement_id가 null이면 가장 마지막 explain plan 명령에 사용했던 쿼리의 실행계획을 보여준다.
*/

select plan_table_output from table(dbms_xplan.display('PLAN_TABLE', null, 'ALL'));


/*
    b. 캐싱된 커서의 ROW SOURCE별 수행 통계 출력
        - dbms_xplan.display_cursor('[sql_id]', '[child_no]', '[format]');
        - sql_id, child_no 인자에 null을 넣으려면 serveroutput을 off로 전환한다.
        - 세션 레벨에서 statistics_level 파라미터를 all로 설정해야한다. (혹은 분석 대상 SQL문에 gather_plan_statistics 힌트를 준다)
                
*/

set serveroutput off;
alter session set statistics_level = 'ALL';

select plan_table_output from table(dbms_xplan.display_cursor(null, null, 'allstats'));








