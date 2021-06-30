SELECT
    u.date
    ,u.last_dau_day_diff
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        distinct date
        ,CASE when last_dau_day_diff = 1 then '1'
            when last_dau_day_diff between 2 and 7 then '2-7'
            else '7+' end as last_dau_day_diff
        ,unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101'
    AND living_days > 30) u
LEFT JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON u.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(u.date, interval 1 day)
GROUP BY 1,2
ORDER BY 1,2