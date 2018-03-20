data0 = read.csv('C:\\Users\\lianjia\\Downloads\\616858.csv')
#data0：基准数据集，不要再动它。

#关于行政区
summary(data0$hdic_district_id)
data0$hdic_district_id = as.factor(data0$hdic_district_id) #将它转化为因子型的变量
#关于住宅的规划类型
data0$house_type = as.factor(data0$house_type)#转化为因子型的变量
table(data0$house_type)#查看因子型变量的频数分布表

data1 = data0[data0$house_type==107500000003,]
dim(data1) #只保存了商业住宅的数据

library(ggplot2)
ggplot(data = data1,mapping = aes(y = price_trans,x=hdic_district_id))+
  geom_boxplot()
ggplot(data = data0,mapping = aes(y = price_trans,x=house_type))+
  geom_boxplot()

summary(data1$house_area)
boxplot(data1$house_area)
data2 = data1[data1$house_area<250,]
dim(data2) # 198089     35
boxplot(data2$house_area)
hist(data2$house_area)

#装修情况
summary(data2$decoration) #自如的数据去都是3，所以将这个变量删掉。
#所以要删掉的字段：decoration


#租赁类型
data2$rent_type = factor(data2$rent_type)
summary(data2$rent_type) #整租是1；合租是2
#初步的思路是根据租赁类型的不同，对不同租赁类型的房源分别建模。
# 我们应该根据不同的租赁类型来进行均价的估计

#出租区域面积
summary(data2$rent_area)
data2 = data2[data2$rent_area<250,]
summary(data2[data2$rent_type==1,]$house_area-data2[data2$rent_type==1,]$rent_area)
data2 = data2[data2$house_area>=data2$rent_area,] #数据清洗：房源面积一定要大于等于出租面积
hist(data2$house_area-data2$rent_area)
#合租的话：租赁面积占房源面积的比例。
hist((data2[data2$rent_type==2,]$house_area-data2[data2$rent_type==2,]$rent_area)/data2[data2$rent_type==2,]$house_area)


#商圈编号 hdic_bizcircle_id
data2$hdic_bizcircle_id= factor(data2$hdic_bizcircle_id)
table(data2$hdic_bizcircle_id)
order1_bizcircle = order(table(data2$hdic_bizcircle_id),decreasing = T)

table(data2$hdic_bizcircle_id)[order1_bizcircle]
barplot(table(data2$hdic_bizcircle_id)[order1_bizcircle])
length(table(data2$hdic_bizcircle_id)) #223个商圈

ggplot(data = data2,aes(x = hdic_bizcircle_id))+
  geom_bar()

library(dplyr)
data_new1 <- data2%>%
  group_by(hdic_bizcircle_id,rent_type)%>%
  summarise(n=n(),mean_price = mean(price_trans),cv_price = sd(price_trans)/mean_price,std_price = sd(price_trans))
data_new1

#小区编号 hdic_resblock_id

