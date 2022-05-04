#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May  3 13:39:05 2022

@author: yeldagungor
"""

import statsmodels.api as sm
import pandas as pd
import numpy as np
from scipy.stats import rankdata

#! Import and Transform the data 

data_daily = pd.read_csv("F-F_Research_Data_Factors_daily.csv", low_memory=False) 
#data_monthly = pd.read_csv("F-F_Research_Data_Factors_monthly.csv", low_memory=False) 
data = data_daily.drop('date',axis = 1)
data = data.drop('RF',axis = 1)
mu = data_daily.mean()
mu_rf =mu.RF 
mu = mu.drop('date')
mu = mu.drop('RF')
iota = np.ones((1,len(mu)),dtype = int)
iota_t = np.ones((len(mu), 1),dtype = int)
#np.matmul(iota,iota_t)

sigmaInv = np.linalg.inv(data.cov())
mu_np = mu.to_numpy()
m = np.asmatrix(mu_np)
pi_t= sigmaInv*(m.T - mu_rf*iota_t)/(np.matmul(iota,sigmaInv*(m.T - mu_rf*iota_t)))



