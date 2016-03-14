************************
*  Read in MRP Scores  *
************************

//Robbie Richards, 2/23/16

cd "C:\Users\Robbie\Documents\dissertation\Data\mrpideo"


*** State Scores ***

import delimited using "state.csv", delim(",") clear
save "state.dta", replace

import delimited using "state_pty.csv", delim(",") clear
merge 1:1 abb using "state.dta", nogen

ren mrp_estimate state_est
ren mrp_sd state_sd
ren raw_mean st_raw_mean
ren raw_sd st_raw_sd

save "state.dta", replace


*** CD Scores ***

import delimited using "cd112.csv", delim(",") clear

drop if abb == "DC"
gen pre_year = 2010
gen post_year = 2012
gen cong = 112
destring mrp_*, replace force
ren sample_size2 sample_size

save "cd.dta", replace

import delimited using "cd113.csv", delim(",") clear

gen pre_year = 2012
gen post_year = 2014
gen cong = 113
destring sample_size, replace
ren name geo_name
ren state name

append using "cd.dta"

tostring cd_fips state_fips, replace
replace cd_fips = "0" + cd_fips if strlen(cd_fips) == 3
replace state_fips = "0" + state_fips if strlen(state_fips) == 1

gen district = substr(cd_fips, 3, .)
destring district, replace
drop if missing(district)

save "cd.dta", replace

merge m:1 abb using "state.dta", nogen update
drop if missing(district)

save "combined.dta", replace

