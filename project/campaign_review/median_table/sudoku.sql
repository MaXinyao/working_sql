CREATE TABLE `sudoku-a782f.warehouse.campaign_review_android_median_table_di` (
    date DATE OPTIONS(description="Natural date"),
    create_date DATE OPTIONS(description="User create date"),
    ua_cost FLOAT64 OPTIONS(description="ua_cost"),
    campaign_name STRING OPTIONS(description="Campaign Name"),
    campaign_id STRING OPTIONS(description="Campaign ID"),
    first_country STRING OPTIONS(description="Country when created"),
    media_source STRING OPTIONS(description="Media Source"),
    living_days INT64 OPTIONS(description="Date diff between create_date and date"),
    rev FLOAT64 OPTIONS(description="Revenue of the campaign in this living days"),
    retended INT64 OPTIONS(description="Users"),
    duration_sec FLOAT64 OPTIONS(description="Duration(s)"),
    game_start FLOAT64 OPTIONS(description="开始"),
    game_finish FLOAT64 OPTIONS(description="完成"),
    fill_num FLOAT64 OPTIONS(description="填数"),
    fill_error_num FLOAT64 OPTIONS(description="填错误的次数"),
    prop_usage FLOAT64 OPTIONS(description="道具消耗数量")
    )
PARTITION BY
    date
OPTIONS (
    description="median table of campaign review",
    labels=[("project", "campaign_review")]);

