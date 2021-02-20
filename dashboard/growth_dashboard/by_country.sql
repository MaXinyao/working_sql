with dau as ( 
    SELECT 
        date, 
        'iOS' as platform, 
        case when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil',
                    'India','Argentina','Indonesia','Canada','Australia','Netherlands','Switzerland') then country else 'other' end as country,
        COUNT(distinct user_pseudo_id) as dau, 
        COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as new_users,
        SUM(crush_rows) as crush_rows,
        SUM(cast(duration as float64)/60000) as duration_min,
        count(distinct case when living_days = 0 and is_aha = 1 then user_pseudo_id else null end) as aha_users
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` 
    WHERE date between @date AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) 
    GROUP BY 1,2,3
    UNION ALL 
    SELECT 
        date,
        'Android' as platform, 
        case when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil',
                    'India','Argentina','Indonesia','Canada','Australia','Netherlands','Switzerland') then country else 'other' end as country,
        COUNT(distinct user_pseudo_id) as dau,
        COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as new_users,
        SUM(crush_rows) as crush_rows,
        SUM(cast(duration as float64)/60000) as duration_min,
        count(distinct case when living_days = 0 and is_aha = 1 then user_pseudo_id else null end) as aha_users
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
    WHERE date between @date AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) 
    GROUP BY 1,2,3
),
rev as (
    SELECT 
        iaa.date,
        iaa.platform, 
        case when m.country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil',
                    'India','Argentina','Indonesia','Canada','Australia','Netherlands','Switzerland') then m.country else 'other' end as country,
        SUM(ifnull(iaa.revenue,0) + ifnull(iap.iap_revenue,0)) as total_revenue
    FROM 
        (SELECT 
            rev.date,
            country_code, 
            case when app.production_id = '5d0b34d6883d6a000119ed23' then 'Android' else 'iOS' end as platform, 
            SUM(revenue) as revenue 
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app 
        INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev 
        ON app.app_id = rev.app_id 
        and ifnull(app.platform,'nt') = ifnull(rev.platform,'nt')
        and app.iaa_platform = rev.iaa_platform
        AND app.production_id IN ('5d0b3f971cd8ea0001e2473a','5d0b34d6883d6a000119ed23') 
        AND rev.date between @date AND DATE_ADD(@date, INTERVAL -2 DAY) 
        GROUP BY 1,2,3) iaa 
    LEFT JOIN 
        (SELECT
            iap.date,
            case when app.production_id = '5d0b34d6883d6a000119ed23' then 'Android' else 'iOS' end as platform, 
            country, 
            SUM(iap.revenue) as iap_revenue 
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app 
        JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap 
        ON iap.app_id = app.app_id 
        AND iap.date between @date AND DATE_ADD(@date, INTERVAL -2 DAY) 
        AND app.production_id IN ('5d0b3f971cd8ea0001e2473a','5d0b34d6883d6a000119ed23') 
        GROUP BY 1,2,3) iap 
    ON iap.platform = iaa.platform 
    AND iap.country = iaa.country_code 
    AND iap.date = iaa.date
    LEFT JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` m
    ON iaa.country_code = m.country_code
    GROUP BY date, country, iaa.platform
) 
SELECT
    date,
    CASE when platform is null then 'All' else platform end as platform,
    CASE when country is null then 'All' else country end as country,
    dau,
    new_users,
    total_revenue,
    case when dau > 0 then cast(total_revenue as float64)/dau else 0 end as arpu,
    crush_rows,
    case when dau > 0 then CAST(duration_min AS float64)/dau else 0 end as duration_pu,
    case when new_users > 0 then CAST(aha_users AS float64)/new_users else 0 end as aha_rate
FROM
    (SELECT
        dau.date,
        dau.platform,
        dau.country,
        SUM(dau.dau) as dau,
        SUM(dau.new_users) as new_users,
        SUM(rev.total_revenue) as total_revenue,
        SUM(dau.crush_rows) as crush_rows,
        SUM(dau.duration_min) as duration_min,
        SUM(dau.aha_users) as aha_users
    FROM dau dau
    LEFT JOIN rev rev
    ON dau.platform = rev.platform
    AND dau.country = rev.country
    AND dau.date = rev.date
    GROUP BY ROLLUP(date, country, platform)
    HAVING date is not null)
UNION all
SELECT
    dau.date,
    dau.platform,
    'All' as country,
    SUM(dau.dau) as dau,
    SUM(dau.new_users) as new_users,
    SUM(rev.total_revenue) as total_revenue,
    case when sum(dau.dau) > 0 then cast(SUM(rev.total_revenue) as float64)/SUM(dau.dau) else 0 end as arpu,
    SUM(dau.crush_rows) as crush_rows,
    case when sum(dau.dau) > 0 then SUM(dau.duration_min)/sum(dau.dau) else 0 end as duration_min,
    case when sum(dau.new_users) > 0 then SUM(dau.aha_users)/sum(dau.new_users) else 0 end as aha_users
FROM dau dau
LEFT JOIN rev rev
ON dau.platform = rev.platform
AND dau.country = rev.country
AND dau.date = rev.date
GROUP BY 1,2,3
order by date, platform, country