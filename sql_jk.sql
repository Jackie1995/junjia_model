	
	-- 下面这个sql是：自如 北京 2018年之后签约 2017年之后创建记录 的数据。
	--  查询标号：625703
	SELECT
	hdic_city_id,
    hdic_district_id,
    hdic_bizcircle_id,
    hdic_resblock_id,
	case 
			frame_bedroom_num
			when '1' then '1' 
			when '2' then '2' 
			when '3' then '3'
			else  '0'
	end as frame_bedroom_num ,
	case 
		rent_type
		    when '1' then '1'
		    when '2' then '2'
		    else '0'
    end as rent_type,
	case 
			decoration
		    when '1' then '1'
		    when '2' then '2'
		    when '3' then '3'
		    else'0'
    end as decoration,
	appid,
	price_trans,
	price_listing,
    price_trans/rent_area as price_trans_per_area,
    price_listing/rent_area as price_listing_per_area,
    to_date(sign_time) as sign_date,
    to_date(app_ctime) as appc_date,
	datediff(to_date(sign_time),to_date(app_ctime)) as diff_days,
    pt
	FROM
		ods.ods_lianjia_house_rent_new_da 
	WHERE hdic_city_id = 110000 and appid = 500 and pt='20180315000000' and sign_time like '2018%' and from_unixtime(unix_timestamp(app_ctime,'yyyy-mm-dd ss:ss:ss'),'yyyymmddssssss')> '201701010000000'


