SELECT
    rn.date,
    u.campaign_id,
    COUNT(distinct u.user_pseudo_id) as users,
    COUNT(u.user_pseudo_id) as checkers,
    SUM(revenue) as revenue,
    AVG(revenue) as arpu
FROM
    (SELECT 
        distinct user_pseudo_id,
        up.value as campaign_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*`,
    UNNEST(user_properties) as up
    WHERE _table_suffix between '20200719' and '20200818'
    AND up.key = 'campaign_id'
    and up.value in ('23845101824870191','23845070099360191','23845022529840191','23845105038310191','23845042483950191')) u 
LEFT JOIN 
    (SELECT
        parse_date('%Y%m%d',s.summary_date) as date,
        s.user_pseudo_id,
        round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as revenue
    FROM
        (select 
            summary_date,
            user_pseudo_id,
            ad_id,
            country,
            SUM(true_show) as total_show
        from `blockpuzzle-f21e1.bi_data_warehouse.adsdk_events_android_*`
        where _table_suffix between '20200719' and '20200818'
        GROUP BY 1,2,3,4
        HAVING total_show > 0 and total_show < 1000000) s
    left join `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_dws_iaa_unitEcpm_a` e   
    ON parse_date('%Y%m%d',s.summary_date) = e.date
    AND s.ad_id = e.unit_id
    and s.country = e.country_name
    GROUP BY 1,2) rn
ON rn.user_pseudo_id = u.user_pseudo_id
GROUP BY 1,2