SELECT
    u.date
    ,u.active_level
    ,COUNT(distinct u.unique_user_id) as users
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        distinct date
        ,CASE WHEN dau_days/living_days < 0.3 then '0.3-'
            WHEN dau_days/living_days between 0.3 and 0.6 then '0.3-0.6'
            WHEN dau_days/living_days between 0.7 and 0.9 then '0.7-0.9'
            else '0.9+' end as active_level
        ,unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101'
    AND living_days > 30
    AND last_dau_day_diff = 1
    ) u
LEFT JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON u.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(u.date, interval 1 day)
GROUP BY 1,2
ORDER BY 1,2