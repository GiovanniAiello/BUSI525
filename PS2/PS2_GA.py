
## Problem Set 2

from random import choices
import math
import numpy as np
import statsmodels.api as stat
from scipy import stats
from matplotlib import pyplot as plt 

#! Question 1 

N=1000 # number of funds 
T=120 #number of months
mkt_excess_ret = np.random.normal(0.05/12, 0.2/math.sqrt(12), size=(T)) #each month is one list in array.
eps = np.random.normal(0, 0.1/math.sqrt(12), size=(T, N)) #each month is one list in array.
beta = np.ones(N)
#plt.hist(mkt_excess_ret[2]) 
#plt.title("histogram") 
#plt.show()

#Part 1 alpha 0 
alpha = np.zeros(N)
fund_excess_ret = np.zeros((T,N))
for i in range(1,1001):
    for t in range(1,121):
        fund_excess_ret[t-1, i-1] = alpha[i-1] + beta[i-1]*mkt_excess_ret[t-1] + eps[t-1,i-1]

def reg(Y,X) : 
    X = stat.add_constant(X)                  
    return [stat.OLS(Y,X).fit().params, stat.OLS(Y,X).fit().tvalues,stat.OLS(Y,X).fit().pvalues] 

#Estimate alpha and t stat
estAlpha = np.zeros(N)
estBeta =   np.zeros(N)
tAlpha =  np.zeros(N)
tBeta = np.zeros(N)
pAlpha =  np.zeros(N)
pBeta = np.zeros(N)
for i in range(1,1001):
    Y = fund_excess_ret[:,i-1]
    X = mkt_excess_ret
    temp = reg(Y,X)
    estAlpha[i-1] = temp[0][0]
    estBeta[i-1] = temp[0][1]
    tAlpha[i-1] = temp[1][0]
    tBeta[i-1] = temp[1][1]
    pAlpha[i-1] = temp[2][0]
    pBeta[i-1] = temp[2][1]

# Residuals 

fund_excess_ret_hat = np.zeros((T,N))

for i in range(1,1001):
    for t in range(1,121):
        fund_excess_ret_hat[t-1, i-1] = estAlpha[i-1] + estBeta[i-1]*mkt_excess_ret[t-1] 


res =  fund_excess_ret - fund_excess_ret_hat 

#? Bootstrap Mkt ER
B = 100 # number of bootstrap
bs_fund_excess_ret = np.zeros((T,N))
bs_estAlpha = np.zeros((B,N))
bs_estBeta =   np.zeros((B,N))
bs_tAlpha =  np.zeros((B,N))
bs_tBeta = np.zeros((B,N))
bs_pAlpha =  np.zeros((B,N))
bs_pBeta = np.zeros((B,N))

for b in range(1,101):
    bs_mkt_excess_ret = choices(mkt_excess_ret, k=120)
    for i in range(1,1001):
        for t in range(1,121):
            bs_fund_excess_ret[t-1, i-1] = estBeta[i-1]*bs_mkt_excess_ret[t-1] + res[t-1,i-1]  
        X = bs_mkt_excess_ret
        Y = bs_fund_excess_ret[:,i-1]
        temp = reg(Y,X)
        bs_estAlpha[b-1,i-1] = temp[0][0]
        bs_estBeta[b-1,i-1] = temp[0][1]
        bs_tAlpha[b-1,i-1] = temp[1][0]
        bs_tBeta[b-1,i-1] = temp[1][1]
        bs_pAlpha[b-1,i-1] = temp[2][0]
        bs_pBeta[b-1, i-1] = temp[2][1]

avg_tAlpha =  np.zeros(B)
fivepc_tAlpha = np.zeros(B)
nnfivepc_tAlpha = np.zeros(B)

for b in range(1,101):
    avg_tAlpha[b-1] = np.average(bs_estAlpha[b-1,:])
    fivepc_tAlpha[b-1] = np.percentile(bs_estAlpha[b-1,:],5)
    nnfivepc_tAlpha[b-1] = np.percentile(bs_estAlpha[b-1,:],95)

plt.plot(np.sort(avg_tAlpha), np.linspace(0, 1, len(avg_tAlpha), endpoint=False))
plt.plot(np.sort(fivepc_tAlpha), np.linspace(0, 1, len(fivepc_tAlpha), endpoint=False))
plt.plot(np.sort(nnfivepc_tAlpha), np.linspace(0, 1, len(nnfivepc_tAlpha), endpoint=False))


          
# Part 2 

