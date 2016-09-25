****************************
*  Ch. 2 - Main Data Code  *
****************************

//Robbie Richards, 8/17/16


*** Setup ***

global codeDir = "C:\Users\Robbie\Documents\dissertation\Code"
global dataDir = "C:\Users\Robbie\Documents\dissertation\Data"


*** District Level ***

run "$codeDir\ch2_pubOp.do"
run "$codeDir\ch2_issuePublics.do"

merge 1:1 state district using "$dataDir\pubOpDataMerged.dta", nogen
save "$dataDir\districtData.dta", replace
//TODO: get Catalist age data, geocoded hospital data, and Annenberg data, merge in here (or in the dependent DO files).

ren statefips fips
destring fips, replace
replace fips = 11 if state == "DC"
merge m:1 fips using "C:\Users\Robbie\Documents\gunPolicy\Data\regions.dta", nogen
save "$dataDir\districtData.dta", replace

use "$dataDir\elections\allElectionData.dta", clear

keep if offSmall == 3
keep if year >= 2002 & year < 2012

gen partyComp = 1 - abs(demScoreOff - 0.5)
gen percDem = maxVotesDEM / partyVotes

keep state district year partyComp percDem
replace year = ((year - 1788) / 2) + 1
ren year cong
drop if district == 80

merge m:1 state district using "$dataDir\districtData.dta", nogen //11 district-years missing...
save "$dataDir\districtData.dta", replace


*** Legislator Level ***

run "$codeDir\ch2_contrib.do"
run "$codeDir\ch2_voteData.do"

merge 1:m govTrackID using "$dataDir\working\idsMerged.dta", ///
	update gen(_merge2) keepusing(icpsrID state district party)

**HARDCODES**
replace icpsrID = 29775 if govTrackID == 400039
replace icpsrID = 20350 if govTrackID == 400096
replace icpsrID = 20349 if govTrackID == 400443
drop if missing(govTrackID) & (icpsrID == 20349 | icpsrID == 20758)
drop if icpsrID == 29775 & govTrackID == 401587

replace state = "TN" if govTrackID == 400096 //Lincoln Davis
replace district = 4 if govTrackID == 400096
replace state = "SD" if govTrackID == 400443 //Stephanie Herseth
replace district = 1 if govTrackID == 400443
replace state = "CA" if govTrackID == 400039 //Mary Bono Mack
replace district = 45 if govTrackID == 400039
replace state = "LA" if govTrackID == 400006 //Rodney Alexander
replace district = 5 if govTrackID == 400006
replace state = "FL" if govTrackID == 412250 //Gus Bilirakis
replace district = 12 if govTrackID == 412250
replace district = 39 if govTrackID == 400355 //Linda Sanchez
//end hardcodes

drop if missing(icpsrID) & _merge2 == 1
drop _merge2 first

merge 1:1 icpsrID using "$dataDir\IssuePublics\contrib_data.dta", ///
	keep(2 3) nogen

**HARRDCODES**
replace district = 1 if icpsrID == 12009 //CLAY, WILLIAM LACY JR
replace state = "MO" if icpsrID == 12009
replace district = 5 if icpsrID == 20327 //Rodney Alexander
replace state = "LA" if icpsrID == 20327
replace district = 5 if icpsrID == 90901 //Virgil Goode
replace state = "VA" if icpsrID == 90901
replace district = 3 if icpsrID == 94679 //Billy Tauzin
replace state = "LA" if icpsrID == 94679
//end hardcodes

reshape long wnom1_ wnom2_ amtH01_ amtH02_ amtH03_ amtH04_ amtH05_, ///
	i(govTrackID icpsrID) j(cong)
foreach var in wnom1_ wnom2_ amtH01_ amtH02_ amtH03_ amtH04_ amtH05_ {
	local newvar = subinstr("`var'", "_", "", .)
	ren `var' `newvar'
}

/*
egen missing = rowmiss(wnom* amtH*)
drop if missing == 7
drop missing
*/
save "$dataDir\legisData.dta", replace
//TODO: get cosponsorship data measures, merge in here.


*** Combine Data ***

merge m:1 state district cong using "$dataDir\districtData.dta"
encode region, gen(reg)
save "$dataDir\ch2_analysisData.dta", replace

