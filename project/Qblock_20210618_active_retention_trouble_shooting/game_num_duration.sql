SELECT
    date
    ,SUM(game_num)/COUNT(distinct unique_user_id) as game_num
    ,SUM(duration)/SUM(game_num)
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
WHERE _table_suffix >= '20210101'
GROUP BY 1
ORDER BY 1