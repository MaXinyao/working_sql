(select
create_date,
count(distinct user_pseudo_id) newusers,
count(distinct(case when first_country is not null then user_pseudo_id end)) have_country,
count(distinct(case when media_source is not null and media_source!='unknown' then user_pseudo_id end)) have_ms,
count(distinct(case when media_source is not null and media_source!='unknown' and media_source!='Organic' then user_pseudo_id end)) no_org,
count(distinct(case when ua_cost>0 and media_source!='unknown' and media_source!='Organic' then user_pseudo_id end)) have_uacost,
count(distinct(case when campaign_id is not null and media_source!='Organic' then user_pseudo_id end)) have_cid,
count(distinct(case when media_source='Facebook Ads' then user_pseudo_id end)) fb_nums,
count(distinct(case when (adgroup_id is not null or adset_id is not null) and media_source='Facebook Ads' then user_pseudo_id end)) fb_groupid,
count(distinct(case when media_source='googleadwords_int' then user_pseudo_id end)) adw_nums,
count(distinct(case when (adgroup_id is not null or adset_id is not null) and media_source='googleadwords_int' then user_pseudo_id end)) adw_groupid,
count(distinct(case when ad_id is not null and media_source!='Organic' then user_pseudo_id end)) have_adid,
'ios' as platform
from
`paint-by-number-3c789.learnings_data_warehouse_ios.dim_dwd_action_userProperty_a`
where create_date between '2020-12-01' and '2020-12-27'
group by 1 order by 1)

union all 

(select
create_date,
count(distinct user_pseudo_id) newusers,
count(distinct(case when first_country is not null then user_pseudo_id end)) have_country,
count(distinct(case when media_source is not null and media_source!='unknown' then user_pseudo_id end)) have_ms,
count(distinct(case when media_source is not null and media_source!='unknown' and media_source!='Organic' then user_pseudo_id end)) no_org,
count(distinct(case when ua_cost>0 and media_source!='unknown' and media_source!='Organic' then user_pseudo_id end)) have_uacost,
count(distinct(case when campaign_id is not null and media_source!='Organic' then user_pseudo_id end)) have_cid,
count(distinct(case when media_source='Facebook Ads' then user_pseudo_id end)) fb_nums,
count(distinct(case when (adgroup_id is not null or adset_id is not null) and media_source='Facebook Ads' then user_pseudo_id end)) fb_groupid,
count(distinct(case when media_source='googleadwords_int' then user_pseudo_id end)) adw_nums,
count(distinct(case when (adgroup_id is not null or adset_id is not null) and media_source='googleadwords_int' then user_pseudo_id end)) adw_groupid,
count(distinct(case when ad_id is not null and media_source!='Organic' then user_pseudo_id end)) have_adid,
'android' as platform
from
`paint-by-number-3c789.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
where create_date between '2020-12-01' and '2020-12-27'
group by 1 order by 1)
