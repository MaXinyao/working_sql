SELECT
    event_name
    ,COUNT(CASE when _table_suffix = '20210330' then 1 else null end) as pv_0330
    ,COUNT(distinct CASE when _table_suffix = '20210330' then unique_user_id else null end) as uv_0330
    ,COUNT(CASE when _table_suffix = '20210608' then 1 else null end) as pv_0604
    ,COUNT(distinct CASE when _table_suffix = '20210608' then unique_user_id else null end) as uv_0604
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`
WHERE _table_suffix in ('20210330','20210608')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1000