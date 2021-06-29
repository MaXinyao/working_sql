-- PBN
SELECT
    u.create_month,
    u.first_country,
    CASE when u.media_source in ('Organic','organic') then 'Organic' else u.media_source end as media_source,
    COUNT(distinct u.unique_user_id) as new_users,
    -- COUNT(distinct CONCAT(a.date,a.unique_user_id)) as lt_users,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 7 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt7,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 14 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt14,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 30 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt30,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 90 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt90,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt120
FROM
    (SELECT
        distinct date_trunc(create_date,month) as create_month,
        create_date,
        media_source,
        first_country,
        unique_user_id
    FROM `paint-by-number-3c789.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE first_country in ('India','United States','Brazil','Russia','Germany','Mexico','France','Turkey','Indonesia','Poland','Egypt',
        'United Kingdom','Colombia','Ukraine','Spain','Argentina','Italy','Iran','Vietnam','Iraq')
    AND create_date between '2020-11-01' and '2021-03-31'
    AND media_source in ('unityads_int','googleadwords_int','Organic','organic','Facebook Ads')) u
LEFT JOIN
    (SELECT
        distinct date,
        unique_user_id
    FROM `paint-by-number-3c789.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date >= '2020-11-01') a
ON u.unique_user_id = a.unique_user_id
GROUP BY 1,2,3
ORDER BY 1,2 asc, 5 desc;

-- Qblock
SELECT
    u.create_month,
    u.first_country,
    CASE when u.media_source in ('Organic','organic') then 'Organic' else u.media_source end as media_source,
    COUNT(distinct u.unique_user_id) as new_users,
    -- COUNT(distinct CONCAT(a.date,a.unique_user_id)) as lt_users,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 7 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt7,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 14 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt14,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 30 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt30,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 90 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt90,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt120
FROM
    (SELECT
        distinct date_trunc(create_date,month) as create_month,
        create_date,
        media_source,
        first_country,
        unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE first_country in ('Russia','Brazil','United States','Germany','Turkey','France','Mexico','Italy','Spain','South Korea','United Kingdom',
        'India','Japan','Ukraine','Kazakhstan','Poland','Indonesia','Canada','Chile','Australia')
    AND create_date between '2020-11-01' and '2021-03-31'
    AND media_source in ('unityads_int','googleadwords_int','Organic','organic','Facebook Ads')) u
LEFT JOIN
    (SELECT
        distinct date,
        unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date >= '2020-11-01') a
ON u.unique_user_id = a.unique_user_id
GROUP BY 1,2,3
ORDER BY 1,2 asc, 5 desc;

-- Sudoku
SELECT
    u.create_month,
    u.first_country,
    CASE when u.media_source in ('Organic','organic') then 'Organic' else u.media_source end as media_source,
    COUNT(distinct u.unique_user_id) as new_users,
    -- COUNT(distinct CONCAT(a.date,a.unique_user_id)) as lt_users,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 7 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt7,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 14 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt14,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 30 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt30,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 90 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt90,
    COUNT(distinct CASE when a.date <= DATE_ADD(u.create_date, interval 120 day) then CONCAT(a.date,a.unique_user_id) else null end)/COUNT(distinct u.unique_user_id) as lt120
FROM
    (SELECT
        distinct date_trunc(create_date,month) as create_month,
        create_date,
        media_source,
        first_country,
        unique_user_id
    FROM `sudoku-a782f.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE first_country in ('United States','Germany','Russia','Japan','India','France','Brazil','Spain','Mexico','United Kingdom','Ukraine',
        'Poland','Colombia','Turkey','Canada','Italy','South Korea','Iran','Netherlands','Argentina')
    AND create_date between '2020-11-01' and '2021-03-31'
    AND media_source in ('unityads_int','googleadwords_int','Organic','organic','Facebook Ads')) u
LEFT JOIN
    (SELECT
        distinct date,
        unique_user_id
    FROM `sudoku-a782f.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date >= '2020-11-01') a
ON u.unique_user_id = a.unique_user_id
GROUP BY 1,2,3
ORDER BY 1,2 asc, 5 desc;