SELECT
    create_date AS Install_date,
    ad_id AS Fb_Ad_ID,
    COUNT(distinct campaign_table.user_pseudo_id) AS Install,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)=0 then ad_revenue end),2)AS RevAd_D0 ,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=1 then ad_revenue end),2)AS RevAd_D1,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=3 then ad_revenue end),2)AS RevAd_D3,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=7 then ad_revenue end),2)AS RevAd_D7,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=14 then ad_revenue end),2)AS RevAd_D14,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=30 then ad_revenue end),2)AS RevAd_D30,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=60 then ad_revenue end),2)AS RevAd_D60,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=90 then ad_revenue end),2)AS RevAd_D90,
    ROUND(SUM(case when DATE_DIFF(date,create_date,DAY)<=120 then ad_revenue end),2)AS RevAd_D120,
    -- ROUND(SUM(ad_revenue),2)AS RevAd_lifetime,
    -- COUNT(distinct case when ad_show > 0 then campaign_table.user_pseudo_id else null end)AS PlayerAdShow_lifetime,
    SUM(case when DATE_DIFF(date,create_date,DAY)=0 then pur_revenue end) AS RevIAP_D0,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=1 then pur_revenue end)AS RevIAP_D1,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=3 then pur_revenue end)AS RevIAP_D3,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=7 then pur_revenue end)AS RevIAP_D7,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=14 then pur_revenue end)AS RevIAP_D14,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=30 then pur_revenue end)AS RevIAP_D30,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=60 then pur_revenue end)AS RevIAP_D60,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=90 then pur_revenue end)AS RevIAP_D90,
    SUM(case when DATE_DIFF(date,create_date,DAY)<=120 then pur_revenue end)AS RevIAP_D120
    -- SUM(pur_revenue)AS RevIAP_lifetime, --需要修改
    -- COUNT(distinct case when pur_revenue > 0 then campaign_table.user_pseudo_id else null end) as Payer_lifetime --需要修改
FROM(
    SELECT
        date,
        living_days,
        user_pseudo_id,
        ad_revenue,
        pur_revenue,
        ad_show
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between DATE_ADD(CURRENT_DATE(),interval -130 day) and CURRENT_DATE()) revenue_table
JOIN(
    SELECT
        create_date,
        user_pseudo_id,
        ad_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE ad_id != 'unknown' and ad_id != 'null')campaign_table
ON revenue_table.user_pseudo_id = campaign_table.user_pseudo_id
GROUP BY 1,2
ORDER BY 1,2