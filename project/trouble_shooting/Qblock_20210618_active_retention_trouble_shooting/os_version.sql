SELECT
    u.date
    ,u.max_os
    ,COUNT(distinct u.unique_user_id) as users
    ,COUNT(distinct r.unique_user_id)/COUNT(distinct u.unique_user_id) as active_retention
FROM
    (SELECT
        date
        ,unique_user_id
        ,MAX(cast(first_os as INT64)) as max_os
    FROM
        (SELECT
            distinct date
            ,unique_user_id
            ,CASE when os_version LIKE '%.%.%' then SPLIT(os_version,'.')[OFFSET(0)]
                WHEN os_version LIKE '%.%' then SPLIT(os_version,'.')[OFFSET(0)]
                ELSE os_version end as first_os
        FROM
            (SELECT
                distinct date
                ,unique_user_id
                ,CASE WHEN os_version like 'Android %' then SPLIT(os_version," ")[offset(1)] else os_version end as os_version
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE _table_suffix >= '20210101'
            AND os_version not in ('Android Marshmallow',
                'Android 4.1.1','8','Android 4.2.1','Android 8.1Go','9.1','4.4.3','Android 11.0','Android 11.1','Android 5.12',
                '7.0.0','7.1','Android 9.0.0','Android 7.0.1','4.2.1','Android 4.4.2 fa','4.4','6.1','Android 8.0.1','Android 6.0.1 Marshmallow',
                '4.1.1','Android 6.0.0','Android VirgataOSv0.1','Android unknown','Android 8','Android Android 7.0','Android Android 4.4 KitKat Os',
                'Android Marshmallow OS 6.0','Android 6.0 Marshmallow','Android 9.2.0','Android 9.0.1','Android 4.4.2_Eyal.H_Cell','8.1Go',
                'Android Android 6.0','Android 8.1.1','Android Android 8.1 oreo','Android 6.1.1','Android 10.0.0','Android 12.0(16A366)','Android 4.3.1',
                '5.12','6.0.0','Android 4.42','Android 5.2','Android 4.4.2 thanks to mehdi nahavandi','Android 4.4.2 fa Forum.GpgStore.iR',
                'Android 5.1.3','Android NA','Android 12.0','Android 0.1.0-D-20170309.1502','Android Android 9.0','Android 0.1.0-D-20170329.1502',
                'Android 10.49.59','Android 0.1.0-D-20170213.1352','4.3.1','10.1','Android 15','Android 9 by @ Rashiid Malyk','Android 12.1','8',
                'Android Android 8.0','Android 4.4.0','Android 4.4.2_EYAL_MOBILE','Android Android 4.4.2','Android Android 5.1','Android 6.0.4','Android 12',
                'Android 5. 0. 1','Android 11.0.0','Android 7.2','9.1.2','Android 7.0 [SDK 24 | ARM]','9.0.1','Android Android 9 ROM by Adi MOD by PuckRom 2019',
                'Android Android Pie-Nougat 7.1.2','Android Chỉnh sửa','Android 8.1 oreo','Android 9.1.2','11','Android Q','Android 5.1.0','Android KitKat 4.4.2',
                'Android 5.0.5','Android 6.0.7','Android Car System','Android 4.4.4 Khalead Nimer','Android www.mellarmobile.com by arash samadi 4.4.2',
                '4.4.2_Eyal.H_Cell','Android 4.4.2 Persian','Android Android MarshMallow 6.0 Os For Yali','Android 6.0.1 Pfly2.0',
                '6.0.1 Marshmallow','Android Android 6.0 MarshMallow Os','Android 9999','Android 4.4.2_EYAL_Mobile','Android 0.9.0','Android 4.4.2_port_mehanik6',
                'Android 4.4.2 by sfri.arash','Android 9 Nihat C','Android 7.1.2 Premium','Marshmallow','Android 0.0.0','Android PIOS N','Android 9.0.5',
                'Android 7.1.9','Android привет андрей','Android 8.00','Android 7.0.2','6.1.1','Android 6.0.3','15','Android 4.4.2 fa by saeed','Android 6.0.2',
                'Android 15.75.86','Android 9.7.8','Android 6.0Marshmallow','Android ios14','Android 6.4.4','Android 4.4.2 Lollipop Style','9.2.0',
                '4.4.2 thanks to mehdi nahavandi','4.4.2 by sfri.arash','Android 7.0[SDK 24|ARM]','Android 9.5.5','Android 4.4.10','Android 9 by @RashidMalyk',
                'Android 9.0_huan10051988','Android 4.4.2 Fa By Afshin Najafi','Android android L','Android Android 4.4.4 KitKat Os For 9inch QuadCore Tablet PC',
                'Android 5.0.0','Android Windows 10','Android 5.1.2','Android 8.1 experience','Android 5.4','Android 7.1.2 edit by AK',
                'Android ios13','Android 4.4.2 farsi by behtash','Android 11.0.1','5.1.3','Android 5. 0. 2','Android 4.4.2 FARSI BY SAEED','Android 8.1.0x',
                'Android 7.0_Huan10051988','Android Ten','Android 5.X','Android 9.1.0','12.0(16A366)','Android7.0','Android 9.9.0','Android 4.4.2.13.07.06.02.sui')))
    GROUP BY 1,2) u
LEFT JOIN 
    (SELECT
        distinct date, unique_user_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE _table_suffix >= '20210101') r
ON u.unique_user_id = r.unique_user_id
AND r.date = DATE_ADD(u.date, interval 1 day)
GROUP BY 1,2
ORDER BY 1,2