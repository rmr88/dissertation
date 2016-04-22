**********************************
*  Merge NOMINATE, Party Scores  *
**********************************

//Robbie Richards, 2/8/16

global code = "C:\Users\Robbie\Documents\dissertation\Code"
global data = "C:\Users\Robbie\Documents\dissertation\Data"


*** NOMINATE Data ***

run "$code\mergeNomToPtyScore.do"

preserve
	drop if district == 0

	replace mc_name = strtrim(mc_name)
	gen winnerLast = substr(mc_name, 1, strpos(mc_name, " ")-1)
	replace winnerLast = mc_name if missing(winnerLast)
	gen winnerFirst2 = substr(mc_name, strpos(mc_name, " ")+1, .)
	replace winnerFirst2 = "" if winnerFirst2 == winnerLast
	replace winnerFirst2 = strtrim(winnerFirst2)
	replace mc_party = 100 if mc_party == 200 & idno == 95122

	//Hardcodes:
	replace winnerLast = "STARKWEATHER" if winnerLast == "STARKWEATHE" & idno == 8854
	replace winnerLast = "SEYMOUR" if winnerLast == "SEYMOOR" & idno == 8386
	replace winnerLast = "HUMPHREY" if winnerLast == "HUMPHERY" & (idno == 4729 | idno == 4730)
	
	save "$data\working\vvHouse.dta", replace
restore

keep if district == 0

replace mc_name = strtrim(mc_name)
gen winnerLast = substr(mc_name, 1, strpos(mc_name, " ")-1)
replace winnerLast = mc_name if missing(winnerLast)
gen winnerFirst2 = substr(mc_name, strpos(mc_name, " ")+1, .)
replace winnerFirst2 = "" if winnerFirst2 == winnerLast
replace winnerFirst2 = strtrim(winnerFirst2)

//Hardcodes:
replace winnerLast = "FRELINGHUYSEN" if winnerLast == "FRELINGHUYS" ///
	& idno == 3362
replace winnerLast = "GOLDSBOROUGH" if winnerLast == "GOLDSBOROUG" ///
	& idno == 3653
replace winnerLast = "VANNUYS" if winnerFirst == "NUYS"
replace winnerFirst = "" if winnerFirst == "NUYS"
replace winnerLast = "SCHWELLENBACH" if winnerLast == "SCHWELLENBA" ///
	& idno == 8287
replace winnerLast = "HICKENLOOPER" if winnerLast == "HICKENLOOPE" ///
	& idno == 4382
replace winnerLast = subinstr(winnerLast, "'", "", .)

save "$data\working\vvSen.dta", replace


*** Party Score Data ***

use "$data\elections\allElectionData.dta", clear //partyScores.dta
replace year = year - 1 if mod(year, 2) == 1 //& (elec_type == "G" | elec_type == "M")
ren state state2

preserve
	keep if offSmall == 3
	save "$data\working\psHouse.dta", replace
restore

preserve
	drop if offSmall == 4 | offSmall == 3
	save "$data\working\psOthers.dta", replace
restore

keep if offSmall == 4

replace sumVotesREP = -1 if missing(sumVotesREP)
replace sumVotesDEM = -1 if missing(sumVotesDEM)
replace sumVotesOTH = -1 if missing(sumVotesOTH)

gen winnerLast = substr(candNameDEM, 1, strpos(candNameDEM, ",")-1) ///
	if sumVotesDEM > sumVotesREP & sumVotesDEM > sumVotesOTH
replace winnerLast = substr(candNameREP, 1, strpos(candNameREP, ",")-1) ///
	if sumVotesREP > sumVotesDEM & sumVotesREP > sumVotesOTH & missing(winnerLast)
replace winnerLast = substr(candNameOTH, 1, strpos(candNameOTH, ",")-1) ///
	if sumVotesOTH > sumVotesREP & sumVotesOTH > sumVotesDEM & missing(winnerLast)
replace winnerLast = substr(candNameDEM, 1, strpos(candNameDEM, ",")-1) ///
	if candNameDEM == candNameOTH & (sumVotesDEM + sumVotesOTH) > sumVotesREP
replace winnerLast = substr(candNameREP, 1, strpos(candNameREP, ",")-1) ///
	if candNameREP == candNameOTH & (sumVotesREP + sumVotesOTH) > sumVotesDEM

gen winnerFirst = substr(candNameDEM, strpos(candNameDEM, ",")+1, .) ///
	if sumVotesDEM > sumVotesREP & sumVotesDEM > sumVotesOTH
replace winnerFirst = substr(candNameREP, strpos(candNameREP, ",")+1, .) ///
	if sumVotesREP > sumVotesDEM & sumVotesREP > sumVotesOTH & missing(winnerFirst)
