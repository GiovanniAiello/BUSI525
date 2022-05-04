*********************************
* Moreira Muir (2017) Replication  
* BUSI525
*********************************
cd "/Users/.../Downloads/Table 3 - Volatility Managed Portfolios"

* Install necessary programs 
ssc install asrol // rolling window statistics 
ssc install asreg // rolling window and group regressions 
ssc install asgen // weighted average 
*ssc install asdoc // sending output to MS Word 
ssc install astile // quartile groups / portfolios creation 
 
* F-F3
* Import Recession Data

import delimited "USREC.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr


save "USREC", replace


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

* Find mean returns over the last 22 days for each factor
asrol mktrf, gen(avg22) window(date 22) stat(mean)  min(12)
asrol hml, gen(hmlavg22) window(date 22) stat(mean)  min(12)
asrol smb, gen(smbavg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mktrf-avg22)^2
gen devsmb = (smb-smbavg22)^2
gen devhml = (hml-hmlavg22)^2


* generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)
bys mofd : egen RV2smb = total(devsmb)
bys mofd : egen RV2hml = total(devhml)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace

* Load the monthly date and merge the deviations with it
use ff_factors_monthly, clear

merge 1:1 mofd using "variance" 

drop _merge

merge 1:1 mofd using "USREC" 

tsset mofd

* Create lagged RV2
gen lag_RV2 = L.RV2
gen lag_RV2smb = L.RV2smb
gen lag_RV2hml = L.RV2hml

* find managed factors

* scale returns by variance
gen mktrf_1 = mktrf / lag_RV2
gen hml_1 = hml / lag_RV2hml
gen smb_1 = smb / lag_RV2smb

* Rescale it so that it has the same volatility as mktrf
sum mktrf 
loc vol0 = r(sd)
sum  mktrf_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mktrf_1 = `C' * mktrf_1

* same for smb
sum smb 
loc vol0 = r(sd)
sum  smb_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace smb_1 = `C' * smb_1

* and hml
sum hml 
loc vol0 = r(sd)
sum  hml_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace hml_1 = `C' * hml_1


* Annualize the factors
replace mktrf_1 = mktrf_1 * 12
replace mktrf = mktrf * 12

replace smb = smb * 12
replace smb_1 = smb_1 * 12

replace hml_1 = hml_1 * 12
replace hml = hml * 12

* Limit sample to 1926 to 2015
keep if tin(1926m7, 2015m4)

* Create interaction variables
gen mktrf_rec = mktrf*rec
gen smb_rec = smb*rec
gen hml_rec = hml*rec

* Export the results to MS Word usng the addoc package.

asdoc reg mktrf_1 mktrf mktrf_rec, cnames(Mkt)  stat(rmse) replace nest tzok save(Table3.doc)
asdoc reg smb_1 smb smb_rec, cnames(SMB)  stat(rmse) nest tzok

asdoc reg hml_1 hml hml_rec, cnames(HML)  stat(rmse) nest tzok


* F-F5
* Import Recession Data

import delimited "USREC.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr


save "USREC", replace

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

* Find mean returns over the last 22 days for each factor
asrol mktrf, gen(avg22) window(date 22) stat(mean)  min(12)
asrol rmw, gen(rmwavg22) window(date 22) stat(mean)  min(12)
asrol cma, gen(cmaavg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mktrf-avg22)^2
gen devrmw = (rmw-rmwavg22)^2
gen devcma = (cma-cmaavg22)^2


*generate montly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)
bys mofd : egen RV2rmw = total(devrmw)
bys mofd : egen RV2cma = total(devcma)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace

* Load the monthly date and merge the deviations with it
use ff_5_factors_monthly, clear

merge 1:1 mofd using "variance" 
drop _merge

merge 1:1 mofd using "USREC" 


tsset mofd

* Create lagged RV2
gen lag_RV2 = L.RV2
gen lag_RV2rmw = L.RV2rmw
gen lag_RV2cma = L.RV2cma

* find managed factors

* scale returns by variance
gen mktrf_1 = mktrf / lag_RV2
gen rmw_1 = rmw / lag_RV2rmw
gen cma_1 = cma / lag_RV2rmw

* Rescale it so that it has the same volatility as mktrf
sum mktrf 
loc vol0 = r(sd)
sum  mktrf_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mktrf_1 = `C' * mktrf_1

* same for rmw
sum rmw
loc vol0 = r(sd)
sum  rmw_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace rmw_1 = `C' * rmw_1

* and cma
sum cma 
loc vol0 = r(sd)
sum  cma_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace cma_1 = `C' * cma_1


* Annualize the factors
replace mktrf_1 = mktrf_1 * 12
replace mktrf = mktrf * 12

replace rmw = rmw * 12
replace rmw_1 = rmw_1 * 12

replace cma_1 = cma_1 * 12
replace cma =cma * 12

* Limit sample to 1926 to 2015
keep if tin(1963m7, 2015m4)

* Create interaction variables
gen cma_rec = cma*rec
gen rmw_rec = rmw*rec

* Export the results to MS Word usng the addoc package.

asdoc reg cma_1 cma cma_rec, cnames(CMA)  stat(rmse) nest tzok append nest tzok save(Table3.doc)

asdoc reg rmw_1 rmw rmw_rec, cnames(RMW)  stat(rmse) nest tzok


* MOM
* Import Recession Data

import delimited "USREC.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr


save "USREC", replace

* Import and Convert data to Stata format

import delimited "F-F_Momentum_Factor_daily.csv", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "ff_mom_factor_daily.dta", replace


* Import monthly factors data
import delimited "F-F_Momentum_Factor.csv", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "ff_mom_factor_monthly", replace


use ff_mom_factor_daily, clear

* Find mean returns over the last 22 days for each factor
asrol mom, gen(momavg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen devmom = (mom-momavg22)^2

*generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2mom = total(devmom)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace


* Load the monthly date and merge the deviations with it
use ff_mom_factor_monthly, clear

merge 1:1 mofd using "variance" 

drop _merge

merge 1:1 mofd using "USREC" 


tsset mofd

* Create lagged RV2
gen lag_RV2mom = L.RV2mom

* find managed factors

* scale returns by variance
gen mom_1 = mom / lag_RV2mom

* Rescale it so that it has the same volatility as r mom
sum mom 
loc vol0 = r(sd)
sum  mom_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mom_1 = `C' * mom_1


* Annualize the factors
replace mom_1 = mom_1 * 12
replace mom = mom * 12

* Limit sample to 1926 to 2015
keep if tin(1927m1, 2015m4)

* Create interaction variables
gen mom_rec = mom*rec


* Appending Table3
asdoc reg mom_1 mom mom_rec, cnames(MOM)  stat(rmse) append nest tzok save(Table3.doc)




* HXZ
* Import Recession Data

import delimited "USREC.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr


save "USREC", replace

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

* Find mean returns over the last 22 days for each factor
asrol mktrf, gen(avg22) window(date 22) stat(mean)  min(12)
asrol r_ia, gen(iaavg22) window(date 22) stat(mean)  min(12)
asrol r_roe, gen(roeavg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen dev = (mktrf-avg22)^2
gen devroe = (r_roe-roeavg22)^2
gen devia = (r_ia-iaavg22)^2


*generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2 = total(dev)
bys mofd : egen RV2roe = total(devroe)
bys mofd : egen RV2ia = total(devia)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace


* Load the monthly date and merge the deviations with it
use hxz_factors_monthly, clear

merge 1:1 mofd using "variance" 

drop _merge

merge 1:1 mofd using "USREC" 


tsset mofd

* Create lagged RV2
gen lag_RV2 = L.RV2
gen lag_RV2roe = L.RV2roe
gen lag_RV2ia = L.RV2ia

* find managed factors

*generate mktrf
gen mktrf = r_mkt - r_f

* scale returns by variance
gen mktrf_1 = mktrf / lag_RV2
gen ia_1 = r_ia / lag_RV2ia
gen roe_1 = r_roe / lag_RV2roe

* Rescale it so that it has the same volatility as mktrf
sum mktrf 
loc vol0 = r(sd)
sum  mktrf_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace mktrf_1 = `C' * mktrf_1

* same for roe
sum r_roe 
loc vol0 = r(sd)
sum  roe_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace roe_1 = `C' * roe_1

* and ia
sum r_ia 
loc vol0 = r(sd)
sum  ia_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace ia_1 = `C' * ia_1


* Annualize the factors
replace mktrf_1 = mktrf_1 * 12
replace mktrf = mktrf * 12

replace r_roe = r_roe * 12
replace roe_1 = roe_1 * 12

replace ia_1 = ia_1 * 12
replace r_ia = r_ia * 12

* Limit sample to 1926 to 2015
keep if tin(1967m1, 2015m4)


* Create interaction variables
gen roe_rec = r_roe*rec
gen ia_rec = r_ia*rec

* Appending Table3
asdoc reg roe_1 r_roe roe_rec, cnames(ROE)  stat(rmse) append nest tzok save(Table3.doc)

asdoc reg ia_1 r_ia ia_rec, cnames(IA)  stat(rmse) nest tzok



* BAB
* Import Recession Data

import delimited "USREC.CSV", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr


save "USREC", replace

* Import and Convert data to Stata format

import delimited "BAB_daily.csv", clear

tostring date, gen(datestr)
drop date
gen date = date(datestr, "YMD")
format date %td
drop datestr
order date
save "BAB_daily.dta", replace


* Import monthly factors data
import delimited "BAB_monthly.csv", clear
tostring date, gen(datestr)
drop date
gen date = date(datestr, "YM")
gen mofd = mofd(date)
format mofd %tm
drop date
drop datestr

save "BAB_monthly", replace


use BAB_daily, clear

* Find mean returns over the last 22 days for each factor
asrol bab, gen(babavg22) window(date 22) stat(mean)  min(12)

* generate deviations
gen devbab = (bab-babavg22)^2

*generate monthly date
gen mofd = mofd(date)
format mofd %tm

* find total deviations
bys mofd : egen RV2bab = total(devbab)

* Convert to monthly frequency
bys mofd: keep if _n == _N

* Keep just the total deviations
keep mofd RV2*

save "variance", replace


* Load the monthly date and merge the deviations with it
use BAB_monthly, clear

merge 1:1 mofd using "variance" 

drop _merge

merge 1:1 mofd using "USREC" 


tsset mofd

* Create lagged RV2
gen lag_RV2bab = L.RV2bab

* find managed factors

* scale returns by variance
gen bab_1 = bab / lag_RV2bab

* Rescale it so that it has the same volatility as r mom
sum bab 
loc vol0 = r(sd)
sum  bab_1
loc vol1 = r(sd)
loc C = `vol0' / `vol1'
replace bab_1 = `C' * bab_1


* Annualize the factors
replace bab_1 = bab_1 * 12
replace bab = bab * 12

* Limit sample to 1926 to 2015
keep if tin(1930m12, 2015m4)


* Create interaction variables
gen bab_rec = bab*rec


* Appending Table3
asdoc reg bab_1 bab bab_rec, cnames(BAB)  stat(rmse) append nest tzok save(Table3.doc)




********* END of TABLE 1 *****************