#change each lambda and legend of the graphs ie p values for alpha , lambda=0.1

lamb = 0.7

#N funds 
mkt_excess_ret = np.random.normal(0.05/12, 0.2/math.sqrt(12), size=(T)) #each month is one list in array.
eps = np.random.normal(0, 0.1/math.sqrt(12), size=(T, N)) #each month is one list in array.
beta = np.ones(N)
#plt.hist(mkt_excess_ret[2]) 
#plt.title("histogram") 
#plt.show()

alpha = np.zeros(N)
alpha[0:int(N*lamb)] = 0.01
fund_excess_ret = np.zeros((T,N))
for i in range(1,1001):
    for t in range(1,121):
        fund_excess_ret[t-1, i-1] = alpha[i-1] + beta[i-1]*mkt_excess_ret[t-1] + eps[t-1,i-1]

def reg(Y,X) : 
    X = stat.add_constant(X)                  
    return [stat.OLS(Y,X).fit().params, stat.OLS(Y,X).fit().tvalues,stat.OLS(Y,X).fit().pvalues] 

#Estimate alpha and t stat
estAlpha = np.zeros(N)
estBeta =   np.zeros(N)
tAlpha =  np.zeros(N)
tBeta = np.zeros(N)
pAlpha =  np.zeros(N)
pBeta = np.zeros(N)
for i in range(1,1001):
    Y = fund_excess_ret[:,i-1]
    X = mkt_excess_ret
    temp = reg(Y,X)
    estAlpha[i-1] = temp[0][0]
    estBeta[i-1] = temp[0][1]
    tAlpha[i-1] = temp[1][0]
    tBeta[i-1] = temp[1][1]
    pAlpha[i-1] = temp[2][0]
    pBeta[i-1] = temp[2][1]


# Residuals 

fund_excess_ret_hat = np.zeros((T,N))

for i in range(1,1001):
    for t in range(1,121):
        fund_excess_ret_hat[t-1, i-1] = estAlpha[i-1] + estBeta[i-1]*mkt_excess_ret[t-1] 


res =  fund_excess_ret - fund_excess_ret_hat 

#? Bootstrap Mkt ER
B = 100 # number of bootstrap
bs_fund_excess_ret = np.zeros((T,N))
bs_estAlpha = np.zeros((B,N))
bs_estBeta =   np.zeros((B,N))
bs_tAlpha =  np.zeros((B,N))
bs_tBeta = np.zeros((B,N))
bs_pAlpha =  np.zeros((B,N))
bs_pBeta = np.zeros((B,N))

for b in range(1,101):
    bs_mkt_excess_ret = choices(mkt_excess_ret, k=120)
    for i in range(1,1001):
        for t in range(1,121):
            bs_fund_excess_ret[t-1, i-1] = estBeta[i-1]*bs_mkt_excess_ret[t-1] + res[t-1,i-1]  
        X = bs_mkt_excess_ret
        Y = bs_fund_excess_ret[:,i-1]
        temp = reg(Y,X)
        bs_estAlpha[b-1,i-1] = temp[0][0]
        bs_estBeta[b-1,i-1] = temp[0][1]
        bs_tAlpha[b-1,i-1] = temp[1][0]
        bs_tBeta[b-1,i-1] = temp[1][1]
        bs_pAlpha[b-1,i-1] = temp[2][0]
        bs_pBeta[b-1, i-1] = temp[2][1]

avg_tAlpha =  np.zeros(B)
fivepc_tAlpha = np.zeros(B)
nnfivepc_tAlpha = np.zeros(B)

for b in range(1,101):
    avg_tAlpha[b-1] = np.average(bs_estAlpha[b-1,:])
    fivepc_tAlpha[b-1] = np.percentile(bs_estAlpha[b-1,:],5)
    nnfivepc_tAlpha[b-1] = np.percentile(bs_estAlpha[b-1,:],95)

plt.plot(np.sort(avg_tAlpha), np.linspace(0, 1, len(avg_tAlpha), endpoint=False))
plt.plot(np.sort(fivepc_tAlpha), np.linspace(0, 1, len(fivepc_tAlpha), endpoint=False))
plt.plot(np.sort(nnfivepc_tAlpha), np.linspace(0, 1, len(nnfivepc_tAlpha), endpoint=False))






