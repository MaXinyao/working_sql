-- PBN
SELECT
    rev.create_month,
    rev.first_country,
    rev.new_users,
    spend.spend,
    rev.rev7,
    rev.rev14,
    rev.rev30,
    rev.rev90,
    rev.rev120,
    CASE when spend.spend > 0 then rev.rev7/spend.spend else -1 end as ROI7,
    CASE when spend.spend > 0 then rev.rev14/spend.spend else -1 end as ROI14,
    CASE when spend.spend > 0 then rev.rev30/spend.spend else -1 end as ROI30,
    CASE when spend.spend > 0 then rev.rev90/spend.spend else -1 end as ROI90,
    CASE when spend.spend > 0 then rev.rev120/spend.spend else -1 end as ROI120
FROM
    (SELECT
        u.create_month as create_month,
        u.first_country,
        COUNT(distinct u.unique_user_id) as new_users,
        IFNULL(SUM(iaa_rev7),0)+IFNULL(SUM(iap_rev7),0) as rev7,
        IFNULL(SUM(iaa_rev14),0)+IFNULL(SUM(iap_rev14),0) as rev14,
        IFNULL(SUM(iaa_rev30),0)+IFNULL(SUM(iap_rev30),0) as rev30,
        IFNULL(SUM(iaa_rev90),0)+IFNULL(SUM(iap_rev90),0) as rev90,
        IFNULL(SUM(iaa_rev120),0)+IFNULL(SUM(iap_rev120),0) as rev120
    FROM
        (SELECT
            date_trunc(create_date, month) as create_month, 
            first_country,
            unique_user_id
        FROM `paint-by-number-3c789.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
        WHERE create_date between '2020-11-01' and '2021-03-31'
        AND first_country in ('India','United States','Brazil','Russia','Germany','Mexico','France','Turkey','Indonesia','Poland','Egypt',
            'United Kingdom','Colombia','Ukraine','Spain','Argentina','Italy','Iran','Vietnam','Iraq')) u
    LEFT JOIN
        (SELECT
            unique_user_id,
            SUM(CASE when living_days < 8 then ad_revenue else 0 end) as iaa_rev7,
            SUM(CASE when living_days < 15 then ad_revenue else 0 end) as iaa_rev14,
            SUM(CASE when living_days < 31 then ad_revenue else 0 end) as iaa_rev30,
            SUM(CASE when living_days < 91 then ad_revenue else 0 end) as iaa_rev90,
            SUM(CASE when living_days < 121 then ad_revenue else 0 end) as iaa_rev120,
            SUM(CASE when living_days < 8 then pur_revenue else 0 end) as iap_rev7,
            SUM(CASE when living_days < 15 then pur_revenue else 0 end) as iap_rev14,
            SUM(CASE when living_days < 31 then pur_revenue else 0 end) as iap_rev30,
            SUM(CASE when living_days < 91 then pur_revenue else 0 end) as iap_rev90,
            SUM(CASE when living_days < 121 then pur_revenue else 0 end) as iap_rev120,
        FROM `paint-by-number-3c789.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE _TABLE_SUFFIX >= format_date("%Y%m%d", '2020-09-01')
        GROUP BY 1) rev
    ON u.unique_user_id = rev.unique_user_id
    GROUP BY 1,2) rev
LEFT JOIN
    (SELECT
        date_trunc(spend.date,month) as create_month
        ,c.country as first_country
        ,SUM(spend.spend) as spend
        ,SUM(spend.install) as install
    FROM `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a` app
    INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_*` spend
    ON IFNULL(app.app_id,'-') = IFNULL(spend.app_id,'-')
    AND IFNULL(app.media_source,'-') = IFNULL(spend.media_source,'-')
    AND IFNULL(app.platform,'-') = IFNULL(spend.platform,'-')
    AND app.production_id in ('5b84f58e689998000116d3fd')
    AND spend._table_suffix between '20201101' and '20210331'
    AND IFNULL(app.store, '-') != 'instant_game'
    INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` c
    ON c.country_code = spend.country_code
    GROUP BY 1,2) spend
ON spend.create_month = rev.create_month
AND spend.first_country = rev.first_country
ORDER BY 1,2;

-- Qblock
SELECT
    rev.create_month,
    rev.first_country,
    rev.new_users,
    spend.spend,
    rev.rev7,
    rev.rev14,
    rev.rev30,
    rev.rev90,
    rev.rev120,
    CASE when spend.spend > 0 then rev.rev7/spend.spend else -1 end as ROI7,
    CASE when spend.spend > 0 then rev.rev14/spend.spend else -1 end as ROI14,
    CASE when spend.spend > 0 then rev.rev30/spend.spend else -1 end as ROI30,
    CASE when spend.spend > 0 then rev.rev90/spend.spend else -1 end as ROI90,
    CASE when spend.spend > 0 then rev.rev120/spend.spend else -1 end as ROI120
FROM
    (SELECT
        u.create_month as create_month,
        u.first_country,
        COUNT(distinct u.unique_user_id) as new_users,
        IFNULL(SUM(iaa_rev7),0)+IFNULL(SUM(iap_rev7),0) as rev7,
        IFNULL(SUM(iaa_rev14),0)+IFNULL(SUM(iap_rev14),0) as rev14,
        IFNULL(SUM(iaa_rev30),0)+IFNULL(SUM(iap_rev30),0) as rev30,
        IFNULL(SUM(iaa_rev90),0)+IFNULL(SUM(iap_rev90),0) as rev90,
        IFNULL(SUM(iaa_rev120),0)+IFNULL(SUM(iap_rev120),0) as rev120
    FROM
        (SELECT
            date_trunc(create_date, month) as create_month, 
            first_country,
            unique_user_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
        WHERE create_date between '2020-11-01' and '2021-03-31'
        AND first_country in ('Russia','Brazil','United States','Germany','Turkey','France','Mexico','Italy','Spain','South Korea','United Kingdom',
            'India','Japan','Ukraine','Kazakhstan','Poland','Indonesia','Canada','Chile','Australia')) u
    LEFT JOIN
        (SELECT
            unique_user_id,
            SUM(CASE when living_days < 8 then ad_revenue else 0 end) as iaa_rev7,
            SUM(CASE when living_days < 15 then ad_revenue else 0 end) as iaa_rev14,
            SUM(CASE when living_days < 31 then ad_revenue else 0 end) as iaa_rev30,
            SUM(CASE when living_days < 91 then ad_revenue else 0 end) as iaa_rev90,
            SUM(CASE when living_days < 121 then ad_revenue else 0 end) as iaa_rev120,
            SUM(CASE when living_days < 8 then pur_revenue else 0 end) as iap_rev7,
            SUM(CASE when living_days < 15 then pur_revenue else 0 end) as iap_rev14,
            SUM(CASE when living_days < 31 then pur_revenue else 0 end) as iap_rev30,
            SUM(CASE when living_days < 91 then pur_revenue else 0 end) as iap_rev90,
            SUM(CASE when living_days < 121 then pur_revenue else 0 end) as iap_rev120,
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE _TABLE_SUFFIX >= format_date("%Y%m%d", '2020-09-01')
        GROUP BY 1) rev
    ON u.unique_user_id = rev.unique_user_id
    GROUP BY 1,2) rev
LEFT JOIN
    (SELECT
        date_trunc(spend.date,month) as create_month
        ,c.country as first_country
        ,SUM(spend.spend) as spend
        ,SUM(spend.install) as install
    FROM `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a` app
    INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_*` spend
    ON IFNULL(app.app_id,'-') = IFNULL(spend.app_id,'-')
    AND IFNULL(app.media_source,'-') = IFNULL(spend.media_source,'-')
    AND IFNULL(app.platform,'-') = IFNULL(spend.platform,'-')
    AND app.production_id in ('5d0b34d6883d6a000119ed23')
    AND spend._table_suffix between '20201101' and '20210331'
    AND IFNULL(app.store, '-') != 'instant_game'
    INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` c
    ON c.country_code = spend.country_code
    GROUP BY 1,2) spend
ON spend.create_month = rev.create_month
AND spend.first_country = rev.first_country
ORDER BY 1,2;

-- Sudoku
SELECT
    rev.create_month,
    rev.first_country,
    rev.new_users,
    spend.spend,
    rev.rev7,
    rev.rev14,
    rev.rev30,
    rev.rev90,
    rev.rev120,
    CASE when spend.spend > 0 then rev.rev7/spend.spend else -1 end as ROI7,
    CASE when spend.spend > 0 then rev.rev14/spend.spend else -1 end as ROI14,
    CASE when spend.spend > 0 then rev.rev30/spend.spend else -1 end as ROI30,
    CASE when spend.spend > 0 then rev.rev90/spend.spend else -1 end as ROI90,
    CASE when spend.spend > 0 then rev.rev120/spend.spend else -1 end as ROI120
FROM
    (SELECT
        u.create_month as create_month,
        u.first_country,
        COUNT(distinct u.unique_user_id) as new_users,
        IFNULL(SUM(iaa_rev7),0)+IFNULL(SUM(iap_rev7),0) as rev7,
        IFNULL(SUM(iaa_rev14),0)+IFNULL(SUM(iap_rev14),0) as rev14,
        IFNULL(SUM(iaa_rev30),0)+IFNULL(SUM(iap_rev30),0) as rev30,
        IFNULL(SUM(iaa_rev90),0)+IFNULL(SUM(iap_rev90),0) as rev90,
        IFNULL(SUM(iaa_rev120),0)+IFNULL(SUM(iap_rev120),0) as rev120
    FROM
        (SELECT
            date_trunc(create_date, month) as create_month, 
            first_country,
            unique_user_id
        FROM `sudoku-a782f.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
        WHERE create_date between '2020-11-01' and '2021-03-31'
        AND first_country in ('United States','Germany','Russia','Japan','India','France','Brazil','Spain','Mexico','United Kingdom','Ukraine',
            'Poland','Colombia','Turkey','Canada','Italy','South Korea','Iran','Netherlands','Argentina')) u
    LEFT JOIN
        (SELECT
            unique_user_id,
            SUM(CASE when living_days < 8 then ad_revenue else 0 end) as iaa_rev7,
            SUM(CASE when living_days < 15 then ad_revenue else 0 end) as iaa_rev14,
            SUM(CASE when living_days < 31 then ad_revenue else 0 end) as iaa_rev30,
            SUM(CASE when living_days < 91 then ad_revenue else 0 end) as iaa_rev90,
            SUM(CASE when living_days < 121 then ad_revenue else 0 end) as iaa_rev120,
            SUM(CASE when living_days < 8 then pur_revenue else 0 end) as iap_rev7,
            SUM(CASE when living_days < 15 then pur_revenue else 0 end) as iap_rev14,
            SUM(CASE when living_days < 31 then pur_revenue else 0 end) as iap_rev30,
            SUM(CASE when living_days < 91 then pur_revenue else 0 end) as iap_rev90,
            SUM(CASE when living_days < 121 then pur_revenue else 0 end) as iap_rev120,
        FROM `sudoku-a782f.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE _TABLE_SUFFIX >= format_date("%Y%m%d", '2020-09-01')
        GROUP BY 1) rev
    ON u.unique_user_id = rev.unique_user_id
    GROUP BY 1,2) rev
LEFT JOIN
    (SELECT
        date_trunc(spend.date,month) as create_month
        ,c.country as first_country
        ,SUM(spend.spend) as spend
        ,SUM(spend.install) as install
    FROM 
        (select 
            distinct app_id, 
            media_source, 
            platform, 
            production_id
        from `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a`
        where ifnull(store, '-') != 'instant_game'
        and production_id in ('5b6d3b0543b43800015a5a87')) app
    INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_*` spend
    ON IFNULL(app.app_id,'-') = IFNULL(spend.app_id,'-')
    AND IFNULL(app.media_source,'-') = IFNULL(spend.media_source,'-')
    AND IFNULL(app.platform,'-') = IFNULL(spend.platform,'-')
    AND spend._table_suffix between '20201101' and '20210331'
    INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` c
    ON c.country_code = spend.country_code
    GROUP BY 1,2) spend
ON spend.create_month = rev.create_month
AND spend.first_country = rev.first_country
ORDER BY 1,2;