*** County-level Election Results, 1824-1968 ***

//Robbie Richards, 1/14/16
global path = "C:\Users\Robbie\Documents\dissertation\Data\elections\ICPSRfedResults\ICPSR_00001"

qui cd $path
cap erase "fedResults2.dta"
forval fileNum = 1/203 {
	if (`fileNum' < 10) local stub = "000`fileNum'"
	else if (`fileNum' < 100) local stub = "00`fileNum'"
	else local stub = "0`fileNum'"
	di "DS`stub'"
	
	run "DS`stub'\setup`stub'.do"
	qui cd $path
	
	local year = "1"
	foreach var of varlist _all {
		local varLab : variable label `var'
		
		//Get election year from first var label that has it
		if (substr("`varLab'", 1, 1) == "9" | substr("`varLab'", 1, 1) == "8") {
			local year = "1" + substr("`varLab'", 1, 3)
		}
		
		if ("`varLab'" == "ICPSR STATE CODE" | "`varLab'" == "ICPR STATE CODE") {
			ren `var' stCode
		}
		else if ("`varLab'" == "COUNTY NAME") {
			cap ren `var' countyName
			if (_rc) drop `var'
		}
		else if ("`varLab'" == "IDENTIFICATION NUMBER") ren `var' idNum
		else if (regexm("`varLab'", "CONG DIST NUMBER (1[8-9][0-9][0-9])")) {
			local year = regexs(1)
			local newName = "district`year'"
			cap ren `var' `newName'
			if (_rc) drop `var'
		}
		else {
			local varLab = stritrim(regexr("`varLab'", " VOTE$", ""))
			local varLab = regexr("`varLab'", "^[0-9][0-9][0-9] ?[0-9]? ?G? ", "")
			
			if (regexm("`varLab'", "^([0-9][0-9][0-9] )?([A-Z]+) 0100$")) {
				local newName = "votes" + strlower(regexs(2)) + "Dem`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 0200$")) {
				local newName = "votes" + strlower(regexs(1)) + "Rep`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) TOTAL$")) {
				local newName = "votes" + strlower(regexs(1)) + "Total`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 1735$")) {
				local newName = "votes" + strlower(regexs(1)) + "Lib`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 2582$")) {
				local newName = "votes" + strlower(regexs(1)) + "Gre`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 1299$")) {
				local newName = "votes" + strlower(regexs(1)) + "Con`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 0029$")) {
				local newName = "votes" + strlower(regexs(1)) + "Whig`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 0025$")) {
				local newName = "votes" + strlower(regexs(1)) + "NatRep`year'"
				cap ren `var' `newName'
			}
			else if (regexm("`varLab'", "^([A-Z]+) 0300$")) {
				local newName = "votes" + strlower(regexs(1)) + "FreeSoil`year'"
				cap ren `var' `newName'
			}
			else cap drop `var'

			if (_rc) {
				local newName = "alt_`newName'"
				qui sum `var'
				if (r(mean) == 0) qui drop `var'
				else {
					cap ren `var' `newName'
					if (_rc) drop `var'
				}
			}
		}	
	}
	
	gen dataset = "DS`stub'"
	cap append using "fedResults2.dta"
	qui save "fedResults2.dta", replace
}

drop countyName
drop if missing(idNum)
duplicates tag idNum stCode dataset, gen(dup)
drop if dup
drop dup

local stubList = ""
local offList = "pres sen cong gov atgn"
foreach off of local offList {
	local `off'Ptys = ""
	foreach var of varlist *votes`off'* {
		local num = regexm("`var'", "^votes`off'([a-zA-Z]+)[0-9][0-9][0-9][0-9]$")
		local pty = regexs(1)
		capture confirm variable alt_`var'

		if (strpos("``off'Ptys'", " `pty'") == 0) {
			local `off'Ptys = "``off'Ptys' `pty'"
		}
		if (!_rc & strpos("``off'Ptys'", "alt_`pty'") == 0) {
			local `off'Ptys = "``off'Ptys' alt_`pty'"
		}
	}
	local `off'Ptys = strtrim("``off'Ptys'")
	
	foreach pty of local `off'Ptys {
		di "`pty'"
		if (substr("`pty'", 1, 4) == "alt_") {
			local pty = subinstr("`pty'", "alt_", "", .)
			local stubList = "`stubList' alt_votes`off'`pty'"
		}
		else local stubList = "`stubList' votes`off'`pty'"
	}
}
local stubList = strtrim("`stubList'")
di "`stubList'"

reshape long district `stubList', i(stCode idNum dataset) j(year)

egen nonmiss = rownonmiss(district votes* alt_*)
drop if nonmiss == 0
drop nonmiss

local offList = "pres sen cong gov atgn"
foreach off of local offList {
	gen margin`off' = (votes`off'Dem - votes`off'Rep) / votes`off'Total
//	replace margin`off' = 100 if missing(votes`off'Rep) & ///
//		missing(margin`off') & !missing(votes`off'Dem)
//	replace margin`off' = -100 if !missing(votes`off'Rep) & ///
//		missing(margin`off') & missing(votes`off'Dem)
}

save "fedResults2.dta", replace

preserve
collapse (mean) marginspres, by(year)
twoway(line marginspres year) if year > 1854, yline(0.5)
restore

