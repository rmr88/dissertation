********************************
*  Ch. 2 Data - Issue Publics  *
********************************

//Robbie Richards, 8/15/16


*** SAHIE Data ***

//Source: Census Bureau Small Area Health Insurance Estimates, http://www.census.gov/did/www/sahie/data/20082014/index.html

*Setup
cd "C:\Users\Robbie\Documents\dissertation\Data"

import delimited using "IssuePublics\sahie_2012.csv", clear delim(",")
drop in 1/78

drop v26
foreach var of varlist _all {
	local name = strlower(subinstr(`var'[1], " ", "", .))
	ren `var' `name'
}
drop in 1

destring year geocat-pctliic_moe, replace force
replace statename = strtrim(statename)
replace countyname = strtrim(subinstr(countyname, " County", "", .))
replace statefips = strtrim(statefips)

keep if geocat == 50 & agecat == 0 & racecat == 0 & ///
	sexcat == 0 & iprcat == 0
keep statefips countyfips statename countyname nipr nui
compress

*Convert to CD
ren statefips STATEFP10
ren countyfips COUNTYFP10
merge 1:m STATEFP10 COUNTYFP10 using "cdShp\output112\data112.dta", ///
	keep(3) nogen keepusing(DISTRICT Shape_area shapeArea)
ren STATEFP10 statefips
ren COUNTYFP10 countyfips
ren DISTRICT district

gen unins = nui * shapeArea / Shape_area
gen denom = nipr * shapeArea / Shape_area

collapse unins denom, by(statefips district)
drop if district == ""
destring district, replace

replace district = 1 if district == 0
duplicates tag statefips dist, gen(d)
drop if d & unins < 1
drop d

merge 1:1 statefips district using "working\districts_2008.dta", ///
	keep(3) nogen

gen unins_rate = unins / denom
save "IssuePublics\sahie_byCD.dta", replace




*** Provider Data ***

//Source: CMS Provider PUF File, http://www.cms.gov/apps/ama/license.asp?file=http://download.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Downloads/Medicare_Provider_Util_Payment_PUF_CY2012_update.zip

use "IssuePublics\providers_2012.dta", clear
ren nppes_provider_state state
ren cd112fp district
destring district, replace force

collapse (count) npi, by(state district)
gen count_raw = npi
replace district = 0 if missing(district) | district == 98
collapse (sum) npi (max) count_raw, by(state district)
ren npi count_corrected

replace district = 1 if district == 0 & (state == "AK" | ///
	state == "DE" | state == "DC" | state == "MT" | state == "ND" | ///
	state == "SD" | state == "VT" | state == "WY")
drop if district == 0 | (district == 7 & state == "SD")

merge 1:1 state district using "IssuePublics\sahie_byCD.dta", nogen

save "IssuePublics\districtLevelData.dta", replace


*** Hospitals and Other Facilities ***
/*
//Source: CMS Provider of Services File, https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/Provider-of-Services/

import delimited using "IssuePublics\POS_CLIA_DEC10.csv", delim(",") clear
drop in 1
keep prov3230 prov2720 prov2905 fipstate fipcnty ssamsacd prov3225

ren prov3230 state
ren prov2720 address
ren prov2905 zip
ren prov3225 city
ren ssamsacd msa

save "IssuePublics\pos10.dta", replace

import delimited using "IssuePublics\POS_OTHER_DEC10.csv", delim(",") clear
drop in 1
keep prov3230 prov2720 prov2905 fipstate fipcnty ssamsacd prov3225

ren prov3230 state
ren prov2720 address
ren prov2905 zip
ren prov3225 city
ren ssamsacd msa

append using "IssuePublics\pos10.dta"
save "IssuePublics\pos10.dta", replace

//After GIS match and join operations:
shp2dta using "F:\cdMapping\matchedPOS.shp", genid(id) replace ///
	data("IssuePublics\hospitals.dta") coord("IssuePublics\hospCoord.dta") 
*/

use "IssuePublics\hospitals.dta", clear
ren fipstate fips
ren state state_addr
ren CD112FP district

merge m:1 fips using "working\states.dta", nogen keep(3) keepusing(state)

collapse (count) ObjectID, by(state district)
drop if missing(district) | state == "DC" | ///
	(state == "AR" & district == "05") | ///
	(state == "KS" & district == "05") | ///
	(state == "KY" & district == "07")
ren ObjectID hospitals

destring district, replace
replace district = 1 if district == 0

merge 1:1 state district using "IssuePublics\districtLevelData.dta", nogen

save "IssuePublics\districtLevelData.dta", replace


*** Medicare (Age) Data ***

//Source: Catalist CA_AGE column (proprietary dataset, but based on state voter files)

import delimited using "IssuePublics\ageData.txt", clear delim(tab) //Data is not for the right districts... Need to go back to Catalist and get the right districts
gen state = strupper(substr(distid, 1, 2))
gen district = subinstr(substr(distid, 3, .), "-", "", .)
destring district, replace
ren ca_age age

gen isSenior = age >= 65
collapse (mean) age (sum) isSenior, by(state district)

merge 1:1 state district using "IssuePublics\districtLevelData.dta", nogen

save "IssuePublics\districtLevelData.dta", replace

