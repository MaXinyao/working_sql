SELECT
    parse_date('%Y%m%d',_table_suffix) as date,
    COUNT(*) as events
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*` e
INNER JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a` u 
ON u.user_pseudo_id = e.user_pseudo_id
AND u.media_source = 'googleadwords_int'
WHERE _table_suffix between '20201015' and '20201031'
AND event_name = 'grt_1r_splash_3_5'
GROUP BY 1
ORDER BY 1;