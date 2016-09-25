/*
twoway (scatter partyComp dwnom if mc_party == 100, mcolor(blue)) ///
	(scatter partyComp dwnom if mc_party == 200, mcolor(red)) ///
	(lfit partyComp dwnom if mc_party == 100, lcolor(blue)) ///
	(lfit partyComp dwnom if mc_party == 200, lcolor(red)) ///
	if cong == 107 & offSmall == 3
*/

local cong = 80
sum dwnom if cong == `cong' & offSmall == 3, d
twoway (scatter partyComp dwnom) (qfit partyComp dwnom) ///
	if cong == `cong' & offSmall == 3, xline(`r(p50)')

gen dwnomSq = dwnom * dwnom

gen cng = 42 + _n
replace cng = . if cng > 113
cap drop lin sq
gen lin = .
gen sq = .
 
qui forvalues c = 43/113 {
	reg partyComp dwnom dwnomSq if cong == `c'
	replace lin = _b[dwnom] if cng == `c'
	replace sq = _b[dwnomSq] if cng == `c'
}

line lin sq cng, yline(0)


reg dwnom cf2.uspDEMdm##cf2.partyComp f2.winMarg f2.uncontested dem rep south i.year
reg dwnom cf2.uspDEMdm##cf2.partyComp##cf2.partyComp f2.winMarg f2.uncontested dem rep south i.year


//Linear: 0.5 -> 0.39, 0.75 -> 0.59, 1 -> 0.78
//quadratic: 0.5 -> 1.31, 0.75 -> 1.65, 1.78


sort cong offSmall dwnom
by cong offSmall: gen rank = _n

gen quintile = .
forvalues q = 1/5 {
	by cong offSmall: replace quintile = `q' if missing(quintile) & rank < (`q' * _N / 5)
}

bys cong offSmall quintile: egen mnComp = mean(partyComp)

preserve
	replace quintile = 1 if quintile == 2
	replace quintile = 5 if quintile == 4
	collapse mnComp, by(cong offSmall quintile)
	drop if missing(quintile)
	reshape wide mnComp, i(cong offSmall) j(quintile)
	list cong offSmall mnComp* if !missing(offSmall) & !missing(cong)
	//line mnComp* cong if offSmall == 3, lcolor(red purple blue)
	twoway (line mnComp* year if offSmall == 3, lcolor(red*0.4 purple*0.4 blue*0.4)) ///
		(lowess mnComp1 year if offSmall == 3, lcolor(red) bw(0.5)) ///
		(lowess mnComp3 year if offSmall == 3, lcolor(purple) bw(0.5)) ///
		(lowess mnComp5 year if offSmall == 3, lcolor(blue) bw(0.5)), ///
		ylab(#4, glcolor(white)) xlab(1870(20)2010) xtitle("Year") ytitle("Average Party Competition") ///
		leg(order(4 "Bottom Quintiles" 5 "Middle Quintile" 6 "Top Quintiles") ///
			cols(3) region(lcolor(white) fcolor(gs15))) graphregion(color(white)) ///
		note("Quintiles are quntiles of ideology, with lower values representing conservative ideology. Smoothed" ///
			"lines are lowess curves, bin width = 0.5.", span)
	graph export "..\Analysis\Figs\misc_fig2.png", replace height(800)
	save "quintileData.dta", replace
restore

xtset stoff year
cap drop yr
gen yr = 1938 + (2 * _n)
replace yr = . if yr > 2008
levelsof yr, local(yrs)

foreach q in 0.1 0.3 0.5 0.7 0.9 {
	local stub = string(`q'*10)
	cap drop b3*_`stub'
	gen b3_`stub' = .
	gen b3se_`stub' = .
	gen b3sig_`stub' = .
	
	qui foreach yr of local yrs {
		qreg dwnom1_tv beta1_ranney beta2 beta3_ranney beta4 beta5 south ///
			dem rep i.state_icpsr if year == `yr' & offSmall == 3, ///
			quantile(`q')
		
		replace b3_`stub' = _b[beta3_ranney] if yr == `yr'
		replace b3se_`stub' = _se[beta3_ranney] if yr == `yr'
	}
	
	replace b3sig_`stub' = (b3_`stub' / b3se_`stub') >= 1.96
}

twoway (line b3_1 b3_5 b3_9 yr, lcolor(red purple blue)), ///
	graphregion(color(white)) xtitle("Year") ytitle("Beta3 for Quantile") ///
	leg(order(1 "10th Pctile" 2 "Median" 3 "90th Pctile") cols(3))
	
global mopt = "mfcolor(none) mstyle(circle_hollow)"
twoway (line b3_1 b3_3 b3_5 b3_7 b3_9 yr, lcolor(red red*0.5 purple blue*0.5 blue)) ///
	(scatter b3_1 yr if b3sig_1 == 0, mlcolor(red) $mopt) ///
	(scatter b3_3 yr if b3sig_3 == 0, mlcolor(red*0.5) $mopt) ///
	(scatter b3_5 yr if b3sig_5 == 0, mlcolor(purple) $mopt) ///
	(scatter b3_7 yr if b3sig_7 == 0, mlcolor(blue*0.5) $mopt) ///
	(scatter b3_9 yr if b3sig_9 == 0, mlcolor(blue) $mopt), ///
	graphregion(color(white)) xtitle("Year") ytitle("Beta3 for Quantile") ///
	leg(order(1 "10th Pctile" 2 "30th Pctile" 3 "Median" 4 "70th Pctile" 5 "90th Pctile"))

	