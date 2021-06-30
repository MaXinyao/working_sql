SELECT date, COUNT(distinct a.user_pseudo_id) as dau
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` a
INNER JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a` u 
ON u.user_pseudo_id = a.user_pseudo_id
AND u.media_source = 'googleadwords_int'
AND u.create_date between '2020-10-13' and '2020-10-31'
AND a.date between u.create_date and DATE_ADD(u.create_date, interval 2 day)
WHERE date between '2020-10-15' and '2020-10-31'
GROUP BY 1
ORDER BY 1