*********************************
*  Ch. 2 - Public Opinion Data  *
*********************************

//Robbie Richards, 8/17/16

cd "C:\Users\Robbie\Documents\dissertation\Data"


*** CCES ***

*2006
use "CCES\cces_2006_common.dta", clear
keep v1002 v1003 v2130-v2133 v2020

ren v1002 state
ren v1003 district
ren v2130 healthCost06
ren v2131 healthSatis06
ren v2132 healthEmplSpons06
ren v2133 healthPers06
ren v2020 birth_year

foreach var of varlist health* {
	qui levelsof `var', local(levels)
	foreach n of local levels {
		gen `var'_`n' = `var' == `n'
	}
	gen `var'_miss = missing(`var')
}
collapse (mean) health*06 birth (sum) health*_*, by(state district)

save "CCES\pubOpData.dta", replace

*2008
use "CCES\cces_2008_common.dta", clear
keep V206 V250 CC316e CC417 V207

decode V206, gen(state_name)
ren V250 district
destring district, replace
ren CC316e healthChip08
ren CC417 healthMand08
ren V207 birth_year

foreach var of varlist health* {
	qui levelsof `var', local(levels)
	foreach n of local levels {
		gen `var'_`n' = `var' == `n'
	}
	gen `var'_miss = missing(`var')
}
collapse (mean) health*08 birth (sum) health*_*, by(state district)

merge m:1 state_name using "working\states.dta", keep(3) nogen keepusing(state)
replace district = 1 if state == "DC"
merge 1:1 state district using "CCES\pubOpData.dta", nogen

save "CCES\pubOpData.dta", replace

*2010
use "CCES\cces_2010_common_validated.dta", clear
keep V206 V276 CC332B CC332D V207

decode V206, gen(state_name)
ren V276 district
destring district, replace
ren CC332B healthChip10
ren CC332D healthACA10
ren V207 birth_year

foreach var of varlist health* {
	qui levelsof `var', local(levels)
	foreach n of local levels {
		gen `var'_`n' = `var' == `n'
	}
	gen `var'_miss = missing(`var')
}
collapse (mean) health*10 birth (sum) health*_*, by(state district)

merge m:1 state_name using "working\states.dta", keep(3) nogen keepusing(state)
replace district = 1 if state == "DC"
merge 1:1 state district using "CCES\pubOpData.dta", nogen

save "CCES\pubOpData.dta", replace


*** Annenberg NAES ***

//Don't have CD data yet; working on it...


*** Catalist IPs ***

replace district = 1 if district == 0
gen distID = state + "-" + string(district)

merge 1:1 distID using "C:\Users\Robbie\Documents\gunPolicy\Data\IPsmall.dta", nogen
drop state_abrev
ren IP_voter2 IP_voter

save "pubOpDataMerged.dta", replace

