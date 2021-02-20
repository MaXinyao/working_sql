SELECT
    -- date
    ab_group
    ,COUNT(distinct user_pseudo_id) as users
    ,SUM(pic_start_nums) as pic_start_nums
    ,AVG(pic_start_nums) as avg_pic_start_nums
    ,STDDEV(pic_start_nums) as std_pic_start_nums
FROM
    (SELECT
        date
        ,user_pseudo_id
        ,CASE WHEN abtest_tag like '%Wl0%' THEN 'Wl0'
            WHEN abtest_tag like '%Wl1%' THEN 'Wl1'
            WHEN abtest_tag like '%Wl2%' THEN 'Wl2'
            WHEN abtest_tag like '%Wl3%' THEN 'Wl3'
            ELSE abtest_tag END as ab_group
        ,SUM(CASE WHEN pic_start_nums is not null THEN pic_start_nums ELSE 0 END) as pic_start_nums
        ,SUM(CASE WHEN hint_get is not null THEN hint_get ELSE 0 END) as hint_get
        ,SUM(rewarded_show) as rewarded_show
    FROM `paint-by-number-3c789.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between '2020-08-06' and '2020-08-14'
    AND abtest_tag like '%Wl%'
    AND app_version >= '002024000000000'
    GROUP BY 1,2,3)
GROUP BY 1
ORDER BY 1
