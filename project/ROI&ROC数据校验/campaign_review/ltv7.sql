SELECT
    SUM(rev)/COUNT(distinct u.unique_user_id) as ltv7
FROM
    (SELECT
        distinct create_date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE create_date between DATE_ADD(CURRENT_DATE(),INTERVAL -15 DAY) and DATE_ADD(CURRENT_DATE(),INTERVAL -9 DAY)
    AND first_country = 'Brazil'
    AND campaign_name = 'QB_uty_adr_br_IAA_0521') u
LEFT JOIN 
    (SELECT
        date
        ,unique_user_id
        ,IFNULL(SUM(ad_revenue),0)+IFNULL(SUM(pur_revenue),0) as rev
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix between format_date('%Y%m%d',DATE_ADD(CURRENT_DATE(),INTERVAL -15 DAY)) 
    and format_date('%Y%m%d',DATE_ADD(CURRENT_DATE(),INTERVAL -2 DAY))
    GROUP BY 1,2) r
ON u.unique_user_id = r.unique_user_id
AND r.date between u.create_date and DATE_ADD(u.create_date, interval 7 day)