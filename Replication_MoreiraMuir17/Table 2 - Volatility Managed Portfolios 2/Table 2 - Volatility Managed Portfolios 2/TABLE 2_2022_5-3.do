*********************************
* Moreira Muir (2017) Replication  
* BUSI525
*********************************
cd "/Users/.../Downloads/Table 2 - Volatility Managed Portfolios 2"

* Install necessary programs 
ssc install asrol // rolling window statistics 
ssc install asreg // rolling window and group regressions 
ssc install asgen // weighted average 
*ssc install asdoc // sending output to MS Word 
ssc install astile // quartile groups / portfolios creation 
 
* F-F3
* Import and Convert data to Stata format

import delimited "F-F_Research_Data_Factors_daily.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "ff_factors_daily.dta", replace

* Import monthly factors data
import delimited "F-F_Research_Data_Factors_monthly.CSV", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "ff_factors_monthly", replace

use ff_factors_daily, clear


* Generate mean for each factor the whole in sample
egen mktavg = mean(mktrf+rf)


* Taking each corresponding entry from vector D and multuply by mkt, hml, smb respectively
gen wmkt = mktrf * -50.39742107
gen whml = hml *  -7.91463286
gen wsmb = smb *  59.3120539 

* the new factor weighted average
gen mveff3 = wmkt + whml + wsmb

* Find mean returns over the last 22 days for each factor
asrol mveff3, gen(avg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mveff3-avg22)^2



* generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)


* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace

* Load the monthly date and merge the deviations with it
use ff_factors_monthly, clear

merge 1:1 mofd using "variance" 

  
* Create a new factor that is a weighted average
gen wmkt = mktrf *5.32186783
gen whml = hml * 0.6567568
gen wsmb = smb *  -4.97862464

* the new factor weighted average
gen mveff3 = wmkt + whml + wsmb

tsset mofd

* Create lagged RV2
gen lag_RV2 = L.RV2


* find managed factors

* scale returns by variance
gen mveff3_1 = mveff3 / lag_RV2


* Rescale it so that it has the same volatility as mktrf
sum mveff3 
loc vol0 = r(sd)
sum  mveff3_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mveff3_1 = `C' * mveff3_1



* Annualize the factors
replace mveff3_1 = mveff3_1 * 12
replace mveff3 = mveff3 * 12


* Limit sample to 1926 to 2015
keep if tin(1926m7, 2015m4)

* Export the results to MS Word usng the addoc package.

asdoc reg mveff3_1 mveff3, cnames(FF3)  stat(rmse) replace nest tzok save(Table2.doc)




* F-F3 and MOM
* Import and Convert data to Stata format

import delimited "F-F_Research_Data_Factors_daily.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "ff_factors_daily.dta", replace

* Import monthly factors data
import delimited "F-F_Research_Data_Factors_monthly.CSV", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "ff_factors_monthly", replace

use ff_factors_daily, clear

gen mkt = mktrf + rf

*Weighted factors

* Do the same for monthly Create a new factor that is a weighted 
gen wmkt = mktrf * 0.46713705
gen whml = hml * 0.26019205
gen wsmb = smb * -0.50472062
gen wmom = mom * 0.77739153
* the new factor weighted average
gen mveff3_mom = wmkt + whml + wsmb + wmom

* Find mean returns over the last 22 days for each factor
asrol mveff3_mom, gen(avg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mveff3_mom-avg22)^2

* generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)


* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace

* Load the monthly date and merge the deviations with it
use ff_factors_monthly, clear

merge 1:1 mofd using "variance" 

tsset mofd

gen wmkt = mktrf * 0.43086172
gen whml = hml *  0.29760804
gen wsmb = smb * -0.26966032
gen wmom = mom *  0.54119056

* the new factor weighted average
gen mveff3_mom = wmkt + whml + wsmb + wmom

* Create lagged RV2
gen lag_RV2 = L.RV2


* find managed factors

* scale returns by variance
gen mveff3_mom_1 = mveff3_mom / lag_RV2

* Rescale it so that it has the same volatility as mktrf
sum mveff3_mom 
loc vol0 = r(sd)
sum  mveff3_mom_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mveff3_mom_1 = `C' * mveff3_mom_1



* Annualize the factors
replace mveff3_mom_1 = mveff3_mom_1 * 12
replace mveff3_mom = mveff3_mom * 12


* Limit sample to 1926 to 2015
keep if tin(1926m7, 2015m4)

* Export the results to MS Word usng the addoc package.

