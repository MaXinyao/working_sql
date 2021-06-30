SELECT
    COUNT(distinct unique_user_id) as users
    ,AVG(CASE when ua_cost > 0 then ua_cost else null end) as cpi
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
WHERE create_date between DATE_ADD(CURRENT_DATE(),INTERVAL -5 DAY) and DATE_ADD(CURRENT_DATE(),INTERVAL -3 DAY)
AND first_country = 'Brazil'
AND campaign_name = 'QB_uty_adr_br_IAA_0521'