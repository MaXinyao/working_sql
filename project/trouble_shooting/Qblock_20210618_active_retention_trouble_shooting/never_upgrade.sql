SELECT
    d.date
    -- ,u.first_app_version
    ,COUNT(distinct d.unique_user_id) as users
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct d.unique_user_id) as active_retention
FROM
    (SELECT
        distinct unique_user_id, first_app_version
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE last_app_version = first_app_version
    AND first_app_version < '002001003000000') u
INNER JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') d
ON d.unique_user_id = u.unique_user_id
LEFT JOIN
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON d.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(d.date, interval 1 day)
GROUP BY 1
-- HAVING users > 2000
ORDER BY 1