replace winnerFirst = substr(candNameOTH, strpos(candNameOTH, ",")+1, .) ///
	if sumVotesOTH > sumVotesREP & sumVotesOTH > sumVotesDEM & missing(winnerFirst)
replace winnerFirst = substr(candNameDEM, strpos(candNameDEM, ",")+1, .) ///
	if candNameDEM == candNameOTH & (sumVotesDEM + sumVotesOTH) > sumVotesREP
replace winnerFirst = substr(candNameREP, strpos(candNameREP, ",")+1, .) ///
	if candNameREP == candNameOTH & (sumVotesREP + sumVotesOTH) > sumVotesDEM

replace winnerLast = winnerFirst if missing(winnerLast) ///
	& !missing(winnerFirst)
replace winnerFirst = "" if winnerLast == winnerFirst
replace winnerFirst = strtrim(winnerFirst)

replace winnerLast = strupper(winnerLast)
replace winnerFirst = strupper(winnerFirst)
replace winnerLast = subinstr(winnerLast, " JR", "", .)
replace winnerLast = subinstr(winnerLast, " III", "", .)
replace winnerLast = subinstr(winnerLast, " IV", "", .)
replace winnerLast = "HARRY REID" if strpos(winnerLast, "REID HARRY") > 0
replace winnerLast = "JOHN H. GLENN" if winnerLast == "JOHN H. GLENN."
replace winnerLast = "PATTY MURRAY" if (winnerLast == "MURRAY-D" ///
	| winnerLast == "MURRAY P") & state2 == "WA" & offSmall == 4
	
//Jrs with commas:
gen winnerLast2 = winnerLast if winnerFirst == "JR." ///
	| winnerFirst == "JR"
replace winnerLast = substr(winnerLast2, strrpos(winnerLast2, " "), .) ///
	if !missing(winnerLast2)
replace winnerFirst = substr(winnerLast2, 1, strrpos(winnerLast2, " ")-1) ///
	+ " " + winnerFirst if !missing(winnerLast2)
drop winnerLast2

//No comma, last name first
gen winnerLast2 = winnerLast if year > 1990 & offSmall == 4 ///
	& state2 == "AK" & (winnerLast == "MURKOWSKI FRANK" ///
	| winnerLast == "STEVENS TED" | winnerLast == "SULLIVAN DAN")
replace winnerFirst = substr(winnerLast2, ///
	strrpos(winnerLast2, " "), .) if !missing(winnerLast2)
replace winnerLast = substr(winnerLast2, 1, ///
	strrpos(winnerLast2, " ")-1) if !missing(winnerLast2)
drop winnerLast2

//No comma, last name last
gen winnerLast2 = winnerLast if year > 1990 & offSmall == 4 ///
	& missing(winnerFirst)
replace winnerFirst = substr(winnerLast2, 1, ///
	strrpos(winnerLast2, " ")-1) if !missing(winnerLast2)
replace winnerLast = substr(winnerLast2, ///
	strrpos(winnerLast2, " "), .) if !missing(winnerLast2)
drop winnerLast2

//Hardcodes:
replace winnerLast = "MCKELLAR" if winnerLast == "MCKELLER" ///
	& state_icpsr == 54 & year == 1916
replace winnerLast = "HICKENLOOPER" if winnerLast == "HICKENLOOFER" ///
	& state_icpsr == 31 & year == 1950
replace winnerLast = "MAGNUSON" if winnerLast == "MAGNVSON" ///
	& state_icpsr == 73 & year == 1968
replace winnerLast = "KEFAUVER" if winnerLast == "KEFUAVER" ///
	& state_icpsr == 54 & year == 1948
replace winnerLast = "ALLOTT" if winnerLast == "AILOTT" ///
	& state_icpsr == 62 & year == 1960
replace winnerLast = "SAXBE" if winnerLast == "SAXE" ///
	& state_icpsr == 24 & year == 1968
replace winnerLast = "HEINZ" if winnerLast == "HEINX" ///
	& state_icpsr == 14 & year == 1976
replace winnerLast = "BURDICK" if winnerLast == "BRUDICK" ///
	& state_icpsr == 36 & year == 1976
replace winnerLast = "PROXMIRE" if winnerLast == "PROXIMIRE" ///
	& state_icpsr == 25 & year == 1976
replace winnerLast = "STAFFORD" if winnerLast == "STATFORD" ///
	& state_icpsr == 6 & year == 1982
replace winnerLast = "MITCHELL" if winnerLast == "MITCHEL" ///
	& state_icpsr == 2 & year == 1982
replace winnerLast = "DECONCINI" if winnerLast == "DECONCIN" ///
	& state_icpsr == 61 & year == 1982
replace winnerLast = "DURENBERGER" if (winnerLast == "DURENBER" | winnerLast == "DUREBURGER") ///
	& state_icpsr == 33 & (year == 1982 | year == 1988)
