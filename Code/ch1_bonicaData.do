

cd  "C:\Users\Robbie\Documents\dissertation\Data\cfScores"
import delimited using "candidate_cfscores_st_fed_1979_2012.csv", ///
	delim(",") clear varnames(1)

*Keep House winner rows
keep if winner == "W" & seat == "federal:house"
drop if state == "DC" | state == "GU" | state == "MP" | ///
	state == "PR" | state == "VI" | state == "AS"
drop if icpsr2 == "20147" & district == "MO01" & cycle == 1992 //William Clay Sr, replaced by his son Lacy Clay in 1992.
drop if icpsr2 == "29148" & district == "VA07" & cycle == 1992 //George Allen, retired to run for governor in 1992.

*Keep relevant variables, conform to other data
keep cycle state district cfscore cfscoresdyn
ren cycle year
replace district = substr(district, 3, 2)
destring district, replace

*Merge state data
merge m:1 state using "..\working\states.dta", nogen keep(1 3) ///
	keepusing(state_icpsr)

*Clean up, save
gen office = 3

duplicates tag state district year, gen(d)
drop if d
drop d

save "cfScores.dta", replace
