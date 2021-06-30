SELECT
    SUM(rev)/COUNT(distinct u.unique_user_id) as ltv21
FROM
    (SELECT
        distinct unique_user_id, ua_cost
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE create_date = '2021-05-28'
    AND campaign_name = 'QB_adr_adw_IN_combo5_1_0506'
    AND first_country = 'India') u
INNER JOIN
    (SELECT
        unique_user_id, IFNULL(SUM(ad_revenue),0)+IFNULL(SUM(pur_revenue),0) as rev
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix between '20210528' and format_date('%Y%m%d',DATE_ADD(date('2021-05-28'), interval 21 day))
    GROUP BY 1) r
ON u.unique_user_id = r.unique_user_id