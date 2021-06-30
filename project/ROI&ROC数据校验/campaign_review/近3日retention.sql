select  
    COUNT(distinct a.unique_user_id)/COUNT(distinct u.unique_user_id) as retention
from 
    (SELECT
        distinct create_date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userProperty_a`
    WHERE create_date between DATE_ADD(CURRENT_DATE(),INTERVAL -5 DAY) and DATE_ADD(CURRENT_DATE(),INTERVAL -3 DAY)
    AND first_country = 'Brazil'
    AND campaign_name = 'QB_uty_adr_br_IAA_0521') u   
left join   
    (select  
        distinct date, unique_user_id
    from `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`  
    where _table_suffix between format_date('%Y%m%d',DATE_ADD(CURRENT_DATE(),INTERVAL -15 DAY)) 
    and format_date('%Y%m%d',DATE_ADD(CURRENT_DATE(),INTERVAL -2 DAY))  
    and living_days between 0 and 7  
    group by 1,2) a  
on u.unique_user_id = a.unique_user_id   
AND a.date = DATE_ADD(u.create_date, interval 1 day)