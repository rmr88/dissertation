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
//TODO: get Annenberg data, merge in here (or in the dependent DO files).

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
merge 1:1 state district cong using "$dataDir\ACS\acsData.dta", nogen
save "$dataDir\districtData.dta", replace


*** Legislator Level ***

run "$codeDir\ch2_contrib.do"
run "$codeDir\ch2_voteData.do"

merge m:1 govTrackID using "$dataDir\working\idsMerged.dta", ///
	update nogen
drop if missing(icpsrID)

**HARDCODES**
replace district = 1 if govTrackID == 400443 //Stephanie Herseth
replace district = 45 if govTrackID == 400039 //Mary Bono Mack
replace district = 39 if govTrackID == 400355 //Linda Sanchez
//end hardcodes

merge m:1 icpsrID cong using "$dataDir\IssuePublics\contrib_data.dta", ///
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

/*
egen missing = rowmiss(wnom* amtH*)
drop if missing == 7
drop missing
*/

*Merge Data
merge m:1 state district cong using "$dataDir\districtData.dta", nogen

save "$dataDir\legisData.dta", replace
//TODO: get cosponsorship data measures, merge in here.


*** Prep for Analysis ***

use "$dataDir\legisData.dta", clear

*MC Characteristics
encode gender, gen(gend)
encode relig, gen(rel)
encode state, gen(st)
gen birthYear = substr(dob, 1, 4)
destring birthYear, replace

*District Characteristics
encode region, gen(reg)

gen percSenior = pop65to74 + popOver75
replace pop = pop - popUnder5 - pop5to17
gen phys_perc = 100 * count_corrected / pop
replace unins_rate = unins_rate * 100

//factor healthChip10 healthACA10 healthChip08 healthMand08 healthCost06 healthSatis06 healthEmplSpons06 healthPers06
//TODO: Add NAES measures here, see if they scale with CCES well.
factor health*0? health*10, factors(2)
rotate
predict healthOpinion

factor healthChip10 healthACA10 healthChip08 healthMand08 healthCost06 healthSatis06 healthEmplSpons06 healthPers06, factors(1)
rotate
predict healthOpinion2
replace healthOpinion = healthOpinion2 if missing(healthOpinion)
drop healthOpinion2

*Contributions
//factor amt*
//rotate
gen amt = amtH02 + amtH03 + amtH04

foreach var of varlist amt* medianIncome {
	replace `var' = `var' / 1000
}

/*
Amount codes:
01 = Providers
02 = Hospitals
03 = Payers/ HMOs
04 = Pharma and Devices
05 = Other?
*/

*Keep only necessary variables, observations
keep govTrackID cong gend birthYear reg party st pop amt* ///
	hospitals percSenior count_corrected count_raw phys_perc ///
	unins_rate IP_voter healthOpinion race* medianIncome /// 
	educ* billtype billnum rollnum minor vote
drop if missing(govTrackID)

*Final clean up of bills
//merge 1:m govTrackID cong using "C:\Users\Robbie\Documents\dissertation\Data\PolicyAgendasProject\healthVotesList.dta"
drop if cong == 111 & billtype == "HR" & billnum == 3590 & rollnum == 768 //this is a non-health related version of the ACA under the same bill #.
drop if cong == 111 & billtype == "HR" & billnum == 3962 & rollnum == 393 //this is the initial vote on HCERA, ACA's companion reconciliation bill, before the health care provisions were added
drop if cong == 111 & billtype == "HR" & billnum == 3961 & rollnum == 67 //This is an SGR bill that was altered to become a bill reauthorizing parts of the Patriot Act
drop if cong == 110 & billtype == "HR" & billnum == 6331 & rollnum == 177 //senate vote

replace vote = "" if vote == "0" | vote == "P"
replace vote = "1" if vote == "+"
replace vote = "0" if vote == "-"
destring vote, replace

*Labels
label define MINOR 300 "General" 301 "Comprehensive Reform" ///
	302 "Insurance Reform" 321 "Drug Industry" 322 "Facilities" ///
	323 "Payment" 324 "Liability" 325 "Workforce" 331 "Prevention" ///
	332 "Children" 333 "Mental Illness" 334 "Long-term Care" ///
	335 "Drug Coverage/ Cost" 336 "Other Benefits" 341 "Tobacco" ///
	342 "Substance Abuse" 398 "Research" 399 "Other", modify
label values minor MINOR

label variable vote ""
label variable amt "Hospital, HMO, Pharma/ Device Contributions ($1,000s)"
label variable amtH01 "Provider Contributions ($1,000s)"
label variable amtBCBS "BCBS Contributions ($1,000s)"
label variable amtAARP "AARP Contributions ($1,000s)"
label variable healthOpinion "Voter Health Opinion"
label variable IP_voter "Voter Ideology"
label variable percSenior "Percent Seniors"
label variable unins_rate "Percent Uninsured"
label variable count_corrected "Number of Doctors"
label variable raceWhite "Percent White"
label variable educHS "Percent HS Only"
label variable medianIncome "Median Income ($1,000s)"
label variable birthYear "Legislator Birth Year"
label variable minor "Minor Topic Code"
label variable party "Party"
label variable phys_perc "Percent Physicians"

*Rep Rangel's position on bill (potential DV)
gen rangel = vote if govTrackID == 400333
bys cong billtype billnum: egen rangel2 = mean(rangel)
gen agree_rangel = vote == rangel2
drop rangel rangel2

*Party position on bill
gen demYes = (party == 100) * vote
gen repYes = (party == 200) * vote
bys cong billtype billnum rollnum: egen demYesTotal = total(demYes)
bys cong billtype billnum rollnum: egen repYesTotal = total(repYes)
gen dem = party == 100
replace dem = . if missing(party) | party == 328
gen rep = party == 200
replace rep = . if missing(party) | party == 328
bys cong billtype billnum rollnum: egen demTotal = total(dem)
bys cong billtype billnum rollnum: egen repTotal = total(rep)
gen demYesPerc = demYesTotal / demTotal
gen repYesPerc = repYesTotal / repTotal
gen partyYesPerc = demYesPerc if party == 100
replace partyYesPerc = repYesPerc if party == 200
gen partyLineVote = (demYesPerc < 0.5 & repYesPerc >= 0.5) ///
	| (demYesPerc >= 0.5 & repYesPerc < 0.5)
drop demTotal repTotal demYes* repYes*
gen partyVote = round(partyYesPerc)
gen agree_party = vote == partyVote
gen agree_dem = abs(agree_party - (party == 200)) if partyLineVote
replace agree_dem = agree_party if !partyLineVote

label variable partyLineVote "Party Line Vote"

*Vote Groups
gen vote_group = "HEALTH Act" if billtype == "HR" & ((billnum == 5 & ///
	(cong == 108 | cong == 109 | cong == 112)) | (cong == 108 & billnum == 4280))
replace vote_group = "ACA and Related" if (cong == 111 & billnum == 3590) ///
	| (cong == 112 & (billnum == 2 | billnum == 1213 | billnum == 2576 | billnum == 6079))
replace vote_group = "CHIPRA 2007" if cong == 110 & (billnum == 3963 | billnum == 976)
replace vote_group = "MMA 2003" if cong == 108 & billnum == 1
replace vote_group = "SGR/ Doc Fix Bills" if (cong == 111 & billnum == 3961) | ///
	(cong == 110 & billnum == 6331 & rollnum != 177)
//replace vote_group = "Contact Lens Fairness Act" if cong == 108 & billnum == 3140
replace vote_group = "Insurance Reform Bills (108th)" if cong == 108 & minor == 302 & partyLineVote


save "$dataDir\ch2_analysisData.dta", replace