-- 单天插入
MERGE INTO `sudoku-a782f.warehouse.campaign_review_android_median_table_di` ltv
USING 
    (SELECT
        u.create_date
        ,u.campaign_name as campaign_name
        ,u.campaign_id as campaign_id
        ,u.date
        ,u.first_country
        ,media_source
        ,AVG(u.ua_cost) as ua_cost
        ,DATE_DIFF(u.date, u.create_date, DAY) as living_days
        ,SUM(rev.retended) as retended
        ,IFNULL(SUM(rev.ad_revenue),0)+IFNULL(SUM(rev.pur_revenue),0) as rev
        ,SUM(IFNULL(rev.duration,0)) as duration_sec
        ,SUM(IFNULL(rev.game_num,0)) as game_start
        ,SUM(IFNULL(rev.success_num,0)) as game_finish
        ,SUM(IFNULL(rev.fill_num,0)) as fill_num
        ,SUM(IFNULL(rev.fill_error_num,0)) as fill_error_num
        ,SUM(IFNULL(rev.prop_usage,0)) as prop_usage
    FROM (
        SELECT 
            create_date
            ,campaign_name 
            ,campaign_id 
            ,first_country
            ,media_source
            ,unique_user_id 
            ,ua_cost
            ,dt as date
        FROM `sudoku-a782f.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`,
        UNNEST(GENERATE_DATE_ARRAY(DATE_ADD(@run_date, INTERVAL -2 DAY), DATE_ADD(@run_date, INTERVAL -2 DAY))) as dt
        WHERE create_date BETWEEN '2020-09-01' AND DATE_ADD(@run_date, INTERVAL -2 DAY)
        ) u 
    LEFT JOIN
        (SELECT 
            unique_user_id 
            ,date
            ,1 as retended
            ,IFNULL(SUM(ad_revenue),0) as ad_revenue
            ,IFNULL(SUM(pur_revenue),0) as pur_revenue
            ,IFNULL(SUM(duration)/1000,0) AS duration
            ,IFNULL(SUM(game_num),0) AS game_num
            ,IFNULL(SUM(success_num),0) AS success_num
            ,IFNULL(sum(fill_num),0) AS fill_num
            ,IFNULL(SUM(fill_error_num),0) AS fill_error_num
            ,IFNULL(SUM(prop_usage),0) AS prop_usage
        FROM `sudoku-a782f.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
        WHERE date BETWEEN DATE_ADD(@run_date, INTERVAL -2 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY)
        GROUP BY 1,2,3) rev
    ON u.date = rev.date
    AND u.unique_user_id = rev.unique_user_id
    WHERE (u.campaign_name is not null 
        OR u.media_source in ('Organic','organic'))
    AND DATE_DIFF(u.date, u.create_date, DAY) >= 0
    AND ua_cost is not null
    GROUP BY 1,2,3,4,5,6,8) n
ON n.create_date = ltv.create_date
AND n.campaign_id = ltv.campaign_id
AND n.campaign_name = ltv.campaign_name
AND n.date = ltv.date
AND n.first_country = ltv.first_country
AND n.media_source = ltv.media_source
WHEN MATCHED THEN
    UPDATE SET rev = n.rev
        ,ua_cost = n.ua_cost
        ,retended = n.retended
        ,duration_sec = n.duration_sec
        ,game_start = n.game_start
        ,game_finish = n.game_finish
        ,fill_num = n.fill_num
        ,fill_error_num = n.fill_error_num
        ,prop_usage = n.prop_usage
WHEN NOT MATCHED THEN
    INSERT (create_date, campaign_name, campaign_id, date, first_country, media_source, ua_cost, living_days, retended,
        rev, duration_sec, game_start,game_finish,fill_num,fill_error_num,prop_usage) 
    VALUES(create_date, campaign_name, campaign_id, date, first_country, media_source, ua_cost, living_days, retended,
        rev, duration_sec, game_start,game_finish,fill_num,fill_error_num,prop_usage)

-- 每日更新
MERGE INTO `sudoku-a782f.warehouse.campaign_review_android_median_table_di` ltv
USING 
    (SELECT
        u.create_date
        ,u.campaign_name as campaign_name
        ,u.campaign_id as campaign_id
        ,u.date
        ,u.first_country
        ,media_source
        ,AVG(u.ua_cost) as ua_cost
        ,DATE_DIFF(u.date, u.create_date, DAY) as living_days
        ,SUM(rev.retended) as retended
        ,IFNULL(SUM(rev.ad_revenue),0)+IFNULL(SUM(rev.pur_revenue),0) as rev
        ,SUM(IFNULL(rev.duration,0)) as duration_sec
        ,SUM(IFNULL(rev.game_num,0)) as game_start
        ,SUM(IFNULL(rev.success_num,0)) as game_finish
        ,SUM(IFNULL(rev.fill_num,0)) as fill_num
        ,SUM(IFNULL(rev.fill_error_num,0)) as fill_error_num
        ,SUM(IFNULL(rev.prop_usage,0)) as prop_usage
    FROM (
        SELECT 
            create_date
            ,campaign_name 
            ,campaign_id 
            ,first_country
            ,media_source
            ,unique_user_id 
            ,ua_cost
            ,dt as date
        FROM `sudoku-a782f.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`,
        UNNEST(GENERATE_DATE_ARRAY(DATE_ADD(@run_date, INTERVAL -4 DAY), DATE_ADD(@run_date, INTERVAL -2 DAY))) as dt
        WHERE create_date BETWEEN '2020-09-01' AND DATE_ADD(@run_date, INTERVAL -2 DAY)
        ) u 
    LEFT JOIN
        (SELECT 
            unique_user_id 
            ,date
            ,1 as retended
            ,IFNULL(SUM(ad_revenue),0) as ad_revenue
            ,IFNULL(SUM(pur_revenue),0) as pur_revenue
            ,IFNULL(SUM(duration)/1000,0) AS duration
            ,IFNULL(SUM(game_num),0) AS game_num
            ,IFNULL(SUM(success_num),0) AS success_num
            ,IFNULL(sum(fill_num),0) AS fill_num
            ,IFNULL(SUM(fill_error_num),0) AS fill_error_num
            ,IFNULL(SUM(prop_usage),0) AS prop_usage
        FROM `sudoku-a782f.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
        WHERE date BETWEEN DATE_ADD(@run_date, INTERVAL -4 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY)
        GROUP BY 1,2,3) rev
    ON u.date = rev.date
    AND u.unique_user_id = rev.unique_user_id
    WHERE (u.campaign_name is not null 
        OR u.media_source in ('Organic','organic'))
    AND DATE_DIFF(u.date, u.create_date, DAY) >= 0
    AND ua_cost is not null
    GROUP BY 1,2,3,4,5,6,8) n
ON n.create_date = ltv.create_date
AND n.campaign_id = ltv.campaign_id
AND n.campaign_name = ltv.campaign_name
AND n.date = ltv.date
AND n.first_country = ltv.first_country
AND n.media_source = ltv.media_source
WHEN MATCHED THEN
    UPDATE SET rev = n.rev
        ,ua_cost = n.ua_cost
        ,retended = n.retended
        ,duration_sec = n.duration_sec
        ,game_start = n.game_start
        ,game_finish = n.game_finish
        ,fill_num = n.fill_num
        ,fill_error_num = n.fill_error_num
        ,prop_usage = n.prop_usage
WHEN NOT MATCHED THEN
    INSERT (create_date, campaign_name, campaign_id, date, first_country, media_source, ua_cost, living_days, retended,
        rev, duration_sec, game_start,game_finish,fill_num,fill_error_num,prop_usage) 
    VALUES(create_date, campaign_name, campaign_id, date, first_country, media_source, ua_cost, living_days, retended,
        rev, duration_sec, game_start,game_finish,fill_num,fill_error_num,prop_usage)