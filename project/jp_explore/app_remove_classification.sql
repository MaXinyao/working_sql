SELECT
    a.user_pseudo_id,
    a.app_remove,
    a.first_app_version,
    a.brand_name,
    a.model_name,
    b.crush_rows,
    a.crush_times,
    b.duration,
    a.sessions,
    a.start_app_times,
    b.more_than_30_sessions,
    b.combo_times,
    a.true_game_num,
    a.holder_num,
    b.rotate_use,
    a.refresh_num,
    b.skip_guide
FROM
    (SELECT
        user_pseudo_id,
        MAX(device.mobile_brand_name) as brand_name,
        MAX(device.mobile_model_name) as model_name,
        MIN(app_version) as first_app_version,
        SUM(CASE when event_name = 'app_remove' then 1 else 0 end) as app_remove,
        SUM(CASE when event_name = 'act_combo' then 1 else 0 end) as crush_times,
        SUM(CASE when event_name = 'act_start_app' then 1 else 0 end) as start_app_times,
        SUM(CASE when event_name = 'act_session_start' then 1 else 0 end) as sessions,
        SUM(CASE when event_name = 'act_new_game_true' then 1 else 0 end) as true_game_num,
        cast(SUM(CASE when event_name = 'act_use_holder' then 1 else 0 end) as float64)/2 as holder_num,
        SUM(CASE when event_name = 'act_click_refresh' then 1 else 0 end) as refresh_num
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_japan_us_user_log`
    WHERE first_country = 'Japan'
    AND create_date = date
    AND create_date between '2020-10-01' AND '2020-11-21'
    GROUP BY 1) a
LEFT JOIN
    (SELECT
        user_pseudo_id,
        SUM(CASE when event_name = 'act_combo' then cast(evt.value.string_value as int64) else 0 end) as crush_rows,
        SUM(CASE when event_name = 'act_combo' and evt.value.string_value >= '3' then 1 else 0 end) as combo_times,
        SUM(CASE when event_name = 'user_engagement' then cast(evt.value.int_value as int64)/60000 else 0 end) as duration,
        SUM(CASE when event_name = 'act_session_start' and evt.value.string_value = '2' then 1 else 0 end) as more_than_30_sessions,
        SUM(CASE when event_name = 'scr_use_rotate' then 1 else 0 end) as rotate_use,
        SUM(CASE when event_name in ('src_new_guide','src_guide_update') then 1 else 0 end) as skip_guide
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_japan_us_user_log`,UNNEST(event_params) as evt
    WHERE first_country = 'Japan'
    AND create_date = date
    AND create_date between '2020-10-01' AND '2020-11-21'
    AND((event_name = 'act_combo' AND evt.key = 'combo_type') OR
        (event_name = 'user_engagement' AND evt.key = 'engagement_time_msec') OR
        (event_name = 'act_session_start' AND evt.key = 'start_type') OR
        (event_name = 'scr_use_rotate' AND evt.key = 'act_cost_item') OR
        (event_name = 'src_new_guide' AND evt.key = 'click_skip') OR
        (event_name = 'src_guide_update' AND evt.key = 'click_skip')
        )
    GROUP BY 1) b
ON a.user_pseudo_id = b.user_pseudo_id