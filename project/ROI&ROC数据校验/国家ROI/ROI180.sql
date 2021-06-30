SELECT
    SUM(rev) as rev
FROM
    (SELECT
        distinct unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a`
    WHERE first_country = @country
    AND create_date between @start_date and @end_date) u
LEFT JOIN 
    (SELECT
        unique_user_id, IFNULL(SUM(ad_revenue),0)+IFNULL(SUM(pur_revenue),0) as rev
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix between FORMAT_DATE('%Y%m%d',@start_date) and FORMAT_DATE('%Y%m%d',DATE_ADD(@end_date, interval 180 day))
    AND living_days <= 180
    GROUP BY 1) r
ON u.unique_user_id = r.unique_user_id