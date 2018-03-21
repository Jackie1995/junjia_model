import numpy as np
import pandas as pd
import preprocess_train
import preprocess_test_cd
#import matplotlib.pyplot as plt
from sklearn.externals import joblib
from math import sqrt
from sklearn import ensemble
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import KFold

train=preprocess_train.preprocess()
train_y=train[['price_trans']].as_matrix()
train.drop(['price_trans'],axis=1,inplace=True)
train_X=train.as_matrix()

test=preprocess_test_cd.preprocess()
test_y=test[['price_trans']].as_matrix()
test.drop(['price_trans'],axis=1,inplace=True)
test_X=test.as_matrix()

params = {'n_estimators': 500, 'max_depth': 4, 'min_samples_split': 2,
          'learning_rate': 0.020, 'loss': 'ls'}
clf = ensemble.GradientBoostingRegressor(**params)
clf.fit(train_X,train_y)
pre=clf.predict(test_X)
rmse=sqrt(mean_squared_error(test_y,pre))
print("avg_rmse=",rmse)
m=[]
for i in range(len(pre)):
    m.append([pre[i]])
error=abs(m-test_y)/test_y
print(type(error))
test.insert(1,"predict", pre)
test.insert(1,"error", error)
avg_error=np.mean(test['error'].as_matrix())
print("avg_error=",avg_error)
print("in_1.0%_true_rate=",float(len(test[test['error']<=0.010]['error']))/len(test['error']))
print("in_2.0%_true_rate=",float(len(test[test['error']<=0.020]['error']))/len(test['error']))
print("in_3.0%_true_rate=",float(len(test[test['error']<=0.030]['error']))/len(test['error']))
print("in_4.0%_true_rate=",float(len(test[test['error']<=0.040]['error']))/len(test['error']))
print("in_5.0%_true_rate=",float(len(test[test['error']<=0.050]['error']))/len(test['error']))
print("in_6.0%_true_rate=",float(len(test[test['error']<=0.060]['error']))/len(test['error']))
print("in_7.0%_true_rate=",float(len(test[test['error']<=0.070]['error']))/len(test['error']))
print("in_8.0%_true_rate=",float(len(test[test['error']<=0.080]['error']))/len(test['error']))
print("in_9.0%_true_rate=",float(len(test[test['error']<=0.090]['error']))/len(test['error']))
print("in_10.0%_true_rate=",float(len(test[test['error']<=0.100]['error']))/len(test['error']))


test.insert(1,"price_trans",test_y)
test.to_csv("predict_test.csv")
#test[['error']].plot(kind='kde')
#plt.xlim((0,0.2))
#plt.xlabel('error_rate')
#plt.ylabel('Desinty')
#my_x_ticks = np.arange(0, 0.2, 0.02)
#plt.xticks(my_x_ticks)
#plt.show()
