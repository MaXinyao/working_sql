-- iOS
SELECT
    u.first_country,
    COUNT(distinct u.unique_user_id) as new_users,
    -- SUM(CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then a.total_revenue else 0 end) as revenue120,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then CONCAT(a.date, a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt120,
    SUM(CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) and u.media_source != 'Organic' then a.total_revenue else 0 end)/COUNT(distinct u.unique_user_id) as ltv120_ua,
    SUM(CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then a.total_revenue else 0 end)/COUNT(distinct u.unique_user_id) as ltv120
FROM
    (SELECT
        distinct create_date,
        first_country,
        CASE when media_source in ('Organic','organic') then 'Organic' else media_source end as media_source,
        unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a`
    WHERE first_country in ('Iran','Chile','Egypt','India','Italy','Japan','Libya','Qatar','Spain','Brazil','Canada','Cyprus','France','Greece','Israel','Jordan',
        'Kuwait','Mexico','Norway','Poland','Russia','Sweden','Taiwan','Turkey','Armenia','Austria','Belarus','Belgium','Croatia','Czechia','Denmark',
        'Finland','Germany','Hungary','Ireland','Lebanon','Morocco','Nigeria','Romania','Tunisia','Ukraine','Colombia','Malaysia','Pakistan','Portugal','Réunion',
        'Thailand','Argentina','Australia','Hong Kong','Indonesia','Singapore','Azerbaijan','Kazakhstan','Kyrgyzstan','Luxembourg','Uzbekistan','Netherlands',
        'New Zealand','Philippines','Puerto Rico','Switzerland','Saudi Arabia','South Africa','United States','United Kingdom','Dominican Republic','United Arab Emirates')
    AND create_date between '2020-11-01' and '2020-11-30') u
LEFT JOIN
    (SELECT
        date,
        unique_user_id,
        ifnull(SUM(ad_revenue),0)+ifnull(SUM(pur_revenue),0) as total_revenue
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date >= '2020-11-01'
    GROUP BY 1,2) a
ON u.unique_user_id = a.unique_user_id
GROUP BY 1;

-- Android
SELECT
    u.first_country,
    COUNT(distinct u.unique_user_id) as new_users,
    -- SUM(CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then a.total_revenue else 0 end) as revenue120,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then CONCAT(a.date, a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt120,
    SUM(CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) and u.media_source != 'Organic' then a.total_revenue else 0 end)/COUNT(distinct u.unique_user_id) as ltv120_ua,
    SUM(CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then a.total_revenue else 0 end)/COUNT(distinct u.unique_user_id) as ltv120
FROM
    (SELECT
        distinct create_date,
        first_country,
        CASE when media_source in ('Organic','organic') then 'Organic' else media_source end as media_source,
        unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE first_country in ('United States',
        'Russia','Brazil','Germany','Mexico','Italy','France','Japan','Turkey','Spain','United Kingdom','South Korea','India','Ukraine','Canada','Poland','Australia','Indonesia',
        'Portugal','Austria','Argentina','Netherlands','Saudi Arabia','Kazakhstan','Vietnam','Iran','Switzerland','Israel','Belgium','Chile','United Arab Emirates','Sweden',
        'Czechia','Taiwan','Finland','South Africa','Colombia','Egypt','Thailand','Slovakia','Ireland','Greece','Romania','Belarus','Venezuela','Tunisia','Denmark',
        'Azerbaijan','Philippines','Malaysia','Norway','Guatemala','Moldova','Uzbekistan','Hong Kong','Peru','Puerto Rico','Morocco','Lithuania','Myanmar (Burma)','Pakistan',
        'Hungary','Slovenia','Croatia','Kyrgyzstan','Palestine','New Zealand','Réunion','Armenia','Ecuador','Singapore','Dominican Republic','Georgia','Algeria','Uruguay','Serbia',
        'Costa Rica','Syria','Jordan','Oman','Bolivia','Lebanon','Iraq','Latvia','Estonia','Bangladesh','China','North Macedonia','Paraguay','Luxembourg','Cyprus',
        'Bulgaria','Kuwait','Bosnia & Herzegovina','Turkmenistan','Panama','Mongolia','El Salvador','Qatar','Cambodia','Albania','Tajikistan','Honduras','Libya','Bahrain')
    AND create_date between '2020-11-01' and '2020-11-30') u
LEFT JOIN
    (SELECT
        date,
        unique_user_id,
        ifnull(SUM(ad_revenue),0)+ifnull(SUM(pur_revenue),0) as total_revenue
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date >= '2020-11-01'
    GROUP BY 1,2) a
ON u.unique_user_id = a.unique_user_id
GROUP BY 1;