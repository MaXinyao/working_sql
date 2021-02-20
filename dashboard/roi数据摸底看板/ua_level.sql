SELECT
    platform,
    media_source,
    COUNT(distinct user_pseudo_id) as users,
    COUNT(distinct CASE when first_country is not null and first_country != 'unknown' then user_pseudo_id else null end) as has_country,
    COUNT(distinct CASE when campaign_id is not null and campaign_id != 'unknown' then user_pseudo_id else null end) as has_cid,
    COUNT(distinct CASE when campaign_name is not null and campaign_name != 'unknown' then user_pseudo_id else null end) as has_cname,
    COUNT(distinct CASE when adset_id is not null and adset_id != 'unknown' then user_pseudo_id else null end) as has_adset_id,
    0 as has_adset_name,
    COUNT(distinct CASE when ad_id is not null and ad_id != 'unknown' then user_pseudo_id else null end) as has_adid,
    0 as has_ad_name,
    COUNT(distinct CASE when af_channel is not null and af_channel != 'unknown' then user_pseudo_id else null end) as has_af_channel,
    COUNT(distinct CASE when site_id is not null and site_id != 'unknown' then user_pseudo_id else null end) as has_site_id
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
WHERE create_date between '2020-12-01' and '2020-12-27'
GROUP BY 1,2,has_adset_name,has_ad_name
UNION all
SELECT
    platform,
    media_source,
    COUNT(distinct user_pseudo_id) as users,
    COUNT(distinct CASE when first_country is not null and first_country != 'unknown' then user_pseudo_id else null end) as has_country,
    COUNT(distinct CASE when campaign_id is not null and campaign_id != 'unknown' then user_pseudo_id else null end) as has_cid,
    COUNT(distinct CASE when campaign_name is not null and campaign_name != 'unknown' then user_pseudo_id else null end) as has_cname,
    COUNT(distinct CASE when adset_id is not null and adset_id != 'unknown' then user_pseudo_id else null end) as has_adset_id,
    0 as has_adset_name,
    COUNT(distinct CASE when ad_id is not null and ad_id != 'unknown' then user_pseudo_id else null end) as has_adid,
    0 as has_ad_name,
    COUNT(distinct CASE when af_channel is not null and af_channel != 'unknown' then user_pseudo_id else null end) as has_af_channel,
    COUNT(distinct CASE when site_id is not null and site_id != 'unknown' then user_pseudo_id else null end) as has_site_id
FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a`
WHERE create_date between '2020-12-01' and '2020-12-27'
GROUP BY 1,2,has_adset_name,has_ad_name
ORDER BY 1,2