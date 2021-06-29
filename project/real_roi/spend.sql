SELECT
    month, 
    SUM(spend) as spend,
    SUM(CASE when country = 'United States' THEN spend ELSE 0 END) as us_spend,
    CASE when SUM(install) > 0 then SUM(spend)/SUM(install) else 0 end as cpi,
    SUM(CASE WHEN country = 'United States' THEN spend ELSE 0 END)/SUM(CASE WHEN country = 'United States' THEN install ELSE 0 END) as us_cpi,
    SUM(CASE WHEN media_source = 'Facebook Ads' THEN spend ELSE 0 END)/SUM(CASE WHEN media_source = 'Facebook Ads' THEN install ELSE 0 END) as fb_cpi,
    SUM(CASE WHEN media_source = 'Facebook Ads' AND country = 'United States' THEN spend ELSE 0 END)/SUM(CASE WHEN media_source = 'Facebook Ads' AND country = 'United States' THEN install ELSE 0 END) as us_fb_cpi,
    case when SUM(CASE WHEN media_source = 'googleadwords_int' THEN install ELSE 0 END) > 0 then 
        SUM(CASE WHEN media_source = 'googleadwords_int' THEN spend ELSE 0 END)/SUM(CASE WHEN media_source = 'googleadwords_int' THEN install ELSE 0 END) 
        else 0 end as adwords_cpi,
    case when SUM(CASE WHEN media_source = 'googleadwords_int' AND country = 'United States' THEN install ELSE 0 END) > 0 then
        SUM(CASE WHEN media_source = 'googleadwords_int' AND country = 'United States' THEN spend ELSE 0 END)/
        SUM(CASE WHEN media_source = 'googleadwords_int' AND country = 'United States' THEN install ELSE 0 END) else 0 end as us_adwords_cpi,
FROM
    (SELECT
        date_trunc(spend.date,month) as month
        ,CASE WHEN app.production_id = '5b84f58e689998000116d3fd' THEN 'Android' ELSE 'iOS' END as platform
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
    FROM 
        (SELECT 
            distinct app_id, 
            media_source, 
            platform, 
            production_id
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a`
        WHERE ifnull(store, '-') != 'instant_game'
        AND production_id in ('5b6d3b0543b43800015a5a87')) app
    INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_*` spend
    ON IFNULL(app.app_id,'-') = IFNULL(spend.app_id,'-')
    AND IFNULL(app.media_source,'-') = IFNULL(spend.media_source,'-')
    AND IFNULL(app.platform,'-') = IFNULL(spend.platform,'-')
    AND spend._table_suffix >= '20200901'
    INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` c
    ON c.country_code = spend.country_code
    GROUP BY 1,2,3,4)
WHERE platform = 'Android'
GROUP BY 1
ORDER BY 1