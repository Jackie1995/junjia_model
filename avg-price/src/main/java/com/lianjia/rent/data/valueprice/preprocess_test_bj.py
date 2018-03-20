import pandas as pd
import numpy as np
import re
from sklearn.ensemble import GradientBoostingClassifier
from sklearn import cross_validation, metrics
from sklearn.ensemble import RandomForestClassifier

def preprocess():
    #df=pd.read_csv("cd_test.csv",sep="\t")
    df=pd.read_csv("bj_test.csv",sep="\t")
    df=df[['frame_orientation','hdic_resblock_id','decoration','heating_type','rent_type','sign_time','floor_level','building_finish_year','house_area','frame_hall_num','frame_bedroom_num','frame_kitchen_num','frame_bathroom_num','price_listing','price_trans','rent_area']]
    df=df[df['frame_orientation'].notnull()]
    df=df[(df['building_finish_year']<2018) & (df['building_finish_year']>1970)]
    df=df[(df['house_area']>=8) & (df['rent_area']<=2000)]
    df=df[(df['rent_area']>=8) & (df['rent_area']<=2000)]
    df=df[df['price_listing']>=500]
    df=df[df['price_trans']>=500]


    a = df['frame_orientation'].as_matrix()
    ori = []
    # print df['frame_orientation'].value_counts()
    for i in range(len(a)):
        n = re.split(r";|,|\?", a[i])
        ori.append([x for x in n if x])
    df.insert(1,"orientation_E", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_N", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_W", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_S", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_ES", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_EN", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_WS", np.zeros(len(df['frame_orientation'])))
    df.insert(1,"orientation_WN", np.zeros(len(df['frame_orientation'])))
    for i in range(len(ori)):
        for j in range(len(ori[i])):
            if(ori[i][j]=='100500000001'):
                df.iloc[i,8]=1
            elif(ori[i][j]=='100500000002'):
                df.iloc[i,4]=1
            elif(ori[i][j]=='100500000003'):
                df.iloc[i,5]=1
            elif(ori[i][j]=='100500000004'):
                df.iloc[i,2]=1
            elif(ori[i][j]=='100500000005'):
                df.iloc[i,6]=1
            elif(ori[i][j]=='100500000006'):
                df.iloc[i,1]=1
            elif(ori[i][j]=='100500000007'):
                df.iloc[i,7]=1
            elif(ori[i][j]=='100500000008'):
                df.iloc[i,3]=1
    df.drop(['frame_orientation'], axis=1, inplace=True)


    df['sign_time'] = pd.to_datetime(df['sign_time'],format='%Y-%m-%d %H:%M:%S')
    month=[i.month for i in df["sign_time"]]
    df['month']=month
    df.drop(['sign_time'], axis=1, inplace=True)


    bt_df1=df[['heating_type','hdic_resblock_id','decoration']]
    dummies_hdic_resblock_id = pd.get_dummies(bt_df1['hdic_resblock_id'], prefix= 'hdic_resblock_id')
    dummies_decoration = pd.get_dummies(bt_df1['decoration'], prefix= 'decoration')
    bt_df1 = pd.concat([bt_df1,dummies_decoration,dummies_hdic_resblock_id], axis=1)
    bt_df1.drop(['decoration','hdic_resblock_id'], axis=1, inplace=True)
    ye_1=bt_df1[bt_df1['heating_type']==0]
    no_1=bt_df1[bt_df1['heating_type']!=0]
    ye_ma1=ye_1.as_matrix()
    no_ma1=no_1.as_matrix()
    y1=no_ma1[:,0]
    X1=no_ma1[:,1:]
    non1=ye_ma1[:,1:]
    clf1=RandomForestClassifier(oob_score=True, random_state=10)
    clf1.fit(X1,y1)
    pred1=clf1.predict(non1)
    df.loc[ (bt_df1['heating_type']==0), 'heating_type' ] = pred1
    #print df['heating_type'].value_counts()
    #print df['building_type'].value_counts()
    #print df.head()



    #dummies_hdic_resblock_id = pd.get_dummies(df['hdic_resblock_id'], prefix= 'hdic_resblock_id')
    #dummies_hdic_building_id = pd.get_dummies(df['hdic_building_id'], prefix= 'hdic_building_id')
    dummies_decoration = pd.get_dummies(df['decoration'], prefix= 'decoration')
    dummies_heating_type = pd.get_dummies(df['heating_type'], prefix= 'heating_type')
    dummies_rent_type = pd.get_dummies(df['rent_type'], prefix= 'rent_type')
    dummies_month = pd.get_dummies(df['month'], prefix= 'month')
    dummies_floor_level = pd.get_dummies(df['floor_level'], prefix= 'floor_level')
    df= pd.concat([df,dummies_decoration,dummies_heating_type,dummies_rent_type,dummies_month,dummies_floor_level], axis=1)
    df.drop(['hdic_resblock_id','decoration','heating_type','rent_type','month','floor_level'], axis=1, inplace=True)

    df[['building_year']]=2017-df[['building_finish_year']]
    df.drop(['building_finish_year'],axis=1,inplace=True)

    df.insert(26,"month_2", np.zeros(len(df['month_1'])))
    df.insert(27,"month_3", np.zeros(len(df['month_1'])))
    df.insert(28,"month_4", np.zeros(len(df['month_1'])))
    df.insert(29,"month_5", np.zeros(len(df['month_1'])))
    df.insert(30,"month_6", np.zeros(len(df['month_1'])))
    df.insert(31,"month_7", np.zeros(len(df['month_1'])))
    df.insert(32,"month_8", np.zeros(len(df['month_1'])))
    df.insert(33,"month_9", np.zeros(len(df['month_1'])))
    df.insert(34,"month_10", np.zeros(len(df['month_1'])))
    df.insert(35,"month_11", np.zeros(len(df['month_1'])))
    #df.to_csv("after_pre.csv",index=False)
    return df
    print(df.info())

