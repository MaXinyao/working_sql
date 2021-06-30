SELECT
    c.country
    ,SUM(spend.spend) as spend
    ,SUM(spend.install) as install
FROM 
    (SELECT
        distinct app_id, media_source, platform
    FROM `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a`
    WHERE production_id = @production_id
    AND IFNULL(store, '-') != 'instant_game') app
INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_*` spend
ON IFNULL(app.app_id,'-') = IFNULL(spend.app_id,'-')
AND IFNULL(app.media_source,'-') = IFNULL(spend.media_source,'-')
AND IFNULL(app.platform,'-') = IFNULL(spend.platform,'-')
AND spend._table_suffix between FORMAT_DATE('%Y%m%d',@start_date) and FORMAT_DATE('%Y%m%d',@end_date)
INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` c
ON c.country_code = spend.country_code
WHERE c.country = @country
GROUP BY 1