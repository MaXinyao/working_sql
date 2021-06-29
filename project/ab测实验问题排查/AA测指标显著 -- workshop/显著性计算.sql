SELECT
    abtest_tag,
    COUNT(*) as num,
    AVG(duration) as avg_duration,
    STDDEV(duration) as stddev_duration,
    AVG(inter_show) as avg_inter,
    STDDEV(inter_show) as stddev_inter,
    AVG(rewarded_show) as avg_rewarded,
    STDDEV(rewarded_show) as stddev_rewarded,
    AVG(crush_rows) as avg_crush_rows,
    STDDEV(crush_rows) as stddev_crush_rows,
    AVG(crush_times) as avg_crush_times,
    STDDEV(crush_times) as stddev_crush_times,
    AVG(combo_times) as avg_combo_times,
    STDDEV(combo_times) as stddev_combo_times,
    AVG(prop_usage) as avg_prop_usage,
    STDDEV(prop_usage) as stddev_prop_usage
FROM
    (SELECT
        date,
        CASE when abtest_tag LIKE '%Td0%' then 'Td0'
             when abtest_tag LIKE '%Td1%' then 'Td1'
             when abtest_tag LIKE '%Td2%' then 'Td2'
             when abtest_tag LIKE '%Td3%' then 'Td3'
             when abtest_tag LIKE '%Td4%' then 'Td4'
             when abtest_tag LIKE '%Td5%' then 'Td5'
             when abtest_tag LIKE '%Td6%' then 'Td6'
             when abtest_tag LIKE '%Td7%' then 'Td7'
             when abtest_tag LIKE '%Td9%' then 'Td9'
             when abtest_tag LIKE '%Td8%' then 'Td8'
             else 'Other' end as abtest_tag,
        unique_user_id,
        SUM(IF(duration is null,0,duration))/1000 as duration,
        SUM(IF(inter_show is null,0,inter_show)) as inter_show,
        SUM(IF(rewarded_show is null,0,rewarded_show)) as rewarded_show,
        SUM(IF(crush_rows is null,0,crush_rows)) as crush_rows,
        SUM(IF(crush_times is null,0,crush_times)) as crush_times,
        SUM(IF(combo_times is null,0,combo_times)) as combo_times,
        SUM(IF(prop_usage is null,0,prop_usage)) as prop_usage
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between '2021-04-09' and '2021-04-22'
    AND app_version >= '002002005000000'
    AND (abtest_tag LIKE '%Td0%' OR abtest_tag LIKE '%Td1%' OR abtest_tag LIKE '%Td2%' OR abtest_tag LIKE '%Td8%' OR abtest_tag LIKE '%Td3%'
        OR abtest_tag LIKE '%Td4%' OR abtest_tag LIKE '%Td5%' OR abtest_tag LIKE '%Td6%' OR abtest_tag LIKE '%Td7%' OR abtest_tag LIKE '%Td9%')
    GROUP BY 1,2,3)
GROUP BY 1
ORDER BY 1