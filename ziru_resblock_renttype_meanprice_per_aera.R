setwd("C:/Users/lianjia/Desktop/junjia_model_lianjia")
#第一步：读入数据。
ziru0 = read.csv('625703.csv')
##数据介绍：adhoc查询条件：自如+北京地区+创建记录在2017.01.01之后+并且在【2018.01.01-2018.03.15】之间成交的房源数据。
dim(ziru0)# 17202    16
#第二步：数据类型转换：
##要变成数值型的变量:numeric_names
numeric_names = names(ziru0)[grep('per_area',names(ziru0))]
attach(ziru0)
ziru0[,numeric_names] = apply(ziru0[,numeric_names],2,as.numeric)
##要变成因子型的变量：factor_names
factor_names = c('decoration','rent_type')
ziru0[,factor_names] = apply(ziru0[,factor_names],2,as.factor)
##查看自如房源的装修情况和租赁情况：
summary(ziru0$decoration)#自如房源的装修情况：
summary(ziru0$rent_type)#自如房源的租赁类型情况：
#在数据框ziru0中删除价格price_listing_per_area缺失或者price_trans_per_area缺失的观测。
complete_row = complete.cases(ziru0$price_trans_per_area,ziru0$price_listing_per_area)
ziru0 = ziru0[complete_logical,]
#按（商圈，小区，租赁方式）对数据框ziru0分组：得到ziru1_group
ziru1_group = group_by(ziru0, hdic_bizcircle_id,hdic_resblock_id,rent_type)
#依这样的分组方式可以分成多少组？
n_groups(ziru1_group)
#查看各个组包含样本数的统计表：
table(group_size(ziru1))
#应用dplyr包对ziru0这个数据框分组（分组依据：小区，租赁类型）求聚合值（组内样本数，组内平均单价）
#得到新的数据框：ziru2。
ziru2 = ziru0 %>%
  group_by(hdic_resblock_id,rent_type) %>%
  summarise(n = n(),mean_price = mean(price_trans_per_area))
#ziru2现在是一个长表，需要用cast函数将其变成一个宽表ziru2_rent_type_junjia
library(reshape2)
ziru2_rent_type_junjia = dcast(data = ziru2,formula = hdic_resblock_id~rent_type) #长表变宽表。
#修改一下新数据框的列名称，新数据框的3列：小区ID，整租的平均单价，合租的平均单价。
names(ziru2_rent_type_junjia)[2:3]=c('zheng_mean','he_mean')
#建立整租均价和合租均价的回归模型
#首要问题：谁做因变量？
#统计整租与合租的缺失值数目。
#对于自如的房源：合租的居多，所以将整租作为因变量来预测。
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

#房源的租赁面积---箱线图
ziru0$area = ziru0$price_listing/ziru0$price_listing_per_area
ziru0 = ziru0[ziru0$area<200,]

ggplot(data = ziru0,aes(x = rent_type,y=area))+
  geom_boxplot(aes(colour = rent_type),alpha=0.4)+
  labs(x='房源租赁类型',y='房源出租面积',color = '租赁类型',title='房源出租面积——箱线图')+
  scale_x_discrete(labels = c('整租','合租'))+
  scale_y_continuous(limits = c(0,200))+
  scale_color_discrete(labels = c('整租','合租'))+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
#结论：整租的出租面积（75%在50m2-100m2之间）明显高于合租的出租面积（50%在10m2-15m2之间）
summary(ziru0[ziru0$rent_type==1,'area'])
summary(ziru0[ziru0$rent_type==2,'area'])

#房源签约价格与租赁面积---散点图：
names(ziru0)
str(ziru0)
library(ggplot2)
ggplot(data = ziru0,aes(x = area,y=price_listing))+
  geom_point(aes(color = rent_type),alpha=0.4)+
  labs(x='房源租赁面积',y='房源签约价格',color = '租赁类型',title='房源签约价格与租赁面积——散点图')+
  scale_x_continuous(limits = c(0,175))+
  scale_y_continuous(limits = c(0,15000))+
  theme_bw()+
  scale_color_discrete()+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_color_discrete(labels = c('整租','合租'))

#房屋签约单价与租赁面积---散点图：
ggplot(data = ziru0,aes(x = area,y=price_listing_per_area))+
  geom_point(aes(color = rent_type),alpha=0.4)+
  labs(x='房源租赁面积',y='房源签约单价',color = '租赁类型',title='房源签约单价与租赁面积——散点图')+
  scale_x_continuous(limits = c(0,175))+
  scale_y_continuous(limits = c(0,600))+
  theme_bw()+
  scale_color_discrete()+
  theme(plot.title = element_text(hjust = 0.5))+
  scale_color_discrete(labels = c('整租','合租'))



a = sort(table(ziru0$hdic_bizcircle_id))
length(a)#共216个商圈
class(a)#table
summary(a)
barplot(a)
shangquan = data.frame(number = a)

#依照商圈的租房热门程度,编码离散化变量：商圈热度：
#变量离散化过程中阈值的选择依据：（1-33：冷清）包含25%的商圈,（34-100：一般）包含50%的商圈，（101及以上：热门）包含25%的商圈。
summary(shangquan$number.Freq)
#重编码
library(dplyr)
shangquan <- shangquan %>%
  mutate(
    shangquan_degree = case_when(
      number.Freq <=33 ~ '冷清商圈',
      number.Freq>34 & number.Freq<100 ~ '一般商圈',
      number.Freq>=100 ~ '热门商圈' 
      )
  )
shangquan$shangquan_degree=as.factor(shangquan$shangquan_degree)
names(shangquan) = c('hdic_bizcircle_id','shangquan_pinshu','shangquan_degree')

#画图：北京自如的热门商圈展示
windowsFonts(myFont=windowsFont("楷体"))
ggplot(shangquan[shangquan$shangquan_degree=='热门商圈',],aes(x = hdic_bizcircle_id,y = shangquan_pinshu))+
  geom_bar(stat = 'identity',fill='#FFD700',color = '#8B6508')+
  theme_bw()+
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=1))+
  labs(x= 'top25%热门商圈ID',y='商圈近3个月的成交量',title = '北京自如热门商圈展示',subtitle = '热门商圈定义：过去3个月成交量>100笔')+
  theme(plot.title = element_text(hjust = 0.5),plot.subtitle = element_text(family = 'myFont',size = 8 ,colour = 'red'))
