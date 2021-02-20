SELECT
    date
    ,create_date
    ,user_pseudo_id
    ,app_version
    ,ad_revenue
    ,rank_perc
FROM
    (SELECT
        date
        ,create_date
        ,user_pseudo_id
        ,app_version
        ,ad_revenue
        ,PERCENT_RANK() OVER(PARTITION BY create_date ORDER BY ad_revenue DESC) as rank_perc
    FROM
        (SELECT
            s.date
            ,s.create_date
            ,s.user_pseudo_id
            ,app_version
            ,ROUND(SUM(IFNULL(s.total_show, 0) * IFNULL(e.ecpm, 0) / 1000), 2) as ad_revenue
        FROM
            (SELECT 
                summary_date
                ,DATE_ADD(PARSE_DATE('%Y%m%d',_table_suffix),INTERVAL 0-living_days DAY) as create_date
                ,user_pseudo_id
                ,app_version
                ,ad_id
                ,country
                ,DATE_SUB(@run_date, INTERVAL 0 DAY) AS date
                ,SUM(true_show) as total_show
            FROM `paint-by-number-3c789.bi_data_warehouse.adsdk_events_android_*`
            WHERE PARSE_DATE('%Y%m%d',_table_suffix) BETWEEN DATE_ADD(@run_date, INTERVAL -8 DAY) BETWEEN DATE_ADD(@run_date, INTERVAL -2 DAY)
            --create_date是7天前
            AND DATE_ADD(parse_date('%Y%m%d',_table_suffix),INTERVAL 0-living_days DAY) BETWEEN DATE_ADD(@run_date, INTERVAL -8 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY) 
            --广告实际发生的时间是6天内
            AND PARSE_DATE('%Y%m%d',summary_date) BETWEEN DATE_ADD(@run_date, INTERVAL -8 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY)
            AND country = 'United States'
            GROUP BY 1,2,3,4,5,6,7
            HAVING total_show > 0 AND total_show < 1000000) s
        LEFT JOIN
            (SELECT 
                iaa_platform
                ,date
                ,unit_id
                ,ip_name as country_name
                ,rev.country_code
                ,IFNULL(SUM(revenue), 0) as revenue, IFNULL(SUM(impression), 0) as impression
                ,ROUND(IFNULL(SAFE_DIVIDE(SUM(revenue), SUM(impression)) * 1000, 0), 10) as ecpm
            FROM `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev 
            JOIN 
                (SELECT 
                    k2.app_id
                    ,k2.platform 
                FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a`
                WHERE production_id = '5b84f58e689998000116d3fd'
                ) app 
            ON app.app_id = rev.app_id 
            AND IFNULL(rev.platform, 'nt') = IFNULL(app.platform, 'nt')
            LEFT JOIN `foradmobapi.learnings_data_warehouse.dim_dwd_basic_country_a` country 
            ON rev.country_code = country.country_code
            WHERE PARSE_DATE('%Y%m%d',_table_suffix) BETWEEN DATE_ADD(@run_date, INTERVAL -8 DAY) AND DATE_ADD(@run_date, INTERVAL -2 DAY)
            GROUP BY 1, 2, 3, 4, 5) e   
        ON PARSE_DATE('%Y%m%d',s.summary_date) = e.date
        AND s.ad_id = e.unit_id
        AND s.country = e.country_name
        GROUP BY 1,2,3,4))
WHERE rank_perc <= 0.3