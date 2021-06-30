SELECT
    parse_date('%Y%m%d',_table_suffix) as date
    ,CASE when event_name in ('push_set','act_set_notification') then 'push_set'
        when event_name in ('push_receive','act_receive_notification') then 'push_receive'
        else 'push_click' end as push_type
    ,COUNT(distinct unique_user_id) as users
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`
WHERE _table_suffix >= '20210101'
AND event_name in ('push_receive','push_click','push_set','act_set_notification','act_receive_notification','act_click_notification')
GROUP BY 1,2
ORDER BY 1,2