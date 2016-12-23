*********************************
*  Ch. 2 - ACS Data Processing  *
*********************************

//Robbie Richards, 10/4/16
//data source: http://factfinder.census.gov/faces/nav/jsf/pages/searchresults.xhtml?refresh=t

*** Setup ***

cd "C:\Users\Robbie\Documents\dissertation\Data"

cap erase "ACS\acsData.dta"
local fileStubs = "05_EST 06_EST 08_3YR 10_3YR"


*** Individual File Processing ***

qui foreach stub of local fileStubs {
	noi: di "`stub'"
	
*Read Data
	import delimited using "ACS\ACS_`stub'_S0601.csv", ///
		clear delim(",") varnames(1)
	keep geo* hc01_est_*

*Variable Labels
	foreach var of varlist _all {
		local label = `var'[1]
		label variable `var' `"`label'"'
	}
	drop in 1

*Destring
	foreach var of varlist _all {
		destring `var', replace
	}
	
*Geographic identifiers
	local refIndex = strlen("Congressional District ")
	gen district = substr(geodisplaylabel, `refIndex', ///
		strpos(geodisplaylabel, " (")-`refIndex')
	destring district, replace
	replace district = 1 if missing(district)
	
	gen state_name = strtrim(substr(geodisplaylabel, ///
		strpos(geodisplaylabel, ", ")+1, .))
	
	gen cong = substr(geodisplaylabel, ///
		strpos(geodisplaylabel, "(1")+1, 3)
	destring cong, replace
	
	merge m:1 state_name using "working\states.dta", ///
		keepusing(state) keep(3) nogen
	order state state_name district cong geo*, first

*File-specific instructions
	if ("`stub'" == "08_3YR") {
		replace cong = cong + 1
		
		ren hc01_est_vc01 pop
		ren hc01_est_vc03 popUnder5
		ren hc01_est_vc04 pop5to17
		ren hc01_est_vc05 pop18to24
		ren hc01_est_vc06 pop25to44
		ren hc01_est_vc07 pop45to54
		ren hc01_est_vc08 pop55to64
		ren hc01_est_vc09 pop65to74
		ren hc01_est_vc10 popOver75
		ren hc01_est_vc11 medianAge
		ren hc01_est_vc13 male
		ren hc01_est_vc14 female
		ren hc01_est_vc16 raceOne
		ren hc01_est_vc17 raceWhite
		ren hc01_est_vc18 raceBlack
		ren hc01_est_vc19 raceNative
		ren hc01_est_vc20 raceAsian
		ren hc01_est_vc21 racePoly
		ren hc01_est_vc22 raceOther
		ren hc01_est_vc23 raceTwo
		ren hc01_est_vc24 raceHisp
		ren hc01_est_vc25 raceWhiteOnly
		ren hc01_est_vc27 langTotal
		ren hc01_est_vc28 langOther
		ren hc01_est_vc29 langEnglish
		ren hc01_est_vc30 langEngNotFluent
		ren hc01_est_vc32 marStatTotal
		ren hc01_est_vc33 marStatSingle
		ren hc01_est_vc34 marStatMarried
		ren hc01_est_vc35 marStatDivSep
		ren hc01_est_vc36 marStatWidowed
		ren hc01_est_vc38 educTotal
		ren hc01_est_vc39 educNoHS
		ren hc01_est_vc40 educHS
		ren hc01_est_vc41 educSomeColl
		ren hc01_est_vc42 educBachelor
		ren hc01_est_vc43 educGrad
		ren hc01_est_vc45 incomeTotal
		ren hc01_est_vc46 incomeBelow10k
		ren hc01_est_vc47 income10kto15k
		ren hc01_est_vc48 income15kto25k
		ren hc01_est_vc49 income25kto35k
		ren hc01_est_vc50 income35kto50k
		ren hc01_est_vc51 income50kto65k
		ren hc01_est_vc52 income65kto75k
		ren hc01_est_vc53 incomeOver75k
		ren hc01_est_vc54 medianIncome
		ren hc01_est_vc56 povertyTotal
		ren hc01_est_vc57 povertyBelow100
		ren hc01_est_vc58 poverty100to149
		ren hc01_est_vc59 povertyOver150
		ren hc01_est_vc61 percImputedCitizenship
		ren hc01_est_vc62 percImputedPlaceOfBirth
	}
	else if ("`stub'" == "06_EST") {
		replace cong = cong + 1
		
		ren hc01_est_vc01 pop
		ren hc01_est_vc03 popUnder5
		ren hc01_est_vc04 pop5to17
		ren hc01_est_vc05 pop18to24
		ren hc01_est_vc06 pop25to44
		ren hc01_est_vc07 pop45to54
		ren hc01_est_vc08 pop55to64
		ren hc01_est_vc09 pop65to74
		ren hc01_est_vc10 popOver75
		ren hc01_est_vc11 medianAge
		ren hc01_est_vc13 male
		ren hc01_est_vc14 female
		ren hc01_est_vc16 raceOne
		ren hc01_est_vc17 raceWhite
		ren hc01_est_vc18 raceBlack
		ren hc01_est_vc19 raceNative
		ren hc01_est_vc20 raceAsian
		ren hc01_est_vc21 racePoly
		ren hc01_est_vc22 raceOther
		ren hc01_est_vc23 raceTwo
		ren hc01_est_vc24 raceHisp
		ren hc01_est_vc25 raceWhiteOnly
		ren hc01_est_vc27 langTotal
		ren hc01_est_vc28 langOther
		ren hc01_est_vc29 langEnglish
		ren hc01_est_vc30 langEngNotFluent
		ren hc01_est_vc32 marStatTotal
		ren hc01_est_vc33 marStatSingle
		ren hc01_est_vc34 marStatMarried
		ren hc01_est_vc35 marStatDivSep
		ren hc01_est_vc36 marStatWidowed
		ren hc01_est_vc38 educTotal
		ren hc01_est_vc39 educNoHS
		ren hc01_est_vc40 educHS
		ren hc01_est_vc41 educSomeColl
		ren hc01_est_vc42 educBachelor
		ren hc01_est_vc43 educGrad
		ren hc01_est_vc45 incomeTotal
		ren hc01_est_vc46 incomeBelow10k
		ren hc01_est_vc47 income10kto15k
		ren hc01_est_vc48 income15kto25k
		ren hc01_est_vc49 income25kto35k
		ren hc01_est_vc50 income35kto50k
		ren hc01_est_vc51 income50kto65k
		ren hc01_est_vc52 income65kto75k
		ren hc01_est_vc53 incomeOver75k
		ren hc01_est_vc54 medianIncome
		ren hc01_est_vc56 povertyTotal
		ren hc01_est_vc57 povertyBelow100
		ren hc01_est_vc58 poverty100to149
		ren hc01_est_vc59 povertyOver150
		ren hc01_est_vc61 percImputedCitizenship
		ren hc01_est_vc62 percImputedPlaceOfBirth
	}
	else if ("`stub'" == "05_EST") {
		expand 2
		bys cong state district: gen n = _n
		replace cong = cong - n + 1
		drop n
		
		ren hc01_est_vc01 pop
		ren hc01_est_vc03 popUnder5
		ren hc01_est_vc04 pop5to17
		ren hc01_est_vc05 pop18to24
		ren hc01_est_vc06 pop25to44
		ren hc01_est_vc07 pop45to54
		ren hc01_est_vc08 pop55to64
		ren hc01_est_vc09 pop65to74
		ren hc01_est_vc10 pop75to84
		ren hc01_est_vc11 pop85plus
		ren hc01_est_vc12 medianAge
		ren hc01_est_vc14 male
		ren hc01_est_vc15 female
		ren hc01_est_vc17 raceOne
		ren hc01_est_vc18 raceWhite
		ren hc01_est_vc19 raceBlack
		ren hc01_est_vc20 raceNative
		ren hc01_est_vc21 raceAsian
		ren hc01_est_vc22 racePoly
		ren hc01_est_vc23 raceOther
		ren hc01_est_vc24 raceTwo
		ren hc01_est_vc25 raceHisp
		ren hc01_est_vc26 raceWhiteOnly
		ren hc01_est_vc28 langTotal
		ren hc01_est_vc29 langOther
		ren hc01_est_vc30 langEnglish
		ren hc01_est_vc31 langEngNotFluent
		ren hc01_est_vc33 marStatTotal
		ren hc01_est_vc34 marStatSingle
		ren hc01_est_vc35 marStatMarried
		ren hc01_est_vc36 marStatDivSep
		ren hc01_est_vc37 marStatWidowed
		ren hc01_est_vc39 educTotal
		ren hc01_est_vc40 educNoHS
		ren hc01_est_vc41 educHS
		ren hc01_est_vc42 educSomeColl
		ren hc01_est_vc43 educBachelor
		ren hc01_est_vc44 educGrad
		ren hc01_est_vc46 incomeTotal
		ren hc01_est_vc47 incomeBelow10k
		ren hc01_est_vc48 income10kto15k
		ren hc01_est_vc49 income15kto25k
		ren hc01_est_vc50 income25kto35k
		ren hc01_est_vc51 income35kto50k
		ren hc01_est_vc52 income50kto65k
		ren hc01_est_vc53 income65kto75k
		ren hc01_est_vc54 incomeOver75k
		ren hc01_est_vc55 medianIncome
		ren hc01_est_vc57 povertyTotal
		ren hc01_est_vc58 povertyBelow100
		ren hc01_est_vc59 poverty100to149
		ren hc01_est_vc60 povertyOver150
		ren hc01_est_vc62 housingTotal
		ren hc01_est_vc63 housingOwn
		ren hc01_est_vc64 housingRent
		ren hc01_est_vc66 hhTotal
		ren hc01_est_vc67 hhMarried
		ren hc01_est_vc68 hhOther
		ren hc01_est_vc70 percImputedCitizenship
		ren hc01_est_vc71 percImputedPlaceOfBirth
	}
	else if ("`stub'" == "10_3YR") {
		replace cong = cong + 1
		
		ren hc01_est_vc01 pop
		ren hc01_est_vc03 popUnder5
		ren hc01_est_vc04 pop5to17
		ren hc01_est_vc05 pop18to24
		ren hc01_est_vc06 pop25to44
		ren hc01_est_vc07 pop45to54
		ren hc01_est_vc08 pop55to64
		ren hc01_est_vc09 pop65to74
		ren hc01_est_vc10 popOver75
		ren hc01_est_vc12 medianAge
		ren hc01_est_vc15 male
		ren hc01_est_vc16 female
		ren hc01_est_vc19 raceOne
		ren hc01_est_vc20 raceWhite
		ren hc01_est_vc21 raceBlack
		ren hc01_est_vc22 raceNative
		ren hc01_est_vc23 raceAsian
		ren hc01_est_vc24 racePoly
		ren hc01_est_vc25 raceOther
		ren hc01_est_vc26 raceTwo
		ren hc01_est_vc28 raceHisp
		ren hc01_est_vc29 raceWhiteOnly
		ren hc01_est_vc33 langTotal
		ren hc01_est_vc34 langOther
		ren hc01_est_vc35 langEnglish
		ren hc01_est_vc36 langEngNotFluent
		ren hc01_est_vc40 marStatTotal
		ren hc01_est_vc41 marStatSingle
		ren hc01_est_vc42 marStatMarried
		ren hc01_est_vc43 marStatDivSep
		ren hc01_est_vc44 marStatWidowed
		ren hc01_est_vc48 educTotal
		ren hc01_est_vc49 educNoHS
		ren hc01_est_vc50 educHS
		ren hc01_est_vc51 educSomeColl
		ren hc01_est_vc52 educBachelor
		ren hc01_est_vc53 educGrad
		ren hc01_est_vc57 incomeTotal
		ren hc01_est_vc58 incomeBelow10k
		ren hc01_est_vc59 income10kto15k
		ren hc01_est_vc60 income15kto25k
		ren hc01_est_vc61 income25kto35k
		ren hc01_est_vc62 income35kto50k
		ren hc01_est_vc63 income50kto65k
		ren hc01_est_vc64 income65kto75k
		ren hc01_est_vc65 incomeOver75k
		ren hc01_est_vc67 medianIncome
		ren hc01_est_vc71 povertyTotal
		ren hc01_est_vc72 povertyBelow100
		ren hc01_est_vc73 poverty100to149
		ren hc01_est_vc74 povertyOver150
		ren hc01_est_vc77 percImputedCitizenship
		ren hc01_est_vc78 percImputedPlaceOfBirth
	}
	
*Append and Save
	cap append using "ACS\acsData.dta"
	di _rc
	save "ACS\acsData.dta", replace
}


*** Further Processing ***

replace popOver75 = pop75to84 + pop85plus if missing(popOver75)
save "ACS\acsData.dta", replace

