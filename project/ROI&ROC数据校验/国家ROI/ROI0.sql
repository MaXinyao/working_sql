SELECT
    SUM(rev) as rev
FROM
    (SELECT
        distinct unique_user_id
    FROM `kjvbible-new.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE first_country = @country
    AND create_date between @start_date and @end_date) u
LEFT JOIN 
    (SELECT
        unique_user_id, IFNULL(SUM(ad_revenue),0)+IFNULL(SUM(pur_revenue),0) as rev
    FROM `kjvbible-new.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix between FORMAT_DATE('%Y%m%d',@start_date) and FORMAT_DATE('%Y%m%d',@end_date)
    AND living_days = 0
    GROUP BY 1) r
ON u.unique_user_id = r.unique_user_id