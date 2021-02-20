SELECT 
    fea_x.create_date
    ,fea_x.first_country
    ,fea_x.campaign_name
    ,fea_x.ua_cost
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.r1users/fea_x.newusers ELSE 0 END AS retention1
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.r2users/fea_x.newusers ELSE 0 END AS retention2
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.r3users/fea_x.newusers ELSE 0 END AS retention3
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.rev0/fea_x.newusers ELSE 0 END AS arpu0
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.rev1/fea_x.r1users ELSE 0 END AS arpu1
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.rev2/fea_x.r2users ELSE 0 END AS arpu2
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.rev3/fea_x.r3users ELSE 0 END AS arpu3
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.duration_sec0/fea_x.newusers ELSE 0 END AS duration_sec0_pu
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.duration_sec1/fea_x.r1users ELSE 0 END AS duration_sec1_pu
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.duration_sec2/fea_x.r2users ELSE 0 END AS duration_sec2_pu
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.duration_sec3/fea_x.r3users ELSE 0 END AS duration_sec3_pu
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.crush_rows0/fea_x.newusers ELSE 0 END AS crush_rows0_pu
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.crush_rows1/fea_x.r1users ELSE 0 END AS crush_rows1_pu
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.crush_rows2/fea_x.r2users ELSE 0 END AS crush_rows2_pu
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.crush_rows3/fea_x.r3users ELSE 0 END AS crush_rows3_pu
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.crush_times0/fea_x.newusers ELSE 0 END AS crush_times0_pu
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.crush_times1/fea_x.r1users ELSE 0 END AS crush_times1_pu
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.crush_times2/fea_x.r2users ELSE 0 END AS crush_times2_pu
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.crush_times3/fea_x.r3users ELSE 0 END AS crush_times3_pu
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.combo_times0/fea_x.newusers ELSE 0 END AS combo_times0_pu
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.combo_times1/fea_x.r1users ELSE 0 END AS combo_times1_pu
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.combo_times2/fea_x.r2users ELSE 0 END AS combo_times2_pu
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.combo_times3/fea_x.r3users ELSE 0 END AS combo_times3_pu
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.game_num0/fea_x.newusers ELSE 0 END AS game_num0_pu
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.game_num1/fea_x.r1users ELSE 0 END AS game_num1_pu
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.game_num2/fea_x.r2users ELSE 0 END AS game_num2_pu
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.game_num3/fea_x.r3users ELSE 0 END AS game_num3_pu
    ,CASE WHEN fea_x.newusers > 0 THEN fea_x.best_record0/fea_x.newusers ELSE 0 END AS best_record0_pu
    ,CASE WHEN fea_x.r1users > 0 THEN fea_x.best_record1/fea_x.r1users ELSE 0 END AS best_record1_pu
    ,CASE WHEN fea_x.r2users > 0 THEN fea_x.best_record2/fea_x.r2users ELSE 0 END AS best_record2_pu
    ,CASE WHEN fea_x.r3users > 0 THEN fea_x.best_record3/fea_x.r3users ELSE 0 END AS best_record3_pu
    ,y.living_days
    ,y.sum_rev
    ,CASE WHEN fea_x.newusers > 0 THEN y.sum_rev/fea_x.newusers ELSE 0 END AS ltv
