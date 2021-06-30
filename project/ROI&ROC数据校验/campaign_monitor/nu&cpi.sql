SELECT
    COUNT(distinct unique_user_id) as users
    ,AVG(CASE WHEN ua_cost > 0 then ua_cost else null end) as cpi
    ,AVG(ua_cost) as ua_cost
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
WHERE create_date = '2021-05-28'
AND campaign_name = 'QB_adr_adw_IN_combo5_1_0506'
AND first_country = 'India'