asdoc reg mveff3_mom_1 mveff3_mom, cnames(FF3MOM)  stat(rmse) append nest tzok save(Table2.doc)


* F-F5
* Import and Convert data to Stata format

import delimited "F-F_Research_Data_5_Factors_daily.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "ff_5_factors_daily.dta", replace

* Import monthly factors data
import delimited "F-F_Research_Data_5_Factors_monthly.CSV", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "ff_5_factors_monthly", replace

use ff_5_factors_daily, clear

* weighted factors
gen wmkt = mktrf * -0.03213021
gen whml = hml *  -0.08950597
gen wsmb = smb *   0.43772603
gen wrmw = rmw * 0.3957943 
gen wcma = cma *0.28811586

* the new factor weighted average
gen mveff5 = wmkt + whml + wsmb + wrmw + wcma

* Create a new factor that is a weighted average

* Find mean returns over the last 22 days for each factor
asrol mveff5, gen(avg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mveff5-avg22)^2


*generate montly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace

* Load the monthly date and merge the deviations with it
use ff_5_factors_monthly, clear

merge 1:1 mofd using "variance" 


tsset mofd


* Taking each corresponding entry from vector D and multuply by mkt, hml, smb respectively
gen wmkt = mktrf * -0.16834364
gen whml = hml *-0.09966475
gen wsmb = smb *  0.45255856
gen wrmw = rmw *   0.47383959
gen wcma = cma * 0.34161025

* the new factor weighted average
gen mveff5 = wmkt + whml + wsmb + wrmw + wcma


* Create lagged RV2
gen lag_RV2 = L.RV2

* find managed factors

* scale returns by variance
gen mveff5_1 = mveff5 / lag_RV2

* Rescale it so that it has the same volatility as mktrf
sum mveff5 
loc vol0 = r(sd)
sum  mveff5_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mveff5_1 = `C' * mveff5_1



* Annualize the factors
replace mveff5_1 = mveff5_1 * 12
replace mveff5 = mveff5 * 12


* Limit sample to 1926 to 2015
keep if tin(1963m7, 2015m4)

* Export the results to MS Word usng the addoc package.

asdoc reg mveff5_1 mveff5, cnames(FF5)  stat(rmse) nest tzok append nest tzok save(Table2.doc)


* F-F5 MOM
* Import and Convert data to Stata format

import delimited "F-F_Research_Data_5_Factors_daily.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "ff_5_factors_daily.dta", replace

* Import monthly factors data
import delimited "F-F_Research_Data_5_Factors_monthly.CSV", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "ff_5_factors_monthly", replace

use ff_5_factors_daily, clear

* Taking each corresponding entry from vector D and multuply by mkt, hml, smb respectively
gen wmkt = mktrf *-0.0742314
gen whml = hml * -0.38294985
gen wsmb = smb * 0.65706348
gen wrmw = rmw * 0.60688467
gen wcma = cma * 0.5924691
gen wmom = mom * -0.39923599
* the new factor weighted average
gen mveff5_mom = wmkt + whml + wsmb + wrmw + wcma + wmom


* Create a new factor that is a weighted average

* Find mean returns over the last 22 days for each factor
asrol mveff5_mom, gen(avg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mveff5_mom-avg22)^2


*generate montly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace

* Load the monthly date and merge the deviations with it
use ff_5_factors_monthly, clear

merge 1:1 mofd using "variance" 

tsset mofd

* Taking each corresponding entry from vector D and multuply by mkt, hml, smb respectively
gen wmkt = mktrf * -0.33154308
gen whml = hml * -0.39489556
gen wsmb = smb * 0.70937848
gen wrmw = rmw * 0.81299774
gen wcma = cma *  0.66837934
gen wmom = mom * -0.46431691
* the new factor weighted average
gen mveff5_mom = wmkt + whml + wsmb + wrmw + wcma + wmom

* Create lagged RV2
gen lag_RV2 = L.RV2

* find managed factors

* scale returns by variance
gen mveff5_mom_1 = mveff5_mom / lag_RV2

* Rescale it so that it has the same volatility as mktrf
sum mveff5_mom 
loc vol0 = r(sd)
sum  mveff5_mom_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mveff5_mom_1 = `C' * mveff5_mom_1


* Annualize the factors
replace mveff5_mom_1 =mveff5_mom_1 * 12
replace mveff5_mom = mveff5_mom * 12


* Limit sample to 1926 to 2015
keep if tin(1963m7, 2015m4)

* Export the results to MS Word usng the addoc package.

asdoc reg mveff5_mom_1 mveff5_mom, cnames(FF5MOM)  stat(rmse) nest tzok append nest tzok save(Table2.doc)


* HXZ
* Import and Convert data to Stata format

import delimited "q5_factors_daily_2021.csv", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "hxz_factors_daily.dta", replace


* Import monthly factors data
import delimited "q5_factors_monthly_2021.csv", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "hxz_factors_monthly", replace


use hxz_factors_daily, clear

*generate mktrf
gen mktrf = r_mkt - r_f


* Weights
gen wmkt = r_mkt *  0.1381881
gen wme = r_me * 0.04242714
gen wia = r_ia * 0.01302607
gen wroe = r_roe * -0.1201724
gen weg = r_eg *  0.92653109

* the new factor weighted average
gen mvehxz = wmkt + wme + wia + wroe + weg


* Find mean returns over the last 22 days for each factor
asrol mvehxz, gen(avg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mvehxz-avg22)^2

*generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace


* Load the monthly date and merge the deviations with it
use hxz_factors_monthly, clear

merge 1:1 mofd using "variance" 

tsset mofd

* weights
gen wmkt = r_mkt * 0.21789038
gen wme = r_me *  0.05749678
gen wia = r_ia * -0.0871123
gen wroe = r_roe * -0.16568837
gen weg = r_eg *  0.97741351

* the new factor weighted average
gen mvehxz = wmkt + wme + wia + wroe + weg

* Create lagged RV2
gen lag_RV2 = L.RV2

* find managed factors

* scale returns by variance
gen mvehxz_1 = mvehxz / lag_RV2

* Rescale it so that it has the same volatility as mktrf
sum mvehxz 
loc vol0 = r(sd)
sum  mvehxz_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mvehxz_1 = `C' * mvehxz_1



* Annualize the factors
replace mvehxz_1 = mvehxz_1 * 12
replace mvehxz = mvehxz * 12

* Limit sample to 1926 to 2015
keep if tin(1967m1, 2015m4)

* Appending Table2
asdoc reg mvehxz_1 mvehxz, cnames(HXZ)  stat(rmse) append nest tzok save(Table2.doc)



* HXZ_MOM
* Import and Convert data to Stata format

import delimited "q5_factors_daily_2021.csv", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "hxz_factors_daily.dta", replace


* Import monthly factors data
import delimited "q5_factors_monthly_2021.csv", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "hxz_factors_monthly", replace


use hxz_factors_daily, clear

*generate mktrf
gen mktrf = r_mkt - r_f


* Weights
gen wmkt = r_mkt * 0.13720719
gen wme = r_me * 0.04735358
gen wia = r_ia * 0.00833978
gen wroe = r_roe * -0.09925394
gen weg = r_eg * 0.93857211
gen wmom = mom * -0.03221872


* the new factor weighted average
gen mvehxz_mom = wmkt + wme + wia + wroe + weg + wmom


* Find mean returns over the last 22 days for each factor
asrol mvehxz_mom, gen(avg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mvehxz_mom-avg22)^2

*generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace


* Load the monthly date and merge the deviations with it
use hxz_factors_monthly, clear

merge 1:1 mofd using "variance" 

tsset mofd

* weights
gen wmkt = r_mkt * 0.05975742
gen wme = r_me *  -0.08823179
gen wia = r_ia *  -0.15874912
gen wroe = r_roe * -0.15874912
gen weg = r_eg * 0.97953045
gen wmom = mom *  -0.00928234

* the new factor weighted average
gen mvehxz_mom = wmkt + wme + wia + wroe + weg + wmom


* Create lagged RV2
gen lag_RV2 = L.RV2

* find managed factors

* scale returns by variance
gen mvehxz_1_mom = mvehxz_mom / lag_RV2

* Rescale it so that it has the same volatility as mktrf
sum mvehxz_mom
loc vol0 = r(sd)
sum  mvehxz_1_mom
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mvehxz_1_mom = `C' * mvehxz_1_mom



* Annualize the factors
replace mvehxz_1_mom = mvehxz_1_mom * 12
replace mvehxz_mom = mvehxz_mom * 12

* Limit sample to 1926 to 2015
keep if tin(1967m1, 2015m4)

* Appending Table2
asdoc reg mvehxz_1_mom mvehxz_mom, cnames(HXZMOM)  stat(rmse) append nest tzok save(Table2.doc)




********* END of TABLE 2 *****************