FROM
    (SELECT 
        create_date
        ,first_country
        ,campaign_name
        ,AVG(ua_cost) ua_cost
        ,SUM(CASE WHEN living_days = 0 THEN retended ELSE 0 END) AS newusers 
        ,SUM(CASE WHEN living_days = 1 THEN retended ELSE 0 END) AS r1users 
        ,SUM(CASE WHEN living_days = 2 THEN retended ELSE 0 END) AS r2users 
        ,SUM(CASE WHEN living_days = 3 THEN retended ELSE 0 END) AS r3users 
        ,SUM(CASE WHEN living_days = 0 THEN rev ELSE 0 END) AS rev0 
        ,SUM(CASE WHEN living_days = 1 THEN rev ELSE 0 END) AS rev1 
        ,SUM(CASE WHEN living_days = 2 THEN rev ELSE 0 END) AS rev2 
        ,SUM(CASE WHEN living_days = 3 THEN rev ELSE 0 END) AS rev3 
        ,SUM(CASE WHEN living_days = 0 THEN duration_sec ELSE 0 END) AS duration_sec0 
        ,SUM(CASE WHEN living_days = 1 THEN duration_sec ELSE 0 END) AS duration_sec1 
        ,SUM(CASE WHEN living_days = 2 THEN duration_sec ELSE 0 END) AS duration_sec2 
        ,SUM(CASE WHEN living_days = 3 THEN duration_sec ELSE 0 END) AS duration_sec3 
        ,SUM(CASE WHEN living_days = 0 THEN crush_rows ELSE 0 END) AS crush_rows0 
        ,SUM(CASE WHEN living_days = 1 THEN crush_rows ELSE 0 END) AS crush_rows1 
        ,SUM(CASE WHEN living_days = 2 THEN crush_rows ELSE 0 END) AS crush_rows2 
        ,SUM(CASE WHEN living_days = 3 THEN crush_rows ELSE 0 END) AS crush_rows3 
        ,SUM(CASE WHEN living_days = 0 THEN crush_times ELSE 0 END) AS crush_times0 
        ,SUM(CASE WHEN living_days = 1 THEN crush_times ELSE 0 END) AS crush_times1 
        ,SUM(CASE WHEN living_days = 2 THEN crush_times ELSE 0 END) AS crush_times2 
        ,SUM(CASE WHEN living_days = 3 THEN crush_times ELSE 0 END) AS crush_times3 
        ,SUM(CASE WHEN living_days = 0 THEN combo_times ELSE 0 END) AS combo_times0 
        ,SUM(CASE WHEN living_days = 1 THEN combo_times ELSE 0 END) AS combo_times1 
        ,SUM(CASE WHEN living_days = 2 THEN combo_times ELSE 0 END) AS combo_times2 
        ,SUM(CASE WHEN living_days = 3 THEN combo_times ELSE 0 END) AS combo_times3 
        ,SUM(CASE WHEN living_days = 0 THEN game_num ELSE 0 END) AS game_num0 
        ,SUM(CASE WHEN living_days = 1 THEN game_num ELSE 0 END) AS game_num1 
        ,SUM(CASE WHEN living_days = 2 THEN game_num ELSE 0 END) AS game_num2 
        ,SUM(CASE WHEN living_days = 3 THEN game_num ELSE 0 END) AS game_num3 
        ,SUM(CASE WHEN living_days = 0 THEN best_record ELSE 0 END) AS best_record0 
        ,SUM(CASE WHEN living_days = 1 THEN best_record ELSE 0 END) AS best_record1 
        ,SUM(CASE WHEN living_days = 2 THEN best_record ELSE 0 END) AS best_record2 
        ,SUM(CASE WHEN living_days = 3 THEN best_record ELSE 0 END) AS best_record3 
    FROM 
        (SELECT  
            * 
        FROM `blockpuzzle-f21e1.warehouse.campaign_review_android_median_table_di`
        WHERE living_days BETWEEN 0 AND 3 
        AND first_country is not null)
    GROUP BY 1,2,3) fea_x 
JOIN (
    SELECT 
        mix.create_date
        ,mix.campaign_name
        ,mix.first_country
        ,mix.living_days
        ,mix.sum_rev
    FROM
        (SELECT 
            *
            ,SUM(rev) over(partition by create_date,campaign_name,first_country 
                order by living_days ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as sum_rev
        FROM 
            (SELECT  
                create_date 
                ,campaign_name 
                ,first_country 
                ,living_days 
                ,rev
            FROM `blockpuzzle-f21e1.warehouse.campaign_review_android_median_table_di`
            WHERE first_country is not null)
        ORDER BY 1,2,3,4) mix 
    WHERE mix.living_days in (30,60,90,120)) y 
ON fea_x.create_date = y.create_date
AND fea_x.campaign_name = y.campaign_name
AND fea_x.first_country = y.first_country 