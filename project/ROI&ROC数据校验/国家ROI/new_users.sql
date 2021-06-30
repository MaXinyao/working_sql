SELECT
    COUNT(distinct unique_user_id) as users
FROM `kjvbible-new.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
WHERE create_date between @start_date and @end_date
AND first_country = @country