replace winnerLast = "MCCONNELL" if winnerLast == "MCCONNEL" ///
	& state_icpsr == 51 & year == 1984
replace winnerLast = "JEFFORDS" if winnerLast == "JEFORDS" ///
	& state_icpsr == 6 & year == 1988
replace winnerLast = subinstr(winnerLast, "'", "", .)

replace winnerLast = strtrim(winnerLast)

joinby state_icpsr year winnerLast using "$data\working\vvSen.dta", ///
	unmatched(both) _merge(join_result)
//duplicates tag state_icpsr year winnerLast, gen(dup)
//drop if elec_type == "S" & dup > 0
//drop dup

//Hardcodes:
drop if idno == 14516 & winnerFirst2 == "M"
drop if idno == 10802 & winnerFirst2 == ""
drop if idno == 3559 & nchoices == 44 //this one is son who filled by appointment the office of his father of the same name, who died in office
drop if (idno == 94240 | idno == 14240) & year == 2000 //Jim Jeffords (VT) the year he switched form REP to IND
drop if (idno == 94910 | idno == 14910) & year == 2008 //Arlen Specter (PA) when he switched parties
drop if idno == 49905 & year == 1998 //Lincoln Chaffee's (RI) short term after father's death
drop if (idno == 15407 | idno == 95407) & year == 1994 //Ben Nighthorse Campbell (CO) switched parties
drop if idno == 14517 & year == 1976 //James Allen died; this is the short appointed term of his widow, Maryon Allen
drop if idno == 5766 & year == 1934 //Rose Long (LA) was appointed to fill the remainder of her husband's term
replace state_n = "INDIANA" if state_icpsr == 22 & missing(state_n)
replace state_n = "VIRGINI" if state_icpsr == 40 & missing(state_n)
replace state_n = "ILLINOI" if state_icpsr == 21 & missing(state_n)
replace state_n = "PENNSYL" if state_icpsr == 14 & missing(state_n)
replace state_n = "NEW JER" if state_icpsr == 12 & missing(state_n)
replace state_n = "TENNESS" if state_icpsr == 54 & missing(state_n)
replace state_n = "N DAKOT" if state_icpsr == 36 & missing(state_n)
replace state_n = "TEXAS" if state_icpsr == 49 & missing(state_n)
replace state_n = "WYOMING" if state_icpsr == 68 & missing(state_n)

replace sumVotesREP = . if sumVotesREP == -1
replace sumVotesDEM = . if sumVotesDEM == -1
replace sumVotesOTH = . if sumVotesOTH == -1

duplicates tag state_n year idno, gen(dup)
drop if dup > 0
drop dup

merge 1:1 state_n year idno using "$data\working\vvSen.dta", update keep(3 4) nogen

/*
gen class = office - 3 if offSmall == 4
bys idno: egen minYear = min(year)
replace class = office - 3 if year == minYear & !missing(class)
bys idno: egen class2 = mean(class)
gen class3 = office - 3
replace office = class2 + 3 if class2 != class3
drop class2 class3 minYear
*/

replace office = 4 if idno == 14914 & cong < 107
replace office = 5 if idno == 14914 & cong > 107

save "$data\elections\scoresMerged.dta", replace

keep if !missing(office)
keep state_icpsr year idno office

ren year elec_year
expand 3
bys state_icpsr office idno elec_year: gen n = _n
gen year = elec_year + (2*(n-1))
drop n

duplicates tag state_icpsr year office, gen(d)
drop if d
drop d
merge m:1 state_icpsr idno year using "$data\elections\scoresMerged.dta", nogen

duplicates tag state_icpsr year office winnerLast elec_year, gen(d)
drop if d
drop d

save "$data\elections\scoresMerged.dta", replace


*** Back to the House ***

use "$data\working\psHouse.dta", clear

replace district = 99 if missing(district)
replace sumVotesREP = -1 if missing(sumVotesREP)
replace sumVotesDEM = -1 if missing(sumVotesDEM)
replace sumVotesOTH = -1 if missing(sumVotesOTH)

gen winnerLast = substr(candNameDEM, 1, strpos(candNameDEM, ",")-1) ///
	if sumVotesDEM > sumVotesREP & sumVotesDEM > sumVotesOTH
replace winnerLast = substr(candNameREP, 1, strpos(candNameREP, ",")-1) ///
	if sumVotesREP > sumVotesDEM & sumVotesREP > sumVotesOTH & missing(winnerLast)
replace winnerLast = substr(candNameOTH, 1, strpos(candNameOTH, ",")-1) ///
	if sumVotesOTH > sumVotesREP & sumVotesOTH > sumVotesDEM & missing(winnerLast)

gen winnerFirst = substr(candNameDEM, strpos(candNameDEM, ",")+1, .) ///
	if sumVotesDEM > sumVotesREP & sumVotesDEM > sumVotesOTH
replace winnerFirst = substr(candNameREP, strpos(candNameREP, ",")+1, .) ///
	if sumVotesREP > sumVotesDEM & sumVotesREP > sumVotesOTH & missing(winnerFirst)
replace winnerFirst = substr(candNameOTH, strpos(candNameOTH, ",")+1, .) ///
	if sumVotesOTH > sumVotesREP & sumVotesOTH > sumVotesDEM & missing(winnerFirst)

replace winnerLast = winnerFirst if missing(winnerLast) ///
	& !missing(winnerFirst)
replace winnerFirst = "" if winnerLast == winnerFirst
replace winnerFirst = strtrim(winnerFirst)

joinby state_icpsr year district using "$data\working\vvHouse.dta", ///
	unmatched(both) _merge(join_result)
drop if join_result == 2 & year < 1868
replace office = 3 if missing(office)

//Hardcodes:
drop if idno == 4729 & winnerFirst == "JAMES M"
drop if idno == 4730 & winnerFirst == "JAMES"
drop if idno == 7814 & winnerFirst == "JOHN"
drop if idno == 7815 & winnerFirst == "JAMES B"
drop if idno == 10591 & winnerFirst == "WILLIAM J (JR)"
drop if idno == 1894 & winnerFirst == "C.R."
drop if idno == 4979 & winnerFirst == "LUTHER A"
drop if idno == 4978 & winnerFirst == "LYNDON B"
drop if idno == 5169 & winnerFirst == "JOHN W"
drop if idno == 2178 & winnerFirst == "CHARLES F"
drop if idno == 5184 & winnerFirst == "MARTIN J"
drop if idno == 5183 & winnerFirst == "MICHAEL J"
drop if idno == 2477 & winnerFirst == "JAMES J"
drop if idno == 2476 & winnerFirst == "JOHN J"
drop if state_icpsr == 14 & (year == 1814 | year == 1816) & district == 5 //can't determine which is correct person/ idno for the "William Maclay" who represented PA-5 in 1814-1817
drop if idno == 7815 & winnerFirst == "JAMES B"
drop if idno == 7814 & winnerFirst == "JOHN"
drop if idno == 13043 & winnerFirst == "J WILLIAM"
drop if idno == 10773 & winnerFirst == "JAMES V"
drop if idno == 14878 & winnerFirst == "JOHN M."
drop if idno == 10702 & winnerFirst == "GEORGE"
drop if idno == 195 & winnerFirst == "GLENN"
drop if idno == 10512 & winnerFirst == "JAMES C"
drop if idno == 2389 & winnerFirst == "JOHN W"

duplicates tag state_icpsr office district year, gen(d)
drop if d
drop d
	
duplicates tag state_icpsr year winnerLast district, gen(dup)
drop if dup >= 1 & substr(winnerFirst, 1, 1) != substr(winnerFirst2, 1, 1)
drop dup
gsort state_icpsr year winnerLast winnerFirst district -month
duplicates drop state_icpsr year winnerLast winnerFirst district dwnom1, force

gen test = substr(winnerFirst, 1, strlen(winnerFirst2)) != winnerFirst2 ///
	if !strpos(winnerFirst2, ".")
drop if test == 1
drop test

replace sumVotesREP = . if sumVotesREP == -1
replace sumVotesDEM = . if sumVotesDEM == -1
replace sumVotesOTH = . if sumVotesOTH == -1


*** Recombine Other Pieces ***

append using "$data\elections\scoresMerged.dta"
append using "$data\working\psOthers.dta"
replace elec_year = year if missing(elec_year)
sort state_icpsr year office district

/*
drop if office == 1 & elec_type == "S"
expand 2 if office == 1, gen(n)
replace elec_year = elec_year + (2 * n) if office == 1
gen dsp = percDem if office == 1
bys state_icpsr elec_year: egen demPresShare = mean(dsp)

drop if office == 1
drop n dsp
*/

merge m:1 state_icpsr year using "$data\elections\ranney_hvd.dta", ///
	nogen keep(1 3) keepusing(ranney_*yrs folded_ranney_*yrs hvd_*yr)
drop folded_ranney_alt*

save "$data\elections\scoresMerged.dta", replace


*** Analysis Version ***

keep state_icpsr year month office district cands partyCands distPost ///
	distType numWinners sumVotesDEM sumVotesREP sumVotesOTH ///
	oneMajorCand uncontested demScore* offSmall cong idno mc_party ///
	dwnom1 elec_year usp* partyVotes totalVotes ranney_*yrs ///
	folded_ranney_*yrs hvd_*yr
save "C:\Users\Robbie\Documents\dissertation\Analysis\scoresMerged.dta", replace

