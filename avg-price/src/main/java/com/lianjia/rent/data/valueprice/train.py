import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.externals import joblib
import preprocess_train
from math import sqrt
from sklearn import ensemble
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import KFold

# #############################################################################
# Load data
df=preprocess_train.preprocess()
print(df.head())
#df=pd.read_csv("after_pre.csv")
y=df[['price_trans']]
df.drop(['price_trans'],axis=1,inplace=True)
print df.info()
print(y.info())
y=y.as_matrix()
X=df.as_matrix()
kf=KFold(n_splits=10)

params = {'n_estimators': 500, 'max_depth': 4, 'min_samples_split': 2,
          'learning_rate': 0.020, 'loss': 'ls'}
clf = ensemble.GradientBoostingRegressor(**params)
sum1=0
sum2=0
df.insert(0,"error", np.zeros(len(df[['house_area']])))
df.insert(1,"predict", np.zeros(len(df[['house_area']])))
for train_index,val_index in kf.split(X):
    X_train,X_val=X[train_index],X[val_index]
    y_train,y_val=y[train_index],y[val_index]
    clf.fit(X_train, y_train)
    pre=clf.predict(X_val)
    m=[]
    for i in range(len(pre)):
        m.append([pre[i]])
    error=abs(m-y_val)/y_val
    #print error
    df.loc[val_index,['error']]=error
    df.loc[val_index,['predict']]=pre
    rmse=sqrt(mean_squared_error(y_val, pre))
    mae=mean_absolute_error(y_val, pre)
    sum1+=rmse
    sum2+=mae
    print("once")
avg_error=np.mean(df['error'].as_matrix())
print("avg_error=",avg_error)

print("in_1.0%_true_rate=",float(len(df[df['error']<=0.010]['error']))/len(df['error']))
print("in_2.0%_true_rate=",float(len(df[df['error']<=0.020]['error']))/len(df['error']))
print("in_3.0%_true_rate=",float(len(df[df['error']<=0.030]['error']))/len(df['error']))
print("in_4.0%_true_rate=",float(len(df[df['error']<=0.040]['error']))/len(df['error']))
print("in_5.0%_true_rate=",float(len(df[df['error']<=0.050]['error']))/len(df['error']))
print("in_6.0%_true_rate=",float(len(df[df['error']<=0.060]['error']))/len(df['error']))
print("in_7.0%_true_rate=",float(len(df[df['error']<=0.070]['error']))/len(df['error']))
print("in_8.0%_true_rate=",float(len(df[df['error']<=0.080]['error']))/len(df['error']))
print("in_9.0%_true_rate=",float(len(df[df['error']<=0.090]['error']))/len(df['error']))
print("in_10.0%_true_rate=",float(len(df[df['error']<=0.100]['error']))/len(df['error']))
print ("avg_rmse=" ,sum1/10)
print ("avg_mae=",sum2/10)

df.insert(1,"price_trans",y)
#df.to_csv("predict.csv")
df[['error']].plot(kind='kde')
plt.xlim((0,0.2))
plt.xlabel('error_rate')
plt.ylabel('Desinty')
my_x_ticks = np.arange(0, 0.2, 0.02)
plt.xticks(my_x_ticks)
plt.show()



