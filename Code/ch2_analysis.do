********************
*  Ch. 2 Analysis  *
********************

//Robbie Richards, 10/4/16


*** Setup ***

use "C:\Users\Robbie\Documents\dissertation\Data\ch2_analysisData.dta", clear
cd "C:\Users\Robbie\Documents\dissertation\Analysis"

replace dem = . if party == 328
replace rep = . if party == 328


*** Models by Bill Group ***

levelsof vote_group, local(grp)
foreach g of local grp {
	//local g = "HEALTH Act"
	di "`g'"
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if vote_group == "`g'"
	local title = subinstr(word("`g'", 1), "/", "", .)
	estimates store `title', title("`g'")
	
	if ("`g'" == "ACA and Related" | "`g'" == "MMA 2003") ///
		local aarp = "amtAARP"
	else local aarp = ""
	
	if ("`g'" == "CHIPRA 2007" | "`g'" == "SGR/ Doc Fix Bills") ///
		local ptyLine = "partyLineVote"
	else local ptyLine = ""
	
	if ("`g'" != "MMA 2003") {
		qui tab rollnum if vote_group == "`g'", gen(_rn)
		drop _rn1
	}
	if ("`g'" == "SGR/ Doc Fix Bills") drop _rn3
	if ("`g'" == "CHIPRA 2007") drop _rn4
	
	capture confirm variable _rn2
	if (_rc == 0) {
		logit agree_dem amt amtH01 amtBCBS `aarp' healthOpinion IP_voter ///
			percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
			`ptyLine' rep birthYear _rn* if vote_group == "`g'"
	}
	else {
		logit agree_dem amt amtH01 amtBCBS `aarp' healthOpinion IP_voter ///
			percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
			`ptyLine' rep birthYear if vote_group == "`g'"
	}

	qui sum agree_dem if vote_group == "`g'"
	local mean = r(mean)
	
	foreach var of varlist amt amtH01 amtBCBS `aarp' healthOpinion ///
			IP_voter percSenior unins_rate phys_perc {
		cap prgen `var', gen(_pr) ci
		if (_rc == 0) {
			qui replace _prp1lb = 0 if _prp1lb < 0
			qui replace _prp1ub = 1 if _prp1ub > 1 & !missing(_prp1ub)
			line _prp1 _prp1lb _prp1ub _prx, lcolor(black gs8 gs8) ///
				lpattern(solid dash dash) lwidth(medium medthin medthin) ///
				graphregion(color(white)) leg(off) yline(`mean', lcolor(blue)) ///
				ytitle("Probability of Voting w/ Democrats") xscale(titlegap(2)) ///
				ylab(0(0.5)1, glcolor(white)) name(`title'_`var', replace)
			qui graph export "Figs\ch2\billGroups\\`title'_`var'.png", replace height(800)
		}
		cap drop _pr*
	}
	cap drop _rn*
}

*For table A2-2
esttab * using "Tables\ch2_modelsByGroup.csv", replace csv ///
	b(3) se(3) mtitles legend star(* 0.05 ** 0.01) ///
	pr2(%4.3f) varwidth(20) modelwidth(6) label nogaps ///
	drop(*.rollnum 100.party 328.party)
estimates clear

/*
//Figures for paper; run with named graphs above in memory.
graph combine ACA_amtBCBS ACA_unins_rate, col(2) graphregion(color(white))
graph export "Figs\fig2-1.png", replace height(800)
graph combine HEALTH_phys_perc HEALTH_amtH01, col(2) graphregion(color(white))
graph export "Figs\fig2-2.png", replace height(800)
graph combine MMA_phys_perc MMA_amtBCBS, col(2) graphregion(color(white))
graph export "Figs\fig2-3.png", replace height(800)
*/


*** Models by Minor Topic Code ***

levelsof minor, local(minor)
cap drop _rn*
foreach m of local minor {
	di "minor = `m'"
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		rep partyLineVote birthYear i.rollnum if minor == `m'
	local lab : label MINOR `m'
	estimates store _`m', title("`lab'")
	
	/*
	qui tab rollnum if minor == `m', gen(_rn)
	drop _rn1	

	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		rep partyLineVote birthYear _rn* if minor == `m'
	
	matrix define tab = r(table)
	local names : colnames tab
	local cols = colsof(tab)
	local todrop = ""
	
	forvalues col = 17/`cols' {
		local name = word("`names'", `col')
		if (tab[2,`col'] == .) {
			local todrop = "`todrop' " + subinstr("`name'", "o.", "", .)
		}
	}
	
	local todrop = strtrim("`todrop'")
	cap drop `todrop'
	
	if (`m' == 300 | `m' == 333 | `m' == 341 | `m' == 342) {
		local ptyLine = ""
	}
	else local ptyLine = "partyLineVote"
	
	if (`m' == 300 | `m' == 341 | `m' == 342) local aarp = ""
	else local aarp = "amtAARP"
	
	if (`m' == 324) local rn = ""
	else local rn = "_rn*"
	
	qui logit agree_dem amt amtH01 amtBCBS `aarp' healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		rep `ptyLine' birthYear `rn' if minor == `m'

	qui sum agree_dem if minor == `m'
	local mean = r(mean)
	
	foreach var of varlist amt amtH01 amtBCBS amtAARP healthOpinion ///
			IP_voter percSenior unins_rate phys_perc {
		cap prgen `var', gen(_pr) ci
		if (_rc == 0) {
			qui replace _prp1lb = 0 if _prp1lb < 0
			qui replace _prp1ub = 1 if _prp1ub > 1 & !missing(_prp1ub)
			line _prp1 _prp1lb _prp1ub _prx, lcolor(black gs8 gs8) ///
				lpattern(solid dash dash) lwidth(medium medthin medthin) ///
				graphregion(color(white)) leg(off) yline(`mean', lcolor(blue)) ///
				ytitle("Probability of Voting w/ Democrats") xscale(titlegap(2)) ///
				ylab(0(0.5)1, glcolor(white))
			qui graph export "Figs\ch2\topics\\m`m'_`var'.png", replace height(800)
		}
		cap drop _pr* //TODO: syntax error 503 here from omitted vars in model
	}
	cap drop _rn*
	*/
}

