*********************************
* Moreira Muir (2017) Replication  
* BUSI525
*********************************
cd "/Users/.../Downloads/Figure 3 - Volatility Managed Portfolios"

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
di "`C'"

* Graphs
gen cum_mkt = sum(mktrf)
gen cum_mkt1 = sum(mktrf_1)

tsline cum_mkt cum_mkt1, saving(Figure3) 



********* END of Figure 3 *****************

