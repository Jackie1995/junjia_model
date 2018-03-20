#! /bin/bash  
ptt='20170719000000'
end='20180128000000'
while [ "$ptt" != "$end" ]
do  
##################################################################
dat=${ptt:0:8}
echo $dat
hive -e"insert into table rentplat.rentplat_dw_avg_price_di
  PARTITION (pt = '$ptt')
select
'resblock' as geography_dim,
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
hdic_resblock_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type
from(
select 
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
hdic_resblock_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type,
pt
from(
    select 
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
hdic_resblock_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    hdic_resblock_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,hdic_resblock_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  left join (
    select 
hdic_city_id as city,
hdic_district_id as dis,
hdic_bizcircle_id as biz,
hdic_resblock_id as res,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    hdic_resblock_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,hdic_resblock_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.hdic_district_id=b.dis and a.hdic_bizcircle_id=b.biz and a.hdic_resblock_id=b.res and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
 
 union

select 
city as hdic_city_id,
dis as hdic_district_id,
biz as hdic_bizcircle_id,
res as hdic_resblock_id,
sta as start_date,
end_ as end_date,
bed as frame_bedroom_num,
ren as rent_type,
dec as decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
typ,
pt1
from(
    select 
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
hdic_resblock_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    hdic_resblock_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,hdic_resblock_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  right join (
    select 
hdic_city_id as city,
hdic_district_id as dis,
hdic_bizcircle_id as biz,
hdic_resblock_id as res,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    hdic_resblock_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,hdic_resblock_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.hdic_district_id=b.dis and a.hdic_bizcircle_id=b.biz and a.hdic_resblock_id=b.res and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
) p;
"
#####################################################################################################################################
dat=${ptt:0:8}
echo $dat
hive -e"insert into table rentplat.rentplat_dw_avg_price_di
  PARTITION (pt = '$ptt')
select
'bizcircle' as geography_dim,
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
'' as hdic_resblock_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type
from(
select 
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type,
pt
from(
    select 
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  left join (
    select 
hdic_city_id as city,
hdic_district_id as dis,
hdic_bizcircle_id as biz,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.hdic_district_id=b.dis and a.hdic_bizcircle_id=b.biz and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
 
 union

select 
city as hdic_city_id,
dis as hdic_district_id,
biz as hdic_bizcircle_id,
sta as start_date,
end_ as end_date,
bed as frame_bedroom_num,
ren as rent_type,
dec as decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
typ,
pt1
from(
    select 
hdic_city_id,
hdic_district_id,
hdic_bizcircle_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  right join (
    select 
hdic_city_id as city,
hdic_district_id as dis,
hdic_bizcircle_id as biz,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,hdic_district_id,hdic_bizcircle_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.hdic_district_id=b.dis and a.hdic_bizcircle_id=b.biz and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
) p;
"
#####################################################################################################################################
dat=${ptt:0:8}
echo $dat
hive -e"insert into table rentplat.rentplat_dw_avg_price_di
  PARTITION (pt = '$ptt')
select
'district' as geography_dim,
hdic_city_id,
hdic_district_id,
'' as hdic_bizcircle_id,
'' as hdic_resblock_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type
from(
select 
hdic_city_id,
hdic_district_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type,
pt
from(
    select 
hdic_city_id,
hdic_district_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    hdic_district_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,hdic_district_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  left join (
    select 
hdic_city_id as city,
hdic_district_id as dis,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    hdic_district_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,hdic_district_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.hdic_district_id=b.dis and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
 
 union

select 
city as hdic_city_id,
dis as hdic_district_id,
sta as start_date,
end_ as end_date,
bed as frame_bedroom_num,
ren as rent_type,
dec as decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
typ,
pt1
from(
    select 
hdic_city_id,
hdic_district_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    hdic_district_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,hdic_district_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  right join (
    select 
hdic_city_id as city,
hdic_district_id as dis,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    hdic_district_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,hdic_district_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.hdic_district_id=b.dis and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
) p;
"
#####################################################################################################################################
dat=${ptt:0:8}
echo $dat
hive -e"insert into table rentplat.rentplat_dw_avg_price_di
  PARTITION (pt = '$ptt')
select
'city' as geography_dim,
hdic_city_id,
'' as hdic_district_id,
'' as hdic_bizcircle_id,
'' as hdic_resblock_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type
from(
select 
hdic_city_id,
start_date,
end_date,
frame_bedroom_num,
rent_type,
decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
type,
pt
from(
    select 
hdic_city_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  left join (
    select 
hdic_city_id as city,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
 
 union

select 
city as hdic_city_id,
sta as start_date,
end_ as end_date,
bed as frame_bedroom_num,
ren as rent_type,
dec as decoration,
trans_amount,
median_deal_price,
mean_deal_price,
min_deal_price,
max_deal_price,
listing_amount,
median_listing_price,
mean_listing_price,
min_listing_price,
max_listing_price,
typ,
pt1
from(
    select 
hdic_city_id,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as start_date,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_date,
frame_bedroom_num,
rent_type,
decoration,
count(if(sign_time is not null, true, null)) as trans_amount,
percentile(cast(price_trans as bigint),0.5) as median_deal_price,
avg(price_trans) as mean_deal_price,
min(price_trans) as min_deal_price,
max(price_trans) as max_deal_price,
appid as type,
pt as pt
from ( 
  SELECT  
      case frame_bedroom_num
        when '1' then '1'
          when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_trans is not null,price_trans,0) as price_trans,
    CASE when substr(sign_time,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(sign_time,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN sign_time ELSE NULL END as sign_time,
    hdic_city_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_trans>0 and sign_time is not null
group by appid, hdic_city_id,frame_bedroom_num,rent_type,decoration,pt
  ) a
  right join (
    select 
hdic_city_id as city,
date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) as sta,
from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') as end_,
frame_bedroom_num as bed,
rent_type as ren,
decoration as dec,
count(if(app_ctime is not null, true, null)) as listing_amount,
percentile(cast(price_listing as bigint),0.5) as median_listing_price,
avg(price_listing) as mean_listing_price,
min(price_listing) as min_listing_price,
max(price_listing) as max_listing_price,
appid as typ,
pt as pt1
from ( 
  SELECT
    case frame_bedroom_num
      when '1' then '1' 
      when '2' then '2' 
      when '3' then '3'
      else
       '4'
    end as frame_bedroom_num ,
    case rent_type
        when '1' then '1'
        when '2' then '2'
        else
        '3'
    end as rent_type,
    case decoration
        when '1' then '1'
        when '2' then '2'
        when '3' then '3'
        else
        '4'
    end as decoration,
        case appid
            when '104' then 'simple_rent'
            else
            'apartment'
    end as appid,
    if(price_listing is not null,price_listing,0) as price_listing,
    CASE when substr(app_ctime,0,10)>date_sub(from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd'),30) and substr(app_ctime,0,10)<=from_unixtime(unix_timestamp('${dat}','yyyymmdd'),'yyyy-mm-dd') THEN app_ctime ELSE NULL END as app_ctime,
    hdic_city_id,
    pt
  FROM
    ods.ods_lianjia_house_rent_new_da 
  WHERE hdic_city_id in ('110000', '510100') and appid in ('500', '104') and pt='$ptt'
) w
where price_listing>0 and app_ctime is not null
group by appid, hdic_city_id,frame_bedroom_num,rent_type,decoration,pt
  ) b
  on a.hdic_city_id=b.city and a.start_date=b.sta and a.end_date=b.end_ and a.frame_bedroom_num=b.bed and a.rent_type=b.ren and a.decoration=b.dec and a.type=b.typ and a.pt=b.pt1
) p;
"
echo '4'
dat=${ptt:0:8}
dat=`date -d "-1 days ago $dat" +%Y%m%d`
echo $dat
echo $dat"000000"
let ptt=`echo $dat"000000"`
done  