*For tables 2-2 and A2-1
esttab _* using "Tables\ch2_modelsByMinor.csv", replace csv ///
	b(3) se(3) mtitles legend star(* 0.05 ** 0.01) label ///
	pr2(%4.3f) varwidth(20) modelwidth(6) nogaps
estimates clear


*** Overall Model ***

qui tab rollnum, gen(_rn)
drop _rn1 _rn35 _rn53 _rn61 _rn75
qui tab minor, gen(_min)
drop _min1 _min7 _min10-_min13 _min15-_min17

logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
	percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
	rep partyLineVote birthYear _rn* _min*

qui sum agree_dem if e(sample)
local mean = r(mean)
	
qui foreach var of varlist amt amtH01 amtBCBS amtAARP healthOpinion ///
		IP_voter percSenior unins_rate phys_perc {
	prgen `var', gen(_pr) ci
	replace _prp1lb = 0 if _prp1lb < 0
	replace _prp1ub = 1 if _prp1ub > 1 & !missing(_prp1ub)
	line _prp1 _prp1lb _prp1ub _prx, lcolor(black gs8 gs8) ///
		lpattern(solid dash dash) lwidth(medium medthin medthin) ///
		graphregion(color(white)) leg(off) yline(`mean', lcolor(blue)) ///
		ytitle("Probability of Voting w/ Democrats") xscale(titlegap(2)) ///
		ylab(0(0.5)1, glcolor(white))
	graph export "Figs\ch2\overall\overall_`var'.png", replace height(800)
	drop _pr*
}
drop _rn* _min*

logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
	percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
	rep partyLineVote birthYear i.minor i.rollnum //if amt <= 200
estimates store overall

*For table 2-1
esttab overall using "Tables\ch2_modelOverall.rtf", replace rtf ///
	b(3) se(3) legend star(* 0.05 ** 0.01) label pr2(%4.3f) ///
	varwidth(20) modelwidth(6) nogaps wide ///
	drop(*.rollnum *.minor 100.party 328.party)
estimates clear

//Interesting that the uninsured districts tend to go more with Republican position, while physicians tend to go more Dem.


/*
*** Working/ Old ***

//Problem: we don't know the directionality of these bills/ votes. Need to somehow say whether voting yes or no is conservative or liberal.
	//Possible solutions: pick one legislator as baseline (Charlie Rangel?); use party proportions to weight the votes or determine directions, etc.
	
//Anything to make of the overall? Perhaps some interactions?
logit vote amt amtH01 amtBCBS amtAARP healthOpinion IP_voter percSenior unins_rate phys_perc raceWhite educHS medianIncome i.party birthYear i.minor
//Do something similar with cosponsorships. (getting ideological direction might be tougher here...)


*Model Exploration (using W-NOM as DV)
reg wnom1 amt healthOpinion i.party i.party i.gend birthYear i.reg, r
reg wnom1 amt healthOpinion hospitals count_corrected unins_rate ///
	percSenior raceWhite educNoHS-educGrad i.party ///
	i.gend birthYear

reg wnom1 amt IP_voter count_corrected, r
reg wnom1 amt healthOpinion count_corrected, r

reg wnom1 amt IP_voter count_raw, r
reg wnom1 amt healthOpinion count_raw, r

reg wnom1 amt IP_voter percSenior, r
reg wnom1 amt healthOpinion percSenior, r
	
reg wnom1 amt IP_voter unins_rate, r
estat ic
reg wnom1 amt healthOpinion unins_rate, r
estat ic
reg wnom1 amt healthOpinion IP_voter unins_rate, r
estat ic
reg wnom1 amt healthOpinion unins_rate ///
	educHS i.party birthYear if cong == 111, r
estat ic

//looks like the coefficients are very sensitive to the bills in the DV metric
//Should probably go to an analysis of the coefficients from individual models, and bill characteristics (models based on models, like Clinton 2006?)
//Could do cosponsorships this way, too, without requiring any fancy DV calculation procedures

reg wnom1 amt IP_voter unins_rate povertyBelow100 ///
	raceWhite educHS educBachelor i.party ///
	i.party i.gend birthYear, r
*/

