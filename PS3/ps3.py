
import math
import numpy as np
import statsmodels.api as stat
from scipy import stats
from matplotlib import pyplot as plt 
#Question 1 

alpha = 0
theta = 0
beta = 0.015
sigma_u = 0.053
sigma_v = 0.044
rho = -0.2 #-0.2 #-0.5
sigma_uv = rho*sigma_u*sigma_v

mean = [0, 0]
cov = [[sigma_u**2, sigma_uv], [sigma_uv, sigma_v**2]]
    
def reg(Y,X) : 
    X = stat.add_constant(X)                  
    return [stat.OLS(Y,X).fit().params, stat.OLS(Y,X).fit().tvalues,stat.OLS(Y,X).fit().pvalues] 

R=10
avg_beta =  np.zeros(R)
fivepc_beta = np.zeros(R)
nnfivepc_beta = np.zeros(R)

Tau=120
for T in range(Tau,Tau*(R+1),Tau):
    B=250
    estAlpha = np.zeros(B)
    estBeta =   np.zeros(B)
    tAlpha =  np.zeros(B)
    tBeta = np.zeros(B)
    pAlpha =  np.zeros(B)
    pBeta = np.zeros(B)
    for i in range(1,B+1):
        uv=np.random.multivariate_normal(mean, cov, (T+1))
        x=np.zeros(T+1)
        for t in range(1,T+1):
            x[t]= theta+ rho*x[t-1]+uv[t,1]
            r = alpha +beta *x[0:T-1]+uv[1:T,0]
            Z = x[0:T-1]
            temp = reg(r,Z)
            estAlpha[i-1] = temp[0][0]
            estBeta[i-1] = temp[0][1]
            tAlpha[i-1] = temp[1][0]
            tBeta[i-1] = temp[1][1]
            pAlpha[i-1] = temp[2][0]
            pBeta[i-1] = temp[2][1]  
    tt=int(T/Tau)
    avg_beta[tt-1] = np.average(estBeta)
    fivepc_beta[tt-1] = np.percentile(estBeta,5)
    nnfivepc_beta[tt-1] = np.percentile(estBeta,95)

plt.plot(range(Tau,Tau*(R+1),Tau), avg_beta)
plt.plot(range(Tau,Tau*(R+1),Tau), fivepc_beta)
plt.plot(range(Tau,Tau*(R+1),Tau), nnfivepc_beta)
