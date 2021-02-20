with user as (SELECT
        date,
        CASE when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'Other' end as country,
        COUNT(distinct user_pseudo_id) as dau,
        COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as nu,
        COUNT(distinct CASE when living_days = 0 and media_source != 'Organic' then user_pseudo_id else null end) as ua_nu,
        COUNT(distinct CASE when living_days = 7 then user_pseudo_id else null end) as d7_retend,
        COUNT(distinct CASE when living_days = 7 and media_source = 'Organic' then user_pseudo_id else null end) as d7_organic_retend,
        SUM(crush_rows) as crush_rows
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between @date and DATE_ADD(@date, INTERVAL 6 day)
    GROUP BY 1,2),
rev as (SELECT 
        iaa.date,
        case when iaa.country_code = 'US' then 'United States'
            when iaa.country_code = 'GB' then 'United Kingdom'
            when iaa.country_code = 'DE' then 'Germany'
            when iaa.country_code = 'FR' then 'France'
            when iaa.country_code = 'ES' then 'Spain'
            when iaa.country_code = 'RU' then 'Russia'
            when iaa.country_code = 'JP' then 'Japan'
            when iaa.country_code = 'MX' then 'Mexico'
            when iaa.country_code = 'BR' then 'Brazil'
            else 'Other' end as country, 
        SUM(ifnull(iaa.revenue,0) + ifnull(iap.iap_revenue,0)) as total_revenue
    FROM 
        (SELECT 
            rev.date,
            country_code, 
            SUM(revenue) as revenue 
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app 
        INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev 
        ON app.app_id = rev.app_id 
        and ifnull(app.platform,'nt') = ifnull(rev.platform,'nt')
        and app.iaa_platform = rev.iaa_platform
        AND app.production_id IN ('5d0b34d6883d6a000119ed23') 
        AND rev.date between @date and DATE_ADD(@date, INTERVAL 6 day)
        GROUP BY 1,2) iaa 
    LEFT JOIN 
        (SELECT
            iap.date,
            country, 
            SUM(iap.revenue) as iap_revenue 
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app 
        JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap 
        ON iap.app_id = app.app_id 
        AND iap.date between @date and DATE_ADD(@date, INTERVAL 6 day)
        AND app.production_id IN ('5d0b34d6883d6a000119ed23') 
        GROUP BY 1,2) iap 
    ON iap.country = iaa.country_code 
    AND iap.date = iaa.date
    GROUP BY date, country),
retention as (SELECT
        date,
        CASE when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'Other' end as country,
        COUNT(distinct user_pseudo_id) as d7_nu,
        COUNT(distinct case when media_source = 'Organic' then user_pseudo_id else null end) as d7_organic_nu
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between DATE_ADD(@date, INTERVAL -7 day) and DATE_ADD(@date, INTERVAL -1 day)
    and living_days = 0
    GROUP BY 1,2)
SELECT
    user.date,
    user.country,
    user.crush_rows,
    user.dau,
    CAST(rev.total_revenue as float64)/user.dau as arpu,
    user.nu,
    user.ua_nu,
    CAST(user.d7_retend AS float64)/retention.d7_nu as d7_retention,
    CAST(user.d7_organic_retend AS float64)/retention.d7_organic_nu as d7_organic_retention,
    retention.d7_nu,
    user.d7_retend,
    retention.d7_organic_nu,
    user.d7_organic_retend,
    rev.total_revenue
FROM user 
JOIN rev
ON rev.date = user.date
and rev.country = user.country
JOIN retention
ON retention.date = DATE_ADD(user.date, INTERVAL -7 DAY)
and retention.country = user.country