*** Comparing NOMINATE and NPAT in UT ***

*Setup
cd "C:\Users\Robbie\Documents\dissertation\Data\StateLeg"
use "npatScores.dta" , clear
keep if st == "UT"

*Name variables
gen last_name = substr(name, 1, strpos(name, ", ")-1)
replace last_name = name if last_name == "" & strpos(name, ",") == 0
gen first_name2 = substr(name, strpos(name, ", ")+2, .) if strpos(name, ", ") != 0

*Join Data
joinby last_name using "UTlegs.dta"

*Perform extra matching
bys last_name: gen n = _N

gen match = 1 if n == 1
replace match = 1 if first_name == first_name2
replace match = 1 if substr(first_name, 1, strlen(first_name2)) == first_name2
replace match = 1 if substr(first_name2, 1, strlen(first_name)) == first_name
keep if match == 1

drop n
bys last_name first_name2: gen n = _N
duplicates drop name last_name first_name first_name2 legislator, force

*Hard-coded matches
drop if legislator == "Brown, Derek E." & name == "Brown"
drop if name == "Peterson" & first_name2 == ""

*Analyze correlations between the measures
replace ideologyscore = ideologyscore / 100

twoway (scatter np_score ideologyscore if party == "R", mcolor(red*0.7)) ///
	(scatter np_score ideologyscore if party == "D", mcolor(blue*0.7)) ///
	(lfit np_score ideologyscore if party == "R", lcolor(red)) ///
	(lfit np_score ideologyscore if party == "D", lcolor(blue)) ///
	(lfit np_score ideologyscore, lcolor(black)), leg(off)
reg np_score c.ideologyscore##i.republican //the difference by party is interesting, though maybe inconsequential

