SELECT
    tag as tag,
    -- 活跃用户数
    COUNT(user_pseudo_id) as Count_user,
    -- 人均着色数
    AVG(count_finish) as Avg_finish,
    stddev(count_finish) as Std_finish,
    -- 人均开图数
    AVG(start_coloring) as Avg_start_coloring,
    stddev(start_coloring) as std_start_coloring,
    -- 素材完成率
    avg(rate_finish) as Avg_rate_finish,
    stddev(rate_finish) as std_rate_finish,
    -- 激励视频展示
    AVG(reward_show) as Avg_reward,
    STDDEV(reward_show) as std_reward,
    -- 激励视频展示 来源hint
    AVG(reward_show_hint) as Avg_reward_hint,
    -- 激励视频展示 来源pic
    AVG(reward_show_pic) as Avg_reward_pic,
    -- 插屏展示
    avg(inter_show) as Avg_inter,
    STDDEV(inter_show) as std_inter,
    -- 素材浏览数
    avg(pic_scan) as Avg_pic_scan,
    stddev(pic_scan) as std_pic_scan,
    -- 素材点击率
    avg(rate_pic_clk) as Avg_rate_pic_clk,
    stddev(rate_pic_clk) as std_rate_pic_clk,
    -- 单素材耗时
    AVG(avg_pic_cost_time) as Avg_pic_cost_time,
    stddev(avg_pic_cost_time) as std_avg_pic_cost_time,
    -- 单素材hint数
    AVG(avg_pic_cost_hint) as Avg_pic_cost_hint,
    stddev(avg_pic_cost_hint) as std_pic_cost_hint,
    -- 总着色时长
    AVG(sum_pic_cost_time) as Avg_sum_pic_cost_time,
    stddev(sum_pic_cost_time) as std_sum_pic_cost_time,
    -- hint使用数
    avg(sum_act_costhints) as avg_costhints,
    stddev(sum_act_costhints) as std_costhints,
    -- hint获得数
    avg(sum_act_gethints) as avg_gethints,
    stddev(sum_act_gethints) as std_gethints,
-- 插屏展示成功率
/*
avg(rate_inter_show) as avg_rate_inter_show,
stddev(rate_inter_show) as std_rate_inter_show
*/
FROM
    (SELECT
        user_pseudo_id as user_pseudo_id,
        CASE
        when abtest_tag like '%Fj0%' then 'Fj0'
        when abtest_tag like '%Fj1%' then 'Fj1'
        when abtest_tag like '%Fj2%' then 'Fj2'
        when abtest_tag like '%Fj3%' then 'Fj3'
        /*  when abtest_tag like '%Fj4%' then 'Fj4'
        when abtest_tag like '%Fj5%' then 'Fj5'*/
        end as tag,
        -- 着色数
        SUM(IF(event_name = 'pic_finish' and ep.key = 'finish',1,0)) as count_finish,
        -- 开图数
        SUM(IF(event_name = 'pic_finish' and ep.key = 'start_coloring',1,0)) as start_coloring,
        -- 素材完成率
        CASE
        when SUM(IF(event_name = 'pic_finish' and ep.key = 'start_coloring',1,0)) = 0 and SUM(IF(event_name = 'pic_finish' and ep.key = 'finish',1,0)) = 0 then null
        when SUM(IF(event_name = 'pic_finish' and ep.key = 'finish',1,0)) > SUM(IF(event_name = 'pic_finish' and ep.key = 'start_coloring',1,0)) then 1
        else SUM(IF(event_name = 'pic_finish' and ep.key = 'finish',1,0)) / SUM(IF(event_name = 'pic_finish' and ep.key = 'start_coloring',1,0))
        end as rate_finish,
        -- 激励视频展示数
        SUM(IF(event_name = 'ad_rewarded' and ep.key = 'show_ad',1,0)) as reward_show,
        -- 激励视频展示数 来源hint
        SUM(IF(event_name = 'ad_rewarded' and ep.key = 'show_ad' and ep.value.string_value like '%hint%',1,0)) as reward_show_hint,
        -- 激励视频展示数 来源pic
        SUM(IF(event_name = 'ad_rewarded' and ep.key = 'show_ad' and ep.value.string_value = 'pic',1,0)) as reward_show_pic,
        -- 插屏展示数
        SUM(IF(event_name = 'ad_inter' and ep.key = 'show_ad',1,0)) as inter_show,
        -- 素材浏览数
        SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic') and ep.key = 'show',1,null)) as pic_scan,
        -- 素材点击率
        CASE when SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic') and ep.key = 'show',1,0)) = 0
                and SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic') and ep.key like 'click_%',1,0)) = 0 then null
            when SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic') and ep.key like 'click_%',1,0))>
                SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic')  and ep.key = 'show',1,0)) then 1 
            else SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic') and ep.key like 'click_%',1,0))/ SUM(IF(event_name in ('home_op_pic','home_level_pic','home_test_pic','home_test2_pic','home_bonus_pic','daily_pic','theme_pic','story_pic','feature_pic','renew_pic')  and ep.key = 'show',1,0))
            end as rate_pic_clk,
        -- 单素材耗时
        avg(IF(event_name = 'pic_cost_time' and ep.key like 'p_%' and safe_cast(ep.value.string_value as numeric) between 0 and 7200,cast(ep.value.string_value as numeric),null)) as avg_pic_cost_time,
        -- 总着色时长
        SUM(IF(event_name = 'pic_cost_time' and ep.key like 'p_%' and safe_cast(ep.value.string_value as numeric) between 0 and 7200,cast(ep.value.string_value as numeric),0)) as sum_pic_cost_time,
        -- 单素材hint数
        avg(IF(event_name = 'pic_cost_hint' and ep.key like 'p_%' and ep.key != 'p_id',cast(ep.value.string_value as numeric),null)) as avg_pic_cost_hint,
        -- 总hint消耗
        sum(if(event_name = 'act_costhints' and ep.key = 'hints',1,0)) as sum_act_costhints,
        -- 总hint获得
        sum(if(event_name = 'act_gethints' and ep.key != 'abTestTagPlus',cast(ep.value.string_value as numeric),0)) as sum_act_gethints,
    FROM
    `bpbn-57141.learnings_data_warehouse_android`.`fact_ods_action_basicEvents_di_*`,UNNEST(event_params) as ep
    WHERE
    _TABLE_SUFFIX BETWEEN '20201118' AND '20201124'
    and abtest_tag like '%Fj%'
    and ep.key not in ('ga_session_id','ga_session_number','firebase_screen')
    and CONCAT(user_pseudo_id,_table_suffix) in (
        SELECT
            CONCAT(user_pseudo_id,_table_suffix)
        from
        `bpbn-57141.learnings_data_warehouse_android`.`fact_ods_action_basicEvents_di_*`
        WHERE
        _TABLE_SUFFIX BETWEEN '20201118' AND '20201124'
        AND geo.country = 'United States'
        and event_name = 'user_engagement'
        and cast(app_version as int64)>= 002008000000000
        and abtest_tag like '%Fj%')
    GROUP BY 1,2
    )
GROUP BY 1
ORDER BY 1