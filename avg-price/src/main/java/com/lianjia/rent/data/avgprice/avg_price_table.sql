create table if not exists rentplat.rentplat_dw_avg_price_di
(
geography_dim string comment '地理粒度',
hdic_city_id int comment '城市ID',
hdic_district_id int comment '市区ID',
hdic_bizcircle_id bigint comment '商圈ID',
hdic_resblock_id bigint comment '小区ID',
start_date string comment '统计起始日期',
end_date string comment '统计截止日期',
frame_bedroom_num int comment '居室数量',
rent_type bigint comment '出租类型',
decoration bigint comment '装修情况',
trans_amount bigint comment '成交数',
median_deal_price decimal comment '成交中位价格',
mean_deal_price decimal comment '成交平均价格',
min_deal_price decimal comment '最小成交价格',
max_deal_price decimal comment '最大成交价格',
listing_amount bigint comment '挂牌数',
median_listing_price decimal comment '挂牌中位价格',
mean_listing_price decimal comment '挂牌平均价格',
min_listing_price decimal comment '最小挂牌价格',
max_listing_price decimal comment '最大挂牌价格',
type string comment '房源来源',
)
comment '不同地理粒度均价表'
ROW FORMAT DELIMITED
PARTITION BY pt
FIELDS TERMINATED BY '\u0001'
COLLECTION ITEMS TERMINATED BY '\u0002'
MAP KEYS TERMINATED BY '\u0003'
STORED AS ORCFILE
location 'hdfs://jx-bd-hadoop00.lianjia.com:9000/user/bigdata/rentplat/dw_log_all_info_di';