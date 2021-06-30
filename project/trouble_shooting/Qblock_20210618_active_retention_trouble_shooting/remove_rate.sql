SELECT
    dau.date,
    COUNT(distinct r.unique_user_id)/COUNT(distinct dau.unique_user_id) as remove_rate
FROM
    (SELECT
        distinct date,
        unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') dau
LEFT JOIN
    (SELECT
        distinct unique_user_id, remove_date
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE remove_date >= '2021-01-01') r
ON r.remove_date = dau.date
AND dau.unique_user_id = r.unique_user_id
GROUP BY 1
ORDER BY 1