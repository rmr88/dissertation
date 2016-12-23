******************************
*  NAES District Level Data  *
******************************

//Robbie Richards, 12/21/16
//This code requires the restricted NAES district data.


cd "C:\Users\Robbie\Documents\dissertation\Data\NAES"


*** 2004 ***

use "F:\naes04cd.dta", clear
merge 1:1 cKEY using "national_cs_mod_04.dta", nogen
keep cUA01 cST cSTNUM cCC01-cCC31

drop if cUA01 == 9999
gen district = cUA01 - (cSTNUM * 100)
ren cST state
ren cSTNUM state_icpsr
ren cCC02 healthGovSpend04
ren cCC03 Chip1
ren cCC04 Chip2
ren cCC05 GovInsWorkers1
ren cCC06 GovInsWorkers2
ren cCC15 healthRxCoverage04
ren cCC17 FavorMMA1
ren cCC18 FavorMMA2
ren cCC21 healthBenefitFromMMA04
ren cCC24 Reimport1
ren cCC25 Reimport2
drop cCC* cUA01

foreach stub in Chip GovInsWorkers FavorMMA Reimport {
	gen health`stub'04 = `stub'1
	replace health`stub' = 1 if `stub'2 == 1 | `stub'2 == 2
	replace health`stub' = 2 if `stub'2 == 3 | `stub'2 == 4
	drop `stub'1 `stub'2
}

foreach var of varlist health* {
	replace `var' = . if `var' > 10
	qui levelsof `var', local(levels)
	foreach n of local levels {
		gen `var'_`n' = `var' == `n'
	}
	gen `var'_miss = missing(`var')
}

collapse (mean) health*04 (sum) health*_*, by(state district state_icpsr)
save "naesDistrictData.dta", replace


*** 2008 ***

use "F:\naes08cd.dta", clear
merge 1:1 rkey using "naes08-phone-nat-rcs-data-full.dta", nogen
keep WFc07 WFc01_c CCa01_c CCa02_c

ren WFc07 district
ren WFc01_c state_icpsr
ren CCa01_c healthGovOrPriv08
ren CCa02_c healthCompOrReg08
drop if district == 99

foreach var of varlist health* {
	replace `var' = . if `var' > 10
	qui levelsof `var', local(levels)
	foreach n of local levels {
		gen `var'_`n' = `var' == `n'
	}
	gen `var'_miss = missing(`var')
}

collapse (mean) health*08 (sum) health*_*, by(district state_icpsr)
merge 1:1 state_icpsr district using "naesDistrictData.dta", nogen

gen distID = state + "-" + string(district)

save "naesDistrictData.dta", replace

