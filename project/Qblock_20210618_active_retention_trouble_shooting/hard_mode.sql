SELECT
    parse_date('%Y%m%d',_table_suffix) as date
    ,COUNT(distinct unique_user_id) as users
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`, UNNEST(event_params) as ep
WHERE _table_suffix in ('20210420','20210615')
AND app_version >= '002002008000000'
AND event_name = 'holder_in'
AND ep.key = 'block_id'
AND ep.value.string_value in ('120','121','122','123','124','125','126','127','128','129','130','131',
    '132','133','134','135','140','141','142','143','145','146')
GROUP BY 1
ORDER BY 1