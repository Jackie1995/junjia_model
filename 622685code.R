data0_avg = read.csv('622685.csv')
getwd()
summary(data0_avg$geography_dim)
str(data0_avg_res)
#发现有很多数值型的变量都被数据框给识别成了 factor类型的变量。
names(data0_avg)
#希望在 data0_avg 数据框中把变量名称以‘price’和‘amount’结尾的变量找出来？
pricenames = grep('price',names(data0_avg))
amountnames = grep('amount',names(data0_avg))
convert_names = c(pricenames,amountnames)
#一行代码改变几列的数据类型：
data0_avg[,convert_names] = apply(data0_avg[,convert_names],2,as.numeric)
#到这一步：data0_avg 中的价格与数量变量都已经转化为数值型了。

##下面都是错误的探索
#***************************************************
#convert_names2 = names(data0_avg)[convert_names]
data0_avg[convert_names] = as.numeric(as.character(data0_avg[convert_names]))

#这样做不行。全都是NA
data0_avg$convert_names2 = as.numeric(as.character(data0_avg$convert_names2))
#这样不行
#colname = 'median_deal_price'
for (colname in convert_names2){
  data0_avg$colname = as.numeric(data0_avg$colname)
}

as.numeric(data0_avg["median_deal_price"])

for (colindex in convert_names){
  data0_avg[colindex] = as.numeric(as.character(data0_avg[colindex]))
}
data0_avg$max_deal_price = as.numeric(as.character(data0_avg$max_deal_price))
data0_avg[15] = as.numeric(as.character(data0_avg[15]))
class(data0_avg['max_deal_price'])

data0_avg[convert_names] = as.numeric((data0_avg[convert_names]))
#Error: (list) object cannot be coerced to type 'double'

str(data0_avg)
summary(data0_avg)
#***************************************************
a <- ls()
rm(list=a[which(a!='data0_avg' & a !='colname')])
#删除当前环境中不需要的变量。

data0_avg_res = data0_avg[data0_avg$geography_dim=='resblock',]
dim(data0_avg_res) #29513    22
summary(data0_avg_res$trans_amount)
index1  = which(is.na(data0_avg_res$trans_amount) & is.na(data0_avg_res$listing_amount))
index1 #integer(0)
#意思就是说。所有的小区在过去的一个月里都有挂牌记录或者交易记录。
#这个结论在excel表中通过对两列同时也得到了验证。

table(data0_avg_res$type)
#apartment  simple_rent 
#5003       24510

#在数据框中新添一个字段：mean_price_two
which(names(data0_avg_res)=='mean_deal_price')      #13                 
which(names(data0_avg_res)=='mean_listing_price')   #18
data0_avg$mean_price_two = rowMeans(data0_avg[,c(13,18)],na.rm = T)
data0_avg_res$mean_price_two = rowMeans(data0_avg_res[,c(13,18)],na.rm = T)
hist(data0_avg_res$mean_price_two)
summary(data0_avg_res$mean_price_two)

#
sort(data0_avg_res$mean_price_two)[1:100]
sort(data0_avg_res$mean_deal_price) [1:100]
sort(data0_avg_res$mean_listing_price)[1:100]

sum(is.na(data0_avg_res$mean_deal_price)) #最近一个月小区地理维度层面：有17276个交易缺失记录
#所以考虑：缩减分组条件。
sum(is.na(data0_avg_res$mean_listing_price)) #3231个缺失

quantile(data0_avg_res$mean_price_two,probs = c(0.8,0.9,0.95,0.99) )
boxplot(data0_avg_res$mean_price_two)
summary(data0_avg_res$hdic_district_id)

boxplot(mean_price_two~hdic_district_id,data = data0_avg_res)
#这个画的有点丑
library(ggplot2)
ggplot(data = data0_avg_res,mapping = aes(x=hdic_district_id,y = mean_price_two) )+
  geom_boxplot(mapping = aes(fill = hdic_district_id))
#发现有异常值

