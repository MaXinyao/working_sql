-- CREATE TABLE `blockpuzzle-f21e1.warehouse.campaign_review_android_median_table_di` (
--     date DATE OPTIONS(description="Natural date"),
--     create_date DATE OPTIONS(description="User create date"),
--     ua_cost FLOAT64 OPTIONS(description="ua_cost"),
--     campaign_name STRING OPTIONS(description="Campaign Name"),
--     campaign_id STRING OPTIONS(description="Campaign ID"),
--     first_country STRING OPTIONS(description="Country when created"),
--     living_days INT64 OPTIONS(description="Date diff between create_date and date"),
--     rev FLOAT64 OPTIONS(description="Revenue of the campaign in this living days"),
--     retended INT64 OPTIONS(description="Users"),
--     duration_sec FLOAT64 OPTIONS(description="Duration(s)"),
--     crush_rows FLOAT64 OPTIONS(description="消除行数"),
--     crush_times FLOAT64 OPTIONS(description="消除次数"),
--     best_record FLOAT64 OPTIONS(description="最佳分数"),
--     combo_times FLOAT64 OPTIONS(description="combo times"),
--     game_num FLOAT64 OPTIONS(description="开局数")
--     )
-- PARTITION BY
--     date
-- OPTIONS (
--     description="median table of campaign review",
--     labels=[("project", "campaign_review")]);

MERGE INTO `blockpuzzle-f21e1.warehouse.campaign_review_android_median_table_di` ltv
USING 
    (SELECT
        u.create_date
        ,u.campaign_name as campaign_name
        ,u.campaign_id as campaign_id
        ,u.date
        ,u.first_country
        ,AVG(u.ua_cost) as ua_cost
        ,DATE_DIFF(u.date, u.create_date, DAY) as living_days
        ,SUM(rev.retended) as retended
        ,IFNULL(SUM(rev.ad_revenue),0)+IFNULL(SUM(rev.pur_revenue),0) as rev
        ,SUM(IFNULL(rev.duration,0)) as duration_sec
        ,SUM(IFNULL(rev.crush_rows,0)) as crush_rows
        ,SUM(IFNULL(rev.crush_times,0)) as crush_times
        ,SUM(IFNULL(rev.best_record,0)) as best_record
        ,SUM(IFNULL(rev.combo_times,0)) as combo_times
        ,SUM(IFNULL(rev.game_num,0)) as game_num
    FROM (
        SELECT 
            create_date
            ,campaign_name 
            ,campaign_id 
            ,first_country
            ,user_pseudo_id 
            ,ua_cost
            ,dt as date
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`,
        UNNEST(GENERATE_DATE_ARRAY(DATE_ADD(@run_date, INTERVAL -4 DAY), DATE_ADD(@run_date, INTERVAL -2 DAY))) as dt
        WHERE create_date BETWEEN '2020-09-01' AND DATE_ADD(@run_date, INTERVAL -2 DAY)
        ) u 
    LEFT JOIN
        (SELECT 
            user_pseudo_id 
            ,date
            ,1 as retended
            ,IFNULL(SUM(ad_revenue),0) as ad_revenue
            ,IFNULL(SUM(pur_revenue),0) as pur_revenue
            ,IFNULL(SUM(duration)/1000,0) AS duration
            ,IFNULL(SUM(crush_rows),0) AS crush_rows
            ,IFNULL(SUM(crush_times),0) AS crush_times
            ,IFNULL(MAX(best_record),0) AS best_record
            ,IFNULL(SUM(combo_times),0) AS combo_times
            ,IFNULL(SUM(game_num),0) AS game_num
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
        WHERE date BETWEEN DATE_ADD(@run_date, INTERVAL -4 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY)
        GROUP BY 1,2,3) rev
    ON u.date = rev.date
    AND u.user_pseudo_id = rev.user_pseudo_id
    WHERE (u.campaign_name is not null 
        OR u.campaign_id is not null)
    AND DATE_DIFF(u.date, u.create_date, DAY) >= 0
    AND ua_cost is not null
    GROUP BY 1,2,3,4,5,7) n
ON n.create_date = ltv.create_date
AND n.campaign_id = ltv.campaign_id
AND n.campaign_name = ltv.campaign_name
AND n.date = ltv.date
AND n.first_country = ltv.first_country
WHEN MATCHED THEN
    UPDATE SET rev = n.rev
        ,ua_cost = n.ua_cost
        ,retended = n.retended
        ,duration_sec = n.duration_sec
        ,crush_rows = n.crush_rows
        ,crush_times = n.crush_times
        ,best_record = n.best_record
        ,combo_times = n.combo_times
        ,game_num = n.game_num
WHEN NOT MATCHED THEN
    INSERT (create_date, campaign_name, campaign_id, date, first_country, ua_cost, living_days, retended,
        rev, duration_sec, crush_rows, crush_times, best_record, combo_times, game_num) 
    VALUES(create_date, campaign_name, campaign_id, date, first_country, ua_cost, living_days, retended,
        rev, duration_sec, crush_rows, crush_times, best_record, combo_times, game_num)
