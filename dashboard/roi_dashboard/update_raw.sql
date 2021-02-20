WITH 
-- 使用平台返回的数据计算投放消耗
-- 计算消耗的写法与BI统一，同一账号可能在不同平台进行投放
spend as (
    SELECT
        spend.date
        ,CASE WHEN app.production_id = '5d0b34d6883d6a000119ed23' THEN 'Android' ELSE 'iOS' END as platform
        ,c.country
        ,CASE WHEN spend.media_source = 'unity' THEN 'unityads_int'
            WHEN spend.media_source = 'applovin' THEN 'applovin_int'
            WHEN spend.media_source = 'vungle' THEN 'vungle_int'
            WHEN spend.media_source = 'toutiao' THEN 'bytedance_int'
            WHEN spend.media_source = 'facebook' THEN 'Facebook Ads'
            WHEN spend.media_source = 'adwords' THEN 'googleadwords_int'
            WHEN spend.media_source = 'snapchat' THEN 'snapchat_int'
            WHEN spend.media_source = 'mintegral' THEN 'mintegral_int'
            WHEN spend.media_source = 'kuaishou' THEN 'kuaishou_int'
            WHEN spend.media_source = 'ironsource' THEN 'ironsource_int'
            WHEN spend.media_source = 'apple' THEN 'Apple Search Ads'
            WHEN spend.media_source = 'chartboost' THEN 'chartboosts2s_int'
            WHEN spend.media_source = 'adcolony' THEN 'adcolony_int'
            WHEN spend.media_source = 'mistplay' THEN 'mistplay_int'
            WHEN spend.media_source = 'tencent' THEN 'tencent_int'
            ELSE 'Other' END as media_source
        ,SUM(spend.spend) as spend
        ,SUM(spend.install) as install
    FROM `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a` app
    INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_*` spend
    ON IFNULL(app.app_id,'-') = IFNULL(spend.app_id,'-')
    AND IFNULL(app.media_source,'-') = IFNULL(spend.media_source,'-')
    AND IFNULL(app.platform,'-') = IFNULL(spend.platform,'-')
    AND app.production_id in ('5d0b34d6883d6a000119ed23','5d0b3f971cd8ea0001e2473a')
    AND spend._table_suffix >= '20201001'
    AND IFNULL(app.store, '-') != 'instant_game'
    INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` c
    ON c.country_code = spend.country_code
    GROUP BY 1,2,3,4)
-- 使用分析表计算第一天、第七天累计和当日收入
,rev_ar as (
    SELECT
        u.create_date as date
        ,'Android' as platform
        ,u.first_country as country
        ,u.media_source
        ,SUM(CASE WHEN a.living_days = 1 THEN a.ad_revenue ELSE 0 END) as iaa_revenue_D1
        ,SUM(CASE WHEN a.living_days = 1 THEN a.pur_revenue ELSE 0 END) as iap_revenue_D1
        ,SUM(CASE WHEN a.living_days = 7 THEN a.ad_revenue ELSE 0 END) as iaa_revenue_D7
        ,SUM(CASE WHEN a.living_days = 7 THEN a.pur_revenue ELSE 0 END) as iap_revenue_D7
        ,SUM(CASE WHEN a.living_days <= 1 THEN a.ad_revenue ELSE 0 END) as iaa_revenue1
        ,SUM(CASE WHEN a.living_days <= 1 THEN a.pur_revenue ELSE 0 END) as iap_revenue1
        ,SUM(a.ad_revenue) as iaa_revenue7
        ,SUM(a.pur_revenue) as iap_revenue7
        ,SUM(CASE WHEN a.date = u.create_date AND a.app_remove = 1 THEN 1 ELSE 0 END) as ar1
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` a
    INNER JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a` u
    ON a.user_pseudo_id = u.user_pseudo_id
    WHERE u.create_date >= '2020-10-01'
    AND a.living_days <= 7
    AND a.date >= '2020-10-01'
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        u.create_date as date
        ,'iOS' as platform
        ,u.first_country as country
        ,u.media_source
        ,SUM(CASE WHEN a.living_days = 1 THEN a.ad_revenue ELSE 0 END) as iaa_revenue_D1
        ,SUM(CASE WHEN a.living_days = 1 THEN a.pur_revenue ELSE 0 END) as iap_revenue_D1
        ,SUM(CASE WHEN a.living_days = 7 THEN a.ad_revenue ELSE 0 END) as iaa_revenue_D7
        ,SUM(CASE WHEN a.living_days = 7 THEN a.pur_revenue ELSE 0 END) as iap_revenue_D7
        ,SUM(CASE WHEN a.living_days <= 1 THEN a.ad_revenue ELSE 0 END) as iaa_revenue1
        ,SUM(CASE WHEN a.living_days <= 1 THEN a.pur_revenue ELSE 0 END) as iap_revenue1
        ,SUM(a.ad_revenue) as iaa_revenue7
        ,SUM(a.pur_revenue) as iap_revenue7
        ,SUM(CASE WHEN a.date = u.create_date AND a.app_remove = 1 THEN 1 ELSE 0 END) as ar1
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` a
    INNER JOIN `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a` u
    ON a.user_pseudo_id = u.user_pseudo_id
    WHERE u.create_date >= '2020-10-01'
    AND a.living_days <= 7
    AND a.date >= '2020-10-01'
    GROUP BY 1,2,3,4)
-- 使用分析表计算新用户量和留存
,nu_retention as (
    SELECT
        u.create_date as date
        ,'Android' as platform
        ,u.first_country as country
        ,u.media_source
        ,COUNT(distinct u.user_pseudo_id) as nu
        ,COUNT(distinct r1.user_pseudo_id) as retention1_users
        ,COUNT(distinct r7.user_pseudo_id) as retention7_users
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a` u
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` r1
    ON u.user_pseudo_id = r1.user_pseudo_id
    AND r1.date = DATE_ADD(u.create_date, INTERVAL 1 DAY)
    AND r1.date >= '2020-10-01'
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` r7
    ON u.user_pseudo_id = r7.user_pseudo_id
    AND r7.date = DATE_ADD(u.create_date, INTERVAL 7 DAY)
    AND r7.date >= '2020-10-01'
    WHERE u.create_date >= '2020-10-01'
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        u.create_date as date
        ,'iOS' as platform
        ,u.first_country as country
        ,u.media_source
        ,COUNT(distinct u.user_pseudo_id) as nu
        ,COUNT(distinct r1.user_pseudo_id) as retention1_users
        ,COUNT(distinct r7.user_pseudo_id) as retention7_users
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a` u
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` r1
    ON u.user_pseudo_id = r1.user_pseudo_id
    AND r1.date = DATE_ADD(u.create_date, INTERVAL 1 DAY)
    AND r1.date >= '2020-10-01'
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` r7
    ON u.user_pseudo_id = r7.user_pseudo_id
    AND r7.date = DATE_ADD(u.create_date, INTERVAL 7 DAY)
    AND r7.date >= '2020-10-01'
    WHERE u.create_date >= '2020-10-01'
    GROUP BY 1,2,3,4)
-- 将以上三张源表汇总，成为一张最细粒度总表
-- 筛选国家和渠道
-- 对日期和平台做特殊处理，保证在没有join到的情况下，这两个字段依然不为空
,main as (
    SELECT
        CASE WHEN s.date is not null THEN s.date
            WHEN r.date is not null THEN r.date
            WHEN n.date is not null THEN n.date
            END as date
        ,CASE WHEN s.platform is not null THEN s.platform
            WHEN r.platform is not null THEN r.platform
            WHEN n.platform is not null THEN n.platform
            END as platform
        -- 写在case条件里而不是where条件里，是为了下面聚合全部国家数据的时候不会丢数据
        ,CASE WHEN n.country IN ('United States','Russia','Brazil','Germany','France')
            --其他投放也需要关注，但是因为google sheet数据量限制无法放入看板的国家
            -- 'Argentina','Australia','Belgium','Canada','Chile','Colombia','Spain',
            -- 'United Kingdom','Hong Kong','Indonesia','Israel','India','Italy','Japan','South Korea','Kazakhstan',
            -- 'Mexico','Netherlands','Peru','Poland','Saudi Arabia','Singapore','Turkey','Taiwan','Ukraine',
            -- 'South Africa'
            THEN n.country
            ELSE 'Other' END as country
        ,CASE WHEN n.media_source IN ('Organic','unityads_int','applovin_int','vungle_int','bytedance_int','Facebook Ads','googleadwords_int',
            'snapchat_int','mintegral_int','kuaishou_int','ironsource_int','Apple Search Ads','chartboosts2s_int','adcolony_int',
            'mistplay_int','tencent_int') 
            THEN n.media_source 
            ELSE 'Other' END as media_source
        ,SUM(n.nu) as nu
        ,SUM(s.spend) as spend
        ,SUM(s.install) as install
        ,SUM(r.iaa_revenue1) as iaa_revenue1
        ,SUM(r.iap_revenue1) as iap_revenue1
        ,SUM(r.iaa_revenue7) as iaa_revenue7
        ,SUM(r.iap_revenue7) as iap_revenue7
        ,SUM(r.iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(r.iap_revenue_D1) as iap_revenue_D1
        ,SUM(r.iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(r.iap_revenue_D7) as iap_revenue_D7
        ,SUM(n.retention1_users) as retention1_users
        ,SUM(n.retention7_users) as retention7_users
        ,SUM(r.ar1) as ar1_users
    FROM nu_retention n
    FULL OUTER JOIN rev_ar r
    ON n.date = r.date
    AND n.platform = r.platform
    AND n.country = r.country
    AND n.media_source = r.media_source
    FULL OUTER JOIN spend s
    ON s.date = n.date
    AND s.platform = n.platform
    AND s.country = n.country
    AND s.media_source = n.media_source
    GROUP BY 1,2,3,4)
-- 以总表为基础，计算每个维度交叉聚合的结果
,group_all as (
    SELECT
        date
        ,'All' as platform
        ,'All' as country
        ,'All' as media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,'All' as platform
        ,'All' as country
        ,media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,'All' as platform
        ,country
        ,'All' as media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,platform
        ,'All' as country
        ,'All' as media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,platform
        ,country
        ,'All' as media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,platform
        ,'All' as country
        ,media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,'All' as platform
        ,country
        ,media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4
    UNION ALL
    SELECT
        date
        ,platform
        ,country
        ,media_source
        ,SUM(nu) as nu
        ,SUM(spend) as spend
        ,SUM(install) as install
        ,SUM(iaa_revenue1) as iaa_revenue1
        ,SUM(iap_revenue1) as iap_revenue1
        ,SUM(iaa_revenue7) as iaa_revenue7
        ,SUM(iap_revenue7) as iap_revenue7
        ,SUM(iaa_revenue_D1) as iaa_revenue_D1
        ,SUM(iap_revenue_D1) as iap_revenue_D1
        ,SUM(iaa_revenue_D7) as iaa_revenue_D7
        ,SUM(iap_revenue_D7) as iap_revenue_D7
        ,SUM(retention1_users) as retention1_users
        ,SUM(retention7_users) as retention7_users
        ,SUM(ar1_users) as ar1_users
    FROM main
    GROUP BY 1,2,3,4)
-- 报表数据
-- 将国家和渠道是Other的隐藏掉
-- 利用算好的收入等数据计算cpi、roi、arpu、retention
SELECT
    date
    ,platform
    ,country
    ,media_source
    ,nu
    ,spend
    -- need to delete
    ,IFNULL(iaa_revenue1,0)+IFNULL(iap_revenue1,0) as rev1
    ,IFNULL(iaa_revenue_D1,0)+IFNULL(iap_revenue_D1,0) as rev_D1
    ,retention1_users
    -- need to delete
    ,CASE WHEN install != 0 THEN CAST(spend as FLOAT64)/install ELSE 0 END as cpi
    ,CASE WHEN spend != 0 THEN CAST(IFNULL(iaa_revenue1,0)+IFNULL(iap_revenue1,0) as FLOAT64)/spend ELSE 0 END as roi1
    ,CASE WHEN spend != 0 THEN CAST(IFNULL(iaa_revenue7,0)+IFNULL(iap_revenue7,0) as FLOAT64)/spend ELSE 0 END as roi7
    ,CASE WHEN nu != 0 THEN CAST(retention1_users as FLOAT64)/nu ELSE 0 END as nu_retention1
    ,CASE WHEN nu != 0 THEN CAST(retention7_users as FLOAT64)/nu ELSE 0 END as nu_retention7
    ,CASE WHEN retention1_users != 0 THEN CAST(IFNULL(iaa_revenue_D1,0)+IFNULL(iap_revenue_D1,0) as FLOAT64)/retention1_users ELSE 0 END as arpu1
    ,CASE WHEN retention7_users != 0 THEN CAST(IFNULL(iaa_revenue_D7,0)+IFNULL(iap_revenue_D7,0) as FLOAT64)/retention7_users ELSE 0 END as arpu7
    ,CASE WHEN nu != 0 THEN CAST(ar1_users as FLOAT64)/nu ELSE 0 END as ar1
FROM group_all
WHERE country != 'Other'
AND media_source != 'Other'
AND date is not null
ORDER BY 1,2,3,4