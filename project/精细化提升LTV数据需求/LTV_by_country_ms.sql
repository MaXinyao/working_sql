-- PBN
SELECT
    create_month,
    first_country,
    media_source,
    new_users,
    CPI,
    LTV7,
    LTV14,
    LTV30,
    LTV90,
    LTV120,
    CASE when CPI > 0 then LTV7/CPI else -1 end as ROC7,
    CASE when CPI > 0 then LTV14/CPI else -1 end as ROC14,
    CASE when CPI > 0 then LTV30/CPI else -1 end as ROC30,
    CASE when CPI > 0 then LTV90/CPI else -1 end as ROC90,
    CASE when CPI > 0 then LTV120/CPI else -1 end as ROC120
FROM
    (SELECT
        rev.create_month,
        rev.first_country,
        rev.media_source,
        rev.new_users,
        CASE when install > 0 then spend.spend/spend.install else -1 end as CPI,
        CASE when new_users > 0 then rev.rev7/new_users else -1 end as LTV7,
        CASE when new_users > 0 then rev.rev14/new_users else -1 end as LTV14,
        CASE when new_users > 0 then rev.rev30/new_users else -1 end as LTV30,
        CASE when new_users > 0 then rev.rev90/new_users else -1 end as LTV90,
        CASE when new_users > 0 then rev.rev120/new_users else -1 end as LTV120,
    FROM
        (SELECT
            u.create_month as create_month,
            u.first_country,
            CASE when u.media_source in ('Organic','organic') then 'Organic' else u.media_source end as media_source,
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
                media_source,
                unique_user_id
            FROM `paint-by-number-3c789.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
            WHERE create_date between '2020-11-01' and '2021-03-31'
            AND first_country in ('India','United States','Brazil','Russia','Germany','Mexico','France','Turkey','Indonesia','Poland','Egypt',
                'United Kingdom','Colombia','Ukraine','Spain','Argentina','Italy','Iran','Vietnam','Iraq')
            AND media_source in ('unityads_int','googleadwords_int','Facebook Ads','Organic','organic')) u
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
        GROUP BY 1,2,3) rev
    LEFT JOIN
        (SELECT
            date_trunc(spend.date,month) as create_month
            ,c.country as first_country
            ,CASE WHEN spend.media_source = 'unity' THEN 'unityads_int'
                WHEN spend.media_source = 'facebook' THEN 'Facebook Ads'
                WHEN spend.media_source = 'adwords' THEN 'googleadwords_int'
                ELSE 'Other' END as media_source
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
        GROUP BY 1,2,3) spend
    ON spend.create_month = rev.create_month
    AND spend.first_country = rev.first_country
    AND spend.media_source = rev.media_source)
ORDER BY 1,2,3;

-- Qblock
SELECT
    create_month,
    first_country,
    media_source,
    new_users,
    CPI,
    LTV7,
    LTV14,
    LTV30,
    LTV90,
    LTV120,
    CASE when CPI > 0 then LTV7/CPI else -1 end as ROC7,
    CASE when CPI > 0 then LTV14/CPI else -1 end as ROC14,
    CASE when CPI > 0 then LTV30/CPI else -1 end as ROC30,
    CASE when CPI > 0 then LTV90/CPI else -1 end as ROC90,
    CASE when CPI > 0 then LTV120/CPI else -1 end as ROC120
FROM
    (SELECT
        rev.create_month,
        rev.first_country,
        rev.media_source,
        rev.new_users,
        CASE when install > 0 then spend.spend/spend.install else -1 end as CPI,
        CASE when new_users > 0 then rev.rev7/new_users else -1 end as LTV7,
        CASE when new_users > 0 then rev.rev14/new_users else -1 end as LTV14,
        CASE when new_users > 0 then rev.rev30/new_users else -1 end as LTV30,
        CASE when new_users > 0 then rev.rev90/new_users else -1 end as LTV90,
        CASE when new_users > 0 then rev.rev120/new_users else -1 end as LTV120,
    FROM
        (SELECT
            u.create_month as create_month,
            u.first_country,
            CASE when u.media_source in ('Organic','organic') then 'Organic' else u.media_source end as media_source,
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
                media_source,
                unique_user_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
            WHERE create_date between '2020-11-01' and '2021-03-31'
            AND first_country in ('Russia','Brazil','United States','Germany','Turkey','France','Mexico','Italy','Spain','South Korea','United Kingdom',
                'India','Japan','Ukraine','Kazakhstan','Poland','Indonesia','Canada','Chile','Australia')
            AND media_source in ('unityads_int','googleadwords_int','Facebook Ads','Organic','organic')) u
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
        GROUP BY 1,2,3) rev
    LEFT JOIN
        (SELECT
            date_trunc(spend.date,month) as create_month
            ,c.country as first_country
            ,CASE WHEN spend.media_source = 'unity' THEN 'unityads_int'
                WHEN spend.media_source = 'facebook' THEN 'Facebook Ads'
                WHEN spend.media_source = 'adwords' THEN 'googleadwords_int'
                ELSE 'Other' END as media_source
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
        GROUP BY 1,2,3) spend
    ON spend.create_month = rev.create_month
    AND spend.first_country = rev.first_country
    AND spend.media_source = rev.media_source)
ORDER BY 1,2,3;

-- Sudoku
SELECT
    create_month,
    first_country,
    media_source,
    new_users,
    CPI,
    LTV7,
    LTV14,
    LTV30,
    LTV90,
    LTV120,
    CASE when CPI > 0 then LTV7/CPI else -1 end as ROC7,
    CASE when CPI > 0 then LTV14/CPI else -1 end as ROC14,
    CASE when CPI > 0 then LTV30/CPI else -1 end as ROC30,
    CASE when CPI > 0 then LTV90/CPI else -1 end as ROC90,
    CASE when CPI > 0 then LTV120/CPI else -1 end as ROC120
FROM
    (SELECT
        rev.create_month,
        rev.first_country,
        rev.media_source,
        rev.new_users,
        CASE when install > 0 then spend.spend/spend.install else -1 end as CPI,
        CASE when new_users > 0 then rev.rev7/new_users else -1 end as LTV7,
        CASE when new_users > 0 then rev.rev14/new_users else -1 end as LTV14,
        CASE when new_users > 0 then rev.rev30/new_users else -1 end as LTV30,
        CASE when new_users > 0 then rev.rev90/new_users else -1 end as LTV90,
        CASE when new_users > 0 then rev.rev120/new_users else -1 end as LTV120,
    FROM
        (SELECT
            u.create_month as create_month,
            u.first_country,
            CASE when u.media_source in ('Organic','organic') then 'Organic' else u.media_source end as media_source,
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
                media_source,
                unique_user_id
            FROM `sudoku-a782f.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
            WHERE create_date between '2020-11-01' and '2021-03-31'
            AND first_country in ('United States','Germany','Russia','Japan','India','France','Brazil','Spain','Mexico','United Kingdom','Ukraine',
                'Poland','Colombia','Turkey','Canada','Italy','South Korea','Iran','Netherlands','Argentina')
            AND media_source in ('unityads_int','googleadwords_int','Facebook Ads','Organic','organic')) u
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
        GROUP BY 1,2,3) rev
    LEFT JOIN
        (SELECT
            date_trunc(spend.date,month) as create_month
            ,c.country as first_country
            ,CASE WHEN spend.media_source = 'unity' THEN 'unityads_int'
                WHEN spend.media_source = 'facebook' THEN 'Facebook Ads'
                WHEN spend.media_source = 'adwords' THEN 'googleadwords_int'
                ELSE 'Other' END as media_source
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
        GROUP BY 1,2,3) spend
    ON spend.create_month = rev.create_month
    AND spend.first_country = rev.first_country
    AND spend.media_source = rev.media_source)
ORDER BY 1,2,3;