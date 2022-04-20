## Replication Moreira Muir 2017


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
#%matplotlib inline

import datetime as dt
from datetime import datetime
import statsmodels.api as sm

import os
current_directory = os.getcwd()
print(current_directory) 
os.chdir("/home/ga/Dropbox/00/87_Spring22/BUSI525/BUSI525/Replication_MoreiraMuir17/Data")


daily=pd.read_pickle('https://github.com/amoreira2/Lectures/blob/main/assets/data/daily.pkl?raw=true')

daily.index

from pandas.tseries.offsets import MonthEnd
endofmonth=daily.index+MonthEnd(0)
endofmonth

# We denote `realized variance` for the market return as `RV`
RV=daily[['vwretd']].groupby(endofmonth).var()
# rename column to clarify
RV=RV.rename(columns={'vwretd':'RV'})
RV.plot()

# calculate weights for the risky assets (market)
c=(5*(0.04**2)/252)
RV['Weight']=c/RV.RV

RV.Weight.plot()
RV.Weight.mean()


# plot the weights on the risk-free rate
(1-RV.Weight).plot()
plt.show()


# aggregate daily returns to monthly returns
Ret=(1+daily).groupby(endofmonth).prod()-1
# rename columns to clarify
Ret.tail()

# Merge Ret (monthly return) with RV (realized variance and weights)
df=RV.merge(Ret,how='left',left_index=True,right_index=True)
df.tail()


# compare with the weight before . It simply shifts the weght from month t to month t+1
df.Weight.shift(1).tail()

# now construct the return of the strategy
df['VMS']=df.Weight.shift(1)*df.vwretd+(1-df.Weight.shift(1))*df.rf

(df[['vwretd','VMS']]+1).cumprod().plot(logy=True)


## STEP 1 
# Import data (K. French website, Hou Website, Verdelhan website)
FF=pd.read_csv("F-F_Research_Data_5_Factors_2x3_daily.CSV")
RV_mkt=FF[['Mkt-RF']].groupby(endofmonth).var()
FF=FF.set_index(['date'])


## STEP 2
# Compute the previous month realized variance (proxy for portfolio conditional variance)
f_mkt=df.vwretd -df.rf
f_s_mkt = df.Weight.shift(1)*f_mkt

y=f_mkt
X= sm.add_constant(f_s_mkt)
model = sm.OLS(y, X, missing='drop').fit()
predictions = model.predict(X) # make the predictions by the model

# Print out the statistics
model.summary()


## STEP 3
# Compute the return of the strategy

## STEP 4
# Compute the alphas by regressig 

