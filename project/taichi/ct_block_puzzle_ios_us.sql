SELECT
    date,
    user_pseudo_id,
    app_version,
    revenue,
    rank_perc
FROM
    (SELECT
        date,
        user_pseudo_id,
        app_version,
        revenue,
        percent_rank() OVER(partition by date ORDER BY revenue DESC) as rank_perc
    FROM
        (SELECT
            s.date,
            s.user_pseudo_id,
            app_version,
            round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as revenue
        FROM
            (select 
                summary_date,
                user_pseudo_id,
                app_version,
                ad_id,
                country,
                date_add(current_date(), interval -14 day) as date,
                SUM(true_show) as total_show
            from `blockpuzzle-f21e1.bi_data_warehouse.adsdk_events_ios_*`
            where parse_date('%Y%m%d',_table_suffix) between date_add(current_date(), interval -14 day) and current_date()
            AND DATE_ADD(parse_date('%Y%m%d',_table_suffix),interval 0-living_days DAY) = date_add(current_date(), interval -14 day)
            and parse_date('%Y%m%d',summary_date) between date_add(current_date(), interval -14 day) and date_add(current_date(), interval -7 day)
            and country = 'United States'
            GROUP BY 1,2,3,4,5,6
            HAVING total_show > 0 and total_show < 1000000) s
        left join `blockpuzzle-f21e1.learnings_data_warehouse_ios.fact_dws_iaa_unitEcpm_a` e   
        ON parse_date('%Y%m%d',s.summary_date) = e.date
        AND s.ad_id = e.unit_id
        and s.country = e.country_name
        GROUP BY 1,2,3))
WHERE rank_perc <= 0.3