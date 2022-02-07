#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb  5 16:15:44 2022

@author: yeldagungor
"""
import math
import numpy as np
import statsmodels.api as stat
from scipy import stats
from matplotlib import pyplot as plt 
#Question 1 
N=1000 # number of funds 
T=120 #number of months
mkt_excess_ret = np.random.normal(0.05/12, 0.2/math.sqrt(12), size=(T, N)) #each month is one list in array.
eps = np.random.normal(0, 0.3/math.sqrt(12), size=(T, N)) #each month is one list in array.
beta = np.ones(N)
#plt.hist(mkt_excess_ret[2]) 
#plt.title("histogram") 
#plt.show()

#Part 1 alpha 0 
alpha = np.zeros(N)
exRet = np.zeros((T,N))
for i in range(1,1001):
    for k in range(1,121):
        exRet[k-1, i-1] = alpha[i-1] + beta[i-1]*mkt_excess_ret[k-1, i-1] + eps[k-1,i-1]

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
    Y = exRet[:,i-1]
    X = mkt_excess_ret[:,i-1]
    temp = reg(Y,X)
    estAlpha[i-1] = temp[0][0]
    estBeta[i-1] = temp[0][1]
    tAlpha[i-1] = temp[1][0]
    tBeta[i-1] = temp[1][1]
    pAlpha[i-1] = temp[2][0]
    pBeta[i-1] = temp[2][1]
    
#Sanity check: if the p values less than 0.05 then reject, it is significant
# we look for skilled alpha !=0, hypothesis above is alpha = 0     
# so how many of p values are smaller than 0.05 is the rephrased question

count = np.count_nonzero(pAlpha<0.05) #number of True
print(count)
    
plt.hist(estAlpha,bins='auto', color='#0504aa',alpha=0.7, rwidth=0.85) 
plt.title("histogram")   
plt.grid(axis='y', alpha=0.75)
plt.xlabel('alpha-value')
plt.ylabel('Frequency')
plt.title('Estimated Alpha')
plt.show() 

plt.hist(tAlpha,bins='auto', color='#0504aa',alpha=0.7, rwidth=0.85) 
plt.title("histogram")   
plt.grid(axis='y', alpha=0.75)
plt.xlabel('t-value')
plt.ylabel('Frequency')
plt.title('t-values for Alpha')
plt.show() 
    
    
plt.hist(pAlpha,bins='auto', color='#0504aa',alpha=0.7, rwidth=0.85) 
plt.title("histogram")   
plt.grid(axis='y', alpha=0.75)
plt.xlabel('p-value')
plt.ylabel('Frequency')
plt.title('p-values for Alpha')
plt.show() 
      
# similar to uniform distribution when hypothesis true. (alpha = prob of type I) 
    
# Part 2 

#change each lambda and legend of the graphs ie p values for alpha , lambda=0.1

lamb = 0.75

#N funds 
mkt_excess_ret = np.random.normal(0.05/12, 0.2/math.sqrt(12), size=(T, N)) #each month is one list in array.
eps = np.random.normal(0, 0.3/math.sqrt(12), size=(T, N)) #each month is one list in array.
beta = np.ones(N)
#plt.hist(mkt_excess_ret[2]) 
#plt.title("histogram") 
#plt.show()

alpha = np.zeros(N)
alpha[0:int(N*lamb)] = 0.025
exRet = np.zeros((T,N))
for i in range(1,1001):
    for k in range(1,121):
        exRet[k-1, i-1] = alpha[i-1] + beta[i-1]*mkt_excess_ret[k-1, i-1] + eps[k-1,i-1]

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
    Y = exRet[:,i-1]
    X = mkt_excess_ret[:,i-1]
    temp = reg(Y,X)
    estAlpha[i-1] = temp[0][0]
    estBeta[i-1] = temp[0][1]
    tAlpha[i-1] = temp[1][0]
    tBeta[i-1] = temp[1][1]
    pAlpha[i-1] = temp[2][0]
    pBeta[i-1] = temp[2][1]
    
#Sanity check: if the p values less than 0.05 then reject, it is significant
# we look for skilled alpha !=0, hypothesis above is alpha = 0     
# so how many of p values are smaller than 0.05 is the rephrased question

count = np.count_nonzero(pAlpha<0.05) #number of True
print(count)

plt.hist(estAlpha,bins='auto', color='#0504aa',alpha=0.7, rwidth=0.85) 
plt.title("histogram")   
plt.grid(axis='y', alpha=0.75)
plt.xlabel('alpha-value')
plt.ylabel('Frequency')
plt.title('Estimated Alpha')
plt.show() 
    
plt.hist(tAlpha,bins='auto', color='#0504aa',alpha=0.7, rwidth=0.85) 
plt.title("histogram")   
plt.grid(axis='y', alpha=0.75)
plt.xlabel('t-value')
plt.ylabel('Frequency')
plt.title('t-values for Alpha')
plt.show() 
    
    
plt.hist(pAlpha,bins='auto', color='#0504aa',alpha=0.7, rwidth=0.85) 
plt.title("histogram")   
plt.grid(axis='y', alpha=0.75)
plt.xlabel('p-value')
plt.ylabel('Frequency')
plt.title('p-values for Alpha')
plt.show() 

# since the the null hypothesis gets more false :) dist of the p-value gets around 0.
    
#How many of the truly skilled funds have insignificant alpha estimates?
# I put skilled funds in the beginning of the array so check that portion
#insig alpha means 0 which means hypothesis dnr p value must be bigger than 0.05

count_1 = np.count_nonzero(pAlpha[0:int(N*lamb)]>0.05) #number of True
print(count_1)


#And how many of the truly unskilled funds are identified as skilled based on significantly positive alpha estimates?
count_2 = np.count_nonzero(pAlpha[int(N*lamb):]<0.05) #number of True
print(count_2)


yy = 100*(int(N*lamb)- count_1)/N
yn = 100*(count_1)/N
ny = 100*(count_2)/N
nn = 100*(N- int(N*lamb)- count_2)/N




