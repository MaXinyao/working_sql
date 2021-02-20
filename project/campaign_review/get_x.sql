create table if not exists `blockpuzzle-f21e1.warehouse.campaign_android_x` as 
SELECT 
    * 
FROM
    (SELECT 
        ua.create_date
        ,ua.campaign_name
        ,ua.first_country
        ,ua.CPI 
        ,max(CASE WHEN ua.living_days = 0 THEN users END) AS new_users
        ,max(CASE WHEN ua.living_days = 1 THEN users END) AS r1users
        ,max(CASE WHEN ua.living_days = 2 THEN users END) AS r2users
        ,max(CASE WHEN ua.living_days = 3 THEN users END) AS r3users
        ,SUM(CASE WHEN ua.living_days = 0 THEN ad END)+SUM(CASE WHEN ua.living_days = 0 THEN pur END) rev0
        ,SUM(CASE WHEN ua.living_days = 1 THEN ad END)+SUM(CASE WHEN ua.living_days = 1 THEN pur END) rev1
        ,SUM(CASE WHEN ua.living_days = 2 THEN ad END)+SUM(CASE WHEN ua.living_days = 2 THEN pur END) rev2
        ,SUM(CASE WHEN ua.living_days = 3 THEN ad END)+SUM(CASE WHEN ua.living_days = 3 THEN pur END) rev3
        ,SUM(CASE WHEN ua.living_days = 0 THEN duration END) AS duration0
        ,SUM(CASE WHEN ua.living_days = 1 THEN duration END) AS duration1
        ,SUM(CASE WHEN ua.living_days = 2 THEN duration END) AS duration2
        ,SUM(CASE WHEN ua.living_days = 3 THEN duration END) AS duration3
    FROM 
        (SELECT 
            u.create_date
            ,u.campaign_name
            ,u.first_country
            ,a.living_days
            ,COUNT(DISTINCT u.user_pseudo_id) AS users
            ,AVG(u.ua_cost) AS CPI
            ,IFNULL(SUM(a.ad_revenue),0) AS ad
            ,IFNULL(SUM(a.pur_revenue),0) AS pur
            ,SUM(a.duration)/1000 AS duration
        FROM (
            SELECT 
                create_date
                ,campaign_name 
                ,first_country
                ,user_pseudo_id 
                ,ua_cost
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a` 
            WHERE create_date BETWEEN '2020-09-01' AND DATE_ADD(@run_date, INTERVAL -2 DAY)
            ) u 
        JOIN (
            SELECT 
                user_pseudo_id 
                ,living_days  
                ,ad_revenue 
                ,pur_revenue
                ,duration
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
            WHERE date BETWEEN DATE_ADD(@run_date, INTERVAL -4 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY)
            AND living_days BETWEEN 0 AND 4) a 
        ON u.user_pseudo_id = a.user_pseudo_id 
        WHERE u.campaign_name is not null 
        AND first_country is not null 
        AND a.living_days is not null
        GROUP BY 1,2,3,4) ua 
    GROUP BY 1,2,3,4) mix
WHERE mix.new_users is not null 
AND mix.CPI>0