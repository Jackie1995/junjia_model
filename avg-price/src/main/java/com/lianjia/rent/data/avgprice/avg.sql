select 
'resblock' as geography_dim,
appid as type,
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
hdic_resblock_id,
frame_bedroom_num,
rent_type,
decoration,
date_sub (from_unixtime(unix_timestamp(substr(pt,0,8),'yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp(substr(pt,0,8),'yyyymmdd'),'yyyy-mm-dd') as end_date,
pt,
count(if(sign_time is not null, true, null)) as trans_amount,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_trans) as min_trans_price,
max(price_trans) as max_trans_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price
from (
	SELECT
		case frame_bedroom_num
			when '1' then '1' 
			when '2' then '2' 
			when '3' then '3'
			else
			 '0'
		end as frame_bedroom_num ,
		case rent_type
		    when '1' then '1'
		    when '2' then '2'
		    else
		    '0'
    end as rent_type,
		case decoration
		    when '1' then '1'
		    when '2' then '2'
		    when '3' then '3'
		    else
		    '0'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when from_unixtime(unix_timestamp(sign_time,'yyyy-mm-dd ss:ss:ss'),'yyyymmddssssss')> '201801020000000' and from_unixtime(unix_timestamp(sign_time,'yyyy-mm-dd ss:ss:ss'),'yyyymmddssssss')<='201801160000000' THEN sign_time ELSE NULL END as sign_time,
    CASE WHEN from_unixtime(unix_timestamp(app_ctime,'yyyy-mm-dd ss:ss:ss'),'yyyymmddssssss')> '201801020000000' and from_unixtime(unix_timestamp(app_ctime,'yyyy-mm-dd ss:ss:ss'),'yyyymmddssssss')<='201801160000000' THEN app_ctime ELSE NULL ENd as app_ctime,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    hdic_resblock_id,
    pt
	FROM
		ods.ods_lianjia_house_rent_new_da 
	WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt>='201801120000000' and pt<'20180117000000'and app_ctime like '2018%' and sign_time like '2018%'
  limit 100
) a
where price_trans>0 and price_listing>0 
group by appid,	hdic_city_id,hdic_district_id,hdic_bizcircle_id,hdic_resblock_id,frame_bedroom_num,rent_type,decoration,pt;


