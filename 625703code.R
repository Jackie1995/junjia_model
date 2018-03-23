ziru0 = read.csv('625703.csv')
setwd("C:/Users/lianjia/Desktop/junjia_model_lianjia")
getwd()
str(ziru0)
dim(ziru0)# 17202    16
library(dplyr)
#第一步修改数据类型
numeric_names = names(ziru0)[grep('per_area',names(ziru0))]
#numeric_names ：是需要把数据类型变成数值型的变量名字符向量。
attach(ziru0)
ziru0[,numeric_names] = apply(ziru0[,numeric_names],2,as.numeric)
ziru0$decoration = as.factor(ziru0$decoration)
ziru0$rent_type = as.factor(ziru0$rent_type)

summary(ziru0$decoration)#自如房源的装修情况：
summary(ziru0$rent_type)#自如房源的租赁类型情况：
sum(price_trans_per_area!=price_listing_per_area,na.rm = T)
#17202
sum(is.na(price_trans_per_area)) #1
sum(is.na(price_listing_per_area)) #1
ziru0[which(is.na(price_trans_per_area)),]
ziru0=ziru0[-15030,]
#在原数据框中删除价格为空的值。
#看一下挂牌价格和成交价格差多少呢
hist(abs(price_trans_per_area-price_listing_per_area)/price_listing_per_area)
ziru1 = group_by(ziru0, hdic_resblock_id,rent_type)
n_groups(ziru1)#3932
table(group_size(ziru1))

ziru2 = ziru0 %>%
group_by(hdic_resblock_id,rent_type) %>%
summarise(n = n(),mean_price = mean(price_trans_per_area))
#将ziru2写出
write.table(ziru2,'ziru2.csv',sep = ",",row.names=F)

#########################################################
zirulian0 = read.csv('628756.csv')
#删掉数据集zirulian0中rent_type或者decoration取0的样本：
zirulian0 = zirulian0[!(zirulian0$decoration==0|zirulian0$rent_type==0),]
str(zirulian0)
#第一步修改数据类型
numeric_names2 = names(zirulian0)[grep('per_area',names(zirulian0))]
#numeric_names ：是需要把数据类型变成数值型的变量名字符向量。
zirulian0[,numeric_names] = apply(zirulian0[,numeric_names],2,as.numeric)
#正确设置因子型的变量：decoration,rent_type
zirulian0$decoration  = as.factor(zirulian0$decoration)
zirulian0$rent_type  = as.factor(zirulian0$rent_type)
summary(zirulian0[zirulian0$appid ==104,'decoration'])#链家房源的装修情况
summary(zirulian0[zirulian0$appid ==104,'rent_type'])#链家房源的租赁情况
complete_logical = complete.cases(zirulian0$price_trans_per_area,zirulian0$price_listing_per_area)
sum(complete_logical)
zirulian0 = zirulian0[complete_logical,]
zirulian1 = group_by(zirulian0, hdic_bizcircle_id,hdic_resblock_id,rent_type)
n_groups(zirulian1)#6307
table(group_size(zirulian1))
#按小区来分类：
zirulian2 = zirulian0 %>%
  group_by(hdic_bizcircle_id,hdic_resblock_id,rent_type,decoration) %>%
  summarise(n_2 = n(),mean_price_2 = mean(price_trans_per_area))
write.table(zirulian2,'zirulian2.csv',sep = ",",row.names=F)
##按商圈来分类:
zirulian3 = zirulian0 %>%
  group_by(hdic_bizcircle_id,rent_type,decoration) %>%
  summarise(n_3 = n(),mean_price_3 = mean(price_trans_per_area))
sum(table(zirulian3$n_3))
distinct(zirulian0,hdic_bizcircle_id)#224个不同商圈。
join_data = right_join(ziru2, zirulian2)
join_data2 = inner_join(ziru2, zirulian2)
join_data2 = mutate(join_data2,diff_rate = abs(mean_price_2-mean_price)/mean_price)
summary(join_data2$diff_rate)
sort(join_data2$diff_rate,decreasing = T)
#在链家18000的房源中，装修或者租赁方式不详的样本数目是：
sum(zirulian0$decoration=='0'|zirulian0$rent_type=='0')

#看一下单位面积租赁价的极值：
summary(zirulian0$price_trans_per_area)

#用cast将长表转化为宽表：ziru2_rent_type_junjia：
ziru2_rent_type_junjia = dcast(data = ziru2,formula = hdic_resblock_id~rent_type) #长表变宽表。
names(ziru2_rent_type_junjia)[2:3]=c('zheng_mean','he_mean')
#建立回归模型：谁做因变量？对于自如的房源：合租的居多，所以将整租作为因变量来预测。
lm_2 = lm(formula = sqrt(he_mean)~zheng_mean,data =ziru2_rent_type_junjia,na.action = na.omit )
lm_3 = lm(formula = sqrt(zheng_mean)~he_mean,data =ziru2_rent_type_junjia,na.action = na.omit )
#lm_3的R2是0.51.
#找到缺失值的位置：
indexNA = which(is.na(ziru2_rent_type_junjia$zheng_mean))
indexNA2 = which(is.na(ziru2_rent_type_junjia$he_mean))
#对zheng_mean进行补缺
predict_lm3 = predict(object = lm_3,newdata = ziru2_rent_type_junjia[indexNA,c(2,3)])**2
ziru2_rent_type_junjia[indexNA,'zheng_mean']=predict_lm3
#对he_mean进行补缺
lm_1 = lm(formula = he_mean~zheng_mean,data =ziru2_rent_type_junjia,na.action = na.omit )
predict_lm1 = predict(object = lm_1,newdata = ziru2_rent_type_junjia[indexNA2,c(2,3)])
hist(predict_lm1)
ziru2_rent_type_junjia[indexNA2,'he_mean']=predict_lm1
dim(ziru2_rent_type_junjia)
