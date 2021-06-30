SELECT
    u.date
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') u
LEFT JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON u.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(u.date, interval 2 day)
GROUP BY 1
ORDER BY 1