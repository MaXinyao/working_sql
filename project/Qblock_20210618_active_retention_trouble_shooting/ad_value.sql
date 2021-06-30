SELECT
    u.date
    ,CASE WHEN ecpm = 0 then '0'
        WHEN ecpm > 0 and ecpm < 5 then '0-5'
        WHEN ecpm between 5 and 10 then '5-10'
        else '>10' end as ecpm_level
    ,COUNT(distinct u.unique_user_id) as users
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        date
        ,unique_user_id
        ,CASE when inter_show is null OR inter_show = 0 OR inter_revenue is null 
            or inter_revenue = 0 then 0 else inter_revenue/inter_show*1000 end as ecpm
    FROM
        (SELECT
            date
            ,unique_user_id
            ,SUM(inter_revenue) as inter_revenue
            ,SUM(inter_show) as inter_show
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