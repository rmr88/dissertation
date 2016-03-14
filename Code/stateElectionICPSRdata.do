*** County-level ICPSR Election Results ***

//Robbie Richards, 1/13/16
//TODO: still need to handle 1950-1972 and 1824-1968, as well as state leg

*Process files for 1974-1990
cd "C:\Users\Robbie\Documents\dissertation\Data\elections\ICPSRfedResults"
cap erase "fedResults.dta"
foreach fileNum of numlist 1 2 5/15 {
	if (`fileNum' < 10) local stub = "000`fileNum'"
	else local stub = "00`fileNum'"
	
	use "DS`stub'\00013-`stub'-Data.dta", clear
	run "DS`stub'\00013-`stub'-Supplemental_syntax.do"
	
	local year = "1"
	foreach var of varlist _all {
		local varLab : variable label `var'
		
		//Get election year from first var label that has it
		if ("`year'" == "1" & substr("`varLab'", 1, 1) == "9") {
			local year = "1" + substr("`varLab'", 1, 3)
			di "`year'"
		}
		
		if ("`varLab'" == "ICPSR STUDY NUMBER" | "`varLab'" == "IDENTIFICATION NUMBER") {
			ren `var' studyNum
		}
		else if ("`varLab'" == "ICPSR VERSION NUMBER" | "`varLab'" == "ICPSR PART NUMBER") {
			drop `var'
		}
		else if ("`varLab'" == "ICPSR STATE CODE" | "`varLab'" == "ICPR STATE CODE") {
			ren `var' stCode
		}
		else if ("`varLab'" == "COUNTY NAME") ren `var' countyName
		else if ("`varLab'" == "ICPSR COUNTY CODE") ren `var' countyCode
		else if ("`varLab'" == "DISTRICT" | substr("`varLab'", 1, 16) == "CONG DIST NUMBER") {
			ren `var' district
		}
		else if (substr("`varLab'", 1, 16) == "STATE OFFICE SUB") ren `var' stOffCode
		else {
			local varLab = stritrim(regexr("`varLab'", " VOTE", ""))
			local varLab = regexr("`varLab'", "[0-9][0-9][0-9] [0-9] G ", "")
			
			if (regexm("`varLab'", "([A-Z]+) 0100")) {
				local newName = "votes" + strlower(regexs(1)) + "Dem"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 0200")) {
				local newName = "votes" + strlower(regexs(1)) + "Rep"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) TOTAL")) {
				local newName = "votes" + strlower(regexs(1)) + "Total"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 1735")) {
				local newName = "votes" + strlower(regexs(1)) + "Lib"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 2582")) {
				local newName = "votes" + strlower(regexs(1)) + "Gre"
				ren `var' `newName'
			}
			else if (regexm("`varLab'", "([A-Z]+) 1299")) {
				local newName = "votes" + strlower(regexs(1)) + "Con"
				ren `var' `newName'
			}
			else drop `var'
		}	
	}
	
	gen year = "`year'"
	cap append using "fedResults.dta"
	save "fedResults.dta", replace
}

foreach off in pres sen cong gov state {
	egen `off'Oth = rowtotal(votes`off'*)
	gen votes`off'Oth = (2 * votes`off'Total) - `off'Oth
	drop `off'Oth
}

reshape long votespres votessen votescong votesgov votesstate, ///
	i(study* stCode county* district year stOffCode) ///
	j(party) string

reshape long votes, j(office) string ///
	i(study* stCode county* district year stOffCode party)

order year, after(district)

save "fedResults.dta", replace
//remaining issue: district numbers are weird. Some county results may also be aggregated district-in-county numbers

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
