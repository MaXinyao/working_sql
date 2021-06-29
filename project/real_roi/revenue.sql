SELECT
    u.month,
    SUM(rev.total_revenue) as rev,
    SUM(CASE WHEN first_country = 'United States' THEN rev.total_revenue ELSE 0 END) as us_rev,
    AVG(CASE WHEN media_source not in ('Organic','organic') THEN rev.total_revenue ELSE NULL END) as ua_ltv,
    AVG(CASE WHEN media_source not in ('Organic','organic') AND first_country = 'United States' THEN rev.total_revenue ELSE NULL END) as us_ua_ltv,
    AVG(CASE WHEN media_source = 'googleadwords_int' THEN rev.total_revenue ELSE NULL END) as adwords_ltv,
    AVG(CASE WHEN media_source = 'googleadwords_int' AND first_country = 'United States' THEN rev.total_revenue ELSE NULL END) as us_adwords_ltv,
    AVG(CASE WHEN media_source = 'Facebook Ads' THEN rev.total_revenue ELSE NULL END) as fb_ltv,
    AVG(CASE WHEN media_source = 'Facebook Ads' AND first_country = 'United States' THEN rev.total_revenue ELSE NULL END) as us_fb_ltv,
FROM
    (SELECT
        date_trunc(create_date, month) as month, 
        first_country,
        media_source,
        unique_user_id
    FROM `sudoku-a782f.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a`
    WHERE create_date between '2020-09-01' and '2021-03-31') u
LEFT JOIN
    (SELECT
        unique_user_id,
        IFNULL(SUM(ad_revenue),0)+IFNULL(SUM(pur_revenue),0) as total_revenue
    FROM `sudoku-a782f.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _TABLE_SUFFIX >= format_date("%Y%m%d", '2020-09-01')
    GROUP BY 1) rev
ON u.unique_user_id = rev.unique_user_id
GROUP BY 1
ORDER BY 1