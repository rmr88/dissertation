*** County-level ICPSR Election Results ***

//Robbie Richards, 1/13/16
//TODO: still need to handle 1950-1972 and 1824-1968, as well as state leg

*** Process files for 1970-1990 ***

*Append Files
cd "C:\Users\Robbie\Documents\dissertation\Data\elections\ICPSRfedResults"
cap erase "fedResults.dta"
foreach fileNum of numlist 1/3 5/15 {
	if (`fileNum' < 10) local stub = "000`fileNum'"
	else local stub = "00`fileNum'"
	
	di "Processing `stub'..."
	use "DS`stub'\00013-`stub'-Data.dta", clear
	run "DS`stub'\00013-`stub'-Supplemental_syntax.do"

	foreach var of varlist _all {
		local varLab : variable label `var'
		if (substr("`varLab'", 1, 1) == "9") ///
			local year = "1" + substr("`varLab'", 1, 3)
		
		if ("`varLab'" == "ICPSR VERSION NUMBER" | ///
				"`varLab'" == "ICPSR PART NUMBER") drop `var'
		else if ("`varLab'" == "ICPSR STATE CODE" | ///
				"`varLab'" == "ICPR STATE CODE" | "`varLab'" == "STATE") ///
			ren `var' state_icpsr
		else if ("`varLab'" == "COUNTY NAME") ren `var' county_name
		else if ("`varLab'" == "ICPSR COUNTY CODE" | ///
				"`varLab'" == "IDENTIFICATION NUMBER") ///
			ren `var' county_icpsr
		else if (substr("`varLab'", 1, 16) == "CONG DIST NUMBER" | ///
				"`varLab'" == "DISTRICT") ren `var' cd_icpsr
		else if (substr("`varLab'", 1, 16) == "STATE OFFICE SUB") ///
			ren `var' stOffCode
		else {
			local varLab = stritrim(regexr("`varLab'", " VOTE", ""))
			local varLab = regexr("`varLab'", "[0-9][0-9][0-9] [0-9] G ", "")
			
			if (strpos("`varLab'", "%") > 0) drop `var'
			else if (regexm("`varLab'", "([A-Z]+) 0100*")) {
				local newName = "votes" + strlower(regexs(1)) + "DEM`year'"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 0200")) {
				local newName = "votes" + strlower(regexs(1)) + "REP`year'"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) TOTAL")) {
				local newName = "votes" + strlower(regexs(1)) + "TOTAL`year'"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 1735")) {
				local newName = "votes" + strlower(regexs(1)) + "Lib`year'"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 2582")) {
				local newName = "votes" + strlower(regexs(1)) + "Gre`year'"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 1299")) {
				local newName = "votes" + strlower(regexs(1)) + "Con`year'"
				ren `var' `newName'
			}
			else drop `var'
		}	
	}
	
	local list ""
	foreach var of varlist votes*`year' {
		local list = "`list' " + subinstr("`var'", "`year'", "", .)
	}
	
	qui reshape long `list', i(county_name state_icpsr) j(year)
	cap append using "fedResults.dta"
	save "fedResults.dta", replace
}

*Total Other Votes
foreach off in pres sen cong gov state {
	egen `off'Oth = rowtotal(votes`off'*)
	gen votes`off'Oth = (2 * votes`off'TOTAL) - `off'Oth
	drop `off'Oth
}

*Fix County ICPSR IDs
replace county_name = "ARLINGTON/ALEXANDRIA" if county_name == "ARLINGTON/ALEXAND"
merge m:1 state_icpsr county_name using "C:\Users\Robbie\Documents\dissertation\Data\working\county_icpsr.dta", ///
	update nogen keep(1 3 4)
replace county_name_full = county_name
merge m:1 state_icpsr county_name_full using "C:\Users\Robbie\Documents\dissertation\Data\working\county_icpsr.dta", ///
	update nogen keep(1 3 4 5)
drop county_name_f* state_name state_fips

egen rightID = mode(county_icpsr), maxmode by(state_icpsr county_name)
replace county_icpsr = rightID if missing(county_icpsr)
drop rightID

*All Results, Long
preserve
	reshape long votespres votessen votescong votesgov votesstate, ///
	i(state_icpsr county* cd_icpsr year stOffCode) j(party) string
	reshape long votes, j(office) string ///
		i(state_icpsr county* cd_icpsr year stOffCode party)
	save "fedResults.dta", replace
restore

*Presidential Results Only, Wide
keep county_name state_icpsr year county_icpsr cd_icpsr votespres*
foreach var of varlist votes* {
	local new = subinstr("`var'", "votes", "", .)
	ren `var' `new'
}
drop if missing(presDEM) & missing(presREP) & missing(presTOTAL)

replace presOth = presOth + presLib + presCon
drop presLib presCon
ren presOth sumVotesOTH
ren presDEM sumVotesDEM
ren presREP sumVotesREP
ren presTOTAL totalVotes
gen partyVotes = sumVotesDEM + sumVotesREP

append using "ICPSR_00001\presDataPre1970.dta"
save "presData.dta", replace

/*
*State Leg results:
cd "C:\Users\Robbie\Documents\dissertation\Data\elections\stateLegData"
use "34297-0001-Data.dta", clear
run "34297-0001-Supplemental_syntax.do"

ren V01 stateNum
ren V02 state
ren V03 stateFIPS
ren V04 stateICPSR
ren V05 year
ren V06 month
ren V07 senOrHouse
ren V08 distName
ren V09 distNum
ren V10A distPostA
ren V10B distPostB
ren V10C distPostC
ren V10D distPostD
ren V10 distPost
ren V11 distID
ren V12 distType
ren V13 numWinners
ren V14 lenTermLaw
ren V15 lenTermActual
ren V16 elecType
ren V17 sitting
ren V18 candID
ren V19 candNameFull
ren V20 ptyCodeDet
ren V21 ptyCodeSimp
ren V22 incumbent
ren V23 candVotes
ren V24 elecWinner
ren V25 numCand
ren V26 numDem
ren V27 numRep
ren V28 numOth
ren V29 totalVotes
ren V30 demVotes
ren V31 repVotes
ren V32 othVotes
ren V33 highestPerc
ren V34 secHighPerc
ren V35 percMargin
ren V36 candPerc
ren V37 candMargin
ren V38 candName8907
ren V39 candName21480
ren V40 nameAdjusted
ren V41 missingInfo
ren V42 uncertainInfo
ren V43 uncertainVar
ren V44 candNameLast
ren V45 candNameFirst
ren V46 candNameMid1
ren V47 candNameMid2
ren V48 candNameMid3
ren V49 candNameMid4
ren V50 candNickname
ren V51 candNameSuff
ren V52 candNamePre
ren V53 candNameNum
ren V54 candNameLastAlt
ren V55 candNameAltType
ren V56 distNum21480
ren V57 distPost21480
ren V58 distName21480

save "stateLegResults.dta", replace
*/
