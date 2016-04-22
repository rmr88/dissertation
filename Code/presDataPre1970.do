*** Process uspidential Dlection Data Pre-1970 ***

//Robbie Richards, 3/19/16

local basePath = "C:\Users\Robbie\Documents\dissertation\Data\elections\ICPSRfedResults\ICPSR_00001"
cap erase "`basePath'\uspDataPre1970.dta"

forvalues n = 1/203 { //loop through data folder
	di "`n'"
	local dsn = string(`n')
	while (strlen("`dsn'") < 4) {
		local dsn = "0`dsn'"
	}
	
	run "`basePath'\DS`dsn'\setup`dsn'.do"
	
	ren V1 state_icpsr
	ren V2 county_name
	ren V3 county_icpsr
	
	local parties = "TOTAL"
	foreach var of varlist _all { //loop through vars
		qui sum `var'
		if (r(sum) == 0 & regexm("`var'", "V[0-9]+")) {
			drop `var'
		}
		else { //process valid variables
			local varlab : var label `var'
			if (regexm("`varlab'", "([0-9][0-9][0-9]) ?[0-9]? ?G? PRES (([0-9][0-9][0-9][0-9])|(TOTAL)) VOTE")) {
				local newname = "usp_1`=regexs(1)'_`=regexs(2)'"
				
				if (strpos("`parties'", "`=regexs(2)'") == 0) {
					local parties = "`=regexs(2)' `parties'"
				}
				
				cap ren `var' `newname'
				qui if (_rc) {
					replace `newname' = `var' + `newname'
					ren `newname' `newname'_tot
					drop `var'
					noi: di "`var', `newname' combined"
				}
			}
			else if (regexm("`varlab'", "CONG DIST NUMBER ([0-9][0-9][0-9][0-9])")) {
				local newname = "cd`=regexs(1)'_icpsr"
				cap ren `var' `newname'
				
				if (_rc) {
					ren `var' `newname'_2
				}
			}
			else if (regexm("`var'", "V[0-9]+")) {
				drop `var'
			}
		} //end process valid vars
	} //end loop through vars

	cap collapse (sum) usp* (firstnm) cd*, by(state_icpsr county_*)
	if (_rc) continue
	
	local longVars = "cd@_icpsr "
	foreach party of local parties {
		local longVars = "`longVars' usp_@_`party'"
	}
	qui reshape long `longVars', i(state_icpsr county_*) j(year)
	
	foreach var of varlist usp* {
		ren `var' `=subinstr("`var'", "__", "", .)'
	}
	
	cap append using "`basePath'\uspDataPre1970.dta"
	qui save "`basePath'\uspDataPre1970.dta", replace
} //end loop through data folders

order usp*, alpha
order state_icpsr county_name county_icpsr year cd_icpsr ///
	usp0100 usp0200 uspTOTAL, first

replace usp0328 = usp0328 + usp_1932_0328_tot if ///
	!missing(usp_1932_0328_tot)
replace usp0328 = usp0328 + usp_1968_0328_tot if ///
	!missing(usp_1968_0328_tot)
drop cd1851_icpsr_2 usp_*_tot

egen uspOTHER = rowtotal(usp*)
replace uspOTHER = uspOTHER - usp0100 - usp0200 - uspTOTAL
drop usp0002-usp9999

drop if missing(usp0100) & missing(usp0200) & missing(uspTOTAL)
drop county_name

ren usp0100 sumVotesDEM
ren usp0200 sumVotesREP
ren uspOTHER sumVotesOTH
ren uspTOTAL totalVotes
gen partyVotes = sumVotesDEM + sumVotesREP

save "`basePath'\presDataPre1970.dta", replace

