**************************
*  Append Election Data  *
**************************

//Robbie Richards, 3/28/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections"


*** 1991-2015 ***

*Prep
use "polidata\_polidataResults.dta", clear
gen source = "Polidata"
merge 1:1 state year office district using "EDAD\heda_cd.dta", nogen
replace source = "HEDA-CD" if missing(source)
drop if mod(year, 2) != 0 //remove any odd-year federal elections that have slipped through (shouldn't happen)
drop if state == "VA" & year == 2008 & office == 3 //there is an issue with this data in HEDA; correct data will be brought in from stateResults
drop if state == "VA" & year == 2008 & office == 1 & district > 11

merge 1:1 state year office district using "stateResults\ussData.dta", nogen
replace source = "States-USS" if missing(source)
merge 1:1 state year office district using "stateResults\stateResults.dta", nogen
replace source = "States-all" if missing(source)
merge 1:1 state year office district using "EDAD\heda_state.dta", nogen
replace source = "HEDA-SW" if missing(source)

replace partyVotes = sumVotesDEM + sumVotesREP
replace partyVotes = sumVotesDEM if missing(sumVotesREP)
replace partyVotes = sumVotesREP if missing(sumVotesDEM)

//drop if office == 3 & district == .
drop if year < 1991
drop if state == "MI" & !missing(district) & ///
	((district > 15 & year == 2004) | (district > 16 & year == 2000))
drop if state == "MI" & !missing(district) & district == 22

*Non-USP data
preserve
	drop if office == 1
	save "allElectionData.dta", replace
restore

*Pull out Presidential data
keep if office == 1
drop office max*
merge m:m state using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen keepusing(state_icpsr) keep(3 4 5) update

preserve
	keep if district == . & (year == 2008 | year == 2012)
	drop district
	save "uspStateData.dta", replace
restore

drop if district == .

gen id = (state_icpsr*1000) + district
xtset id year
tsfill
replace state = state[_n-1] if state == ""
forvalues n = 1/3 {
	foreach var of varlist *Votes* district state_icpsr {
		replace `var' = l`n'.`var' if missing(`var') & !missing(l`n'.`var')
	}
}
drop id
save "uspCDdata.dta", replace //there's still a district missing in 2000...

drop if year > 2007
collapse (sum) sumVotesDEM sumVotesREP sumVotesOTH totalVotes ///
	partyVotes, by(state year source)
append using "uspStateData.dta"
merge m:m state using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen keepusing(state_icpsr) keep(3 4 5) update
	
xtset state_icpsr year
tsfill

replace state = state[_n-1] if state == ""
forvalues n = 1/3 {
	foreach var of varlist *Votes* {
		replace `var' = l`n'.`var' if missing(`var') & !missing(l`n'.`var')
	}
}

save "uspStateData.dta", replace


*** Pre-1992 Overall and State Leg Results ***

*Prep pre-1992 data
//run "C:\Users\Robbie\Documents\dissertation\Code\electionDataIcpsr0002.do"
use "electionDataPreScore.dta", clear
drop if elec_type != "G" & elec_type != ""
drop if state_icpsr == 63 & year == 1890 & office == 3 & ///
	district == 98 & missing(month)

replace partyVotes = sumVotesDEM + sumVotesREP
replace partyVotes = sumVotesDEM if missing(sumVotesREP)
replace partyVotes = sumVotesREP if missing(sumVotesDEM)

collapse (firstnm) month sumVotesDEM-candNameREP (sum) totalVotes ///
	partyVotes cands partyCands (min) oneMajorCand uncontested, ///
	by(state_icpsr year office district distPost distType numWinners)
gen source = "ICPSR"

*Combine with post-1992 data
append using "allElectionData.dta"
merge m:m state_icpsr using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen update keepusing(state)
merge m:m state using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen update keepusing(state_icpsr) keep(3 4 5)
drop if state == "DC"

*Dem index, statewide
preserve //All offices
	drop if office == 1
	collapse (mean) avgCands=cands percUncontested=uncontested ///
		percOneMCand=oneMajorCand avgPartyCands=partyCands ///
		(sum) swVotesDEM=sumVotesDEM swVotesREP=sumVotesREP ///
		swTotalVotes=totalVotes swPartyVotes=partyVotes, ///
		by(state_icpsr year) //may want some indication of number of offices, total number of candidates overall, etc.
	gen demScore = swVotesDEM / swPartyVotes
	save "swCompScores.dta", replace
restore

preserve //No state legislature
	drop if office == 1 | office > 7
	collapse (sum) swVotesDEM_nostl=sumVotesDEM ///
		swPartyVotes_nostl=partyVotes, by(state_icpsr year)
	gen demScore_nostl = swVotesDEM_nostl / swPartyVotes_nostl
	merge 1:1 state_icpsr year using "swCompScores.dta", nogen
	save "swCompScores.dta", replace
restore

preserve //Governor and federal only
	drop if office == 1 | office >= 7
	collapse (sum) swVotesDEM_govfed=sumVotesDEM ///
		swPartyVotes_govfed=partyVotes, by(state_icpsr year)
	gen demScore_govfed = swVotesDEM_govfed / swPartyVotes_govfed
	merge 1:1 state_icpsr year using "swCompScores.dta", nogen
	save "swCompScores.dta", replace
restore

preserve //Statewide only
	drop if office == 1 | office == 3 | office > 7
	collapse (sum) swVotesDEM_statewide=sumVotesDEM ///
		swPartyVotes_statewide=partyVotes, by(state_icpsr year)
	gen demScore_statewide = swVotesDEM_statewide / swPartyVotes_statewide
	merge 1:1 state_icpsr year using "swCompScores.dta", nogen
	save "swCompScores.dta", replace
restore

*Dem index, office-specific
merge m:1 state_icpsr year using "swCompScores.dta", nogen
gen demScoreOff = (swVotesDEM - sumVotesDEM) / (swPartyVotes - partyVotes) ///
	if office != 1
gen demScoreOff_nostl = (swVotesDEM_nostl - sumVotesDEM) / ///
	(swPartyVotes_nostl - partyVotes) if office != 1
gen demScoreOff_govfed = (swVotesDEM_govfed - sumVotesDEM) / ///
	(swPartyVotes_govfed - partyVotes) if office != 1
/*
pwcorr demScore* if year > 1967 & office == 3, sig
*/ //indices all highly correlated , rho > 0.85 for all.

*Office dummies
gen gov = office == 2
gen uss = office >= 4 & office <= 6
gen stexec = office == 7
bys state_icpsr year: egen hasGov = max(gov)
bys state_icpsr year: egen hasUss = max(uss)
bys state_icpsr year: egen hasStexec = max(stexec)
drop gov uss stexec

*Non-USP election data
preserve
	drop if office == 1
	replace district = . if district == 0 & office != 3
	save "allElectionData.dta", replace
restore


*** Presidential Election Data ***

keep if office == 1
keep state state_icpsr year sumVotes* maxVotesOTH totalVotes ///
	partyVotes cands
	
*Add missing CO 1944 results (hardcode)
local newN = _N + 1
set obs `newN'
replace state = "CO" if state == ""
replace year = 1944 if year == .
replace sumVotesDEM = 234331 if state == "CO" & year == 1944
replace sumVotesREP = 268371 if state == "CO" & year == 1944
replace totalVotes = 505039 if state == "CO" & year == 1944
replace partyVotes = sumVotesDEM + sumVotesREP if missing(partyVotes)
replace cands = 5 if state == "CO" & year == 1944

append using "uspStateData.dta"
save "uspStateData.dta", replace

//use "uspStateData.dta", replace
drop if year < 1867
gen type = "state"

append using "uspCDdata.dta"
append using "presByCD.dta"
replace type = "cd" if missing(type)

*Demean Pres. vote by year (separately for state data, CD data)
gen uspDEM = sumVotesDEM / partyVotes
gen uspREP = sumVotesREP / partyVotes
egen uspMeanDEM = mean(uspDEM), by(type year)
egen uspMeanREP = mean(uspREP), by(type year)
gen uspDEMdm = uspDEM - uspMeanDEM
gen uspREPdm = uspREP - uspMeanREP

keep state_icpsr state year district type usp*
save "uspData.dta", replace

*Merge back into other election data
use "allElectionData.dta", clear
replace district = 1 if district == 98

duplicates tag office state year district distPost ///
	distType numWinners, gen(d)
sort state year office district totalVotes
bys office state year district: gen n = _n
replace district = . if n == 2 & d > 0
drop d n

drop if year < 1868

gen offSmall = 4 if office == 4 | office == 5 | office == 6
replace offSmall = office if missing(offSmall)
drop if offSmall == 4 & ((state == "AK" & year == 1958) ///
	| (state == "HI" & year == 1959))

replace office = class + 3 if offSmall == 4 & ///
	source == "States-USS"
drop if offSmall == 4 & missing(class) & ///
	(source == "HEDA-SW" | source == "States-all")
drop class

drop if state_icpsr == 4 & year == 1878 & office == 2 & month == 3
drop if state_icpsr == 49 & year == 1972 & office == 2 & month == .

duplicates tag state district office year source ///
	distPost distType numWinners, gen(d)
drop if d & missing(totalVotes)
drop d
duplicates tag state district office year source ///
	distPost distType numWinners, gen(d)
drop if d
drop d

gen id = state + "-" + string(district) + "-" + string(office) ///
	+ string(distPost) + string(distType) + string(numWinners)
encode id, gen(distID)
xtset distID year
gen marker = 1
tsfill

forvalues n = 1/3 {
	foreach var of varlist state_icpsr district office offSmall distID {
		replace `var' = l`n'.`var' if missing(`var') & !missing(l`n'.`var')
	}
}

merge m:1 state_icpsr year district using "uspData.dta", nogen keep(1 3)
//office code 7 and odd-year elections will not have any pres votes, and state leg. offices will have incorrect ones. could fix later if necessary

xtset distID year
forvalues n = 1/3 {
	foreach var of varlist usp* {
		replace `var' = l`n'.`var' if missing(`var') & !missing(l`n'.`var')
	}
}

keep if marker == 1
drop marker

save "allElectionData.dta", replace

