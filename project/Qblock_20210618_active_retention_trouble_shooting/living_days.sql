SELECT
    u.date,
    u.living_days,
    COUNT(distinct u.unique_user_id) as users,
    COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        distinct date, 
        CASE when living_days = 0 then '0'
            WHEN living_days between 1 and 7 then '1-7'
            WHEN living_days between 8 and 30 then '8-30'
            WHEN living_days between 31 and 90 then '31-90'
            else '90+' end as living_days, 
        unique_user_id
    FROM `woodblockudoku.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') u
LEFT JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `woodblockudoku.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON u.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(u.date, interval 1 day)
GROUP BY 1,2
ORDER BY 1,2