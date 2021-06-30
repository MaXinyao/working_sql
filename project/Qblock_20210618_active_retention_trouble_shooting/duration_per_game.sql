SELECT
    u.date
    ,CASE when duration between 0 and 500 then '0-500'
        WHEN duration > 500 and duration <= 1000 then '500-1000'
        WHEN duration > 1000 AND duration <= 2000 then '1000-2000'
        WHEN duration > 2000 AND duration <= 4000 then '2000-4000'
        else '>4000' end as duration
    ,COUNT(distinct u.unique_user_id) as users
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        date
        ,unique_user_id
        ,CASE when duration is null then 0 else duration end as duration
    FROM
        (SELECT
            date
            ,unique_user_id
            ,SUM(duration)/1000 as duration
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE _table_suffix >= '20210101'
        GROUP BY 1,2)) u
LEFT JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON u.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(u.date, interval 1 day)
GROUP BY 1,2
ORDER BY 1,2