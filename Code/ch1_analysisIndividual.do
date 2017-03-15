****************************************
*  Congress Only Models (DW-NOMINATE)  *
****************************************

//Robbie Richards, 2/16/16

*** Setup ***

cd  "C:\Users\Robbie\Documents\dissertation\Analysis"
use "scoresMerged.dta", clear

gen percDem = sumVotesDEM / partyVotes
gen partyComp = 1 - abs(demScoreOff - 0.5) //higher values -> more party competition (range is 0.5-1)
gen partyComp2 = 1 - abs(demScore - 0.5)

gen presMarg = 2 * abs(0.5 - uspDEMdm) //winner's margin in the presidential election (state-level)
gen winMarg = 2 * abs(0.5 - percDem) //winner's margin in the last election

gen south = (state_icpsr >= 40 & state_icpsr <= 49) //state is in the Solid South (as defined by codebook for ICPSR election data)
gen dem = mc_party == 100 //MC in cong elected in year (elec_year) is a Democrat
replace dem = . if dem == 0 & mc_party != 200
gen rep = mc_party == 200 //MC in cong elected in year (elec_year) is a Republican
replace rep = . if rep == 0 & mc_party != 100

gen stoff = (state_icpsr * 100000) + (office * 10000) + district //state-office-district ID for xtset (serves as x)
keep if !missing(stoff) & !missing(dwnom1) & year > 1870
//duplicates tag stoff year elec_year, gen(d)
//drop if d & missing(sumVotesDEM) & missing(sumVotesREP)
//drop d

xtset stoff year
gen ldem = l2.dem //MC in previous cong, elected in l2.year is a Democrat
gen lrep = l2.rep //MC in previous cong, elected in l2.year is a Republican

gen demScoreOff_4yr = (demScoreOff + l2.demScore) / 2
gen demScoreOff_6yr = (demScoreOff + l2.demScore + l4.demScore) / 3
gen demScoreOff_8yr = (demScoreOff + l2.demScore + l4.demScore + l6.demScore) / 4
gen demScoreOff_10yr = (demScoreOff + l2.demScore + l4.demScore + l6.demScore + l8.demScore) / 5

gen partyComp_4yr = 1 - abs(demScoreOff_4yr - 0.5) //Senate doesn't work with these calculations
gen partyComp_6yr = 1 - abs(demScoreOff_6yr - 0.5)
gen partyComp_8yr = 1 - abs(demScoreOff_8yr - 0.5)
gen partyComp_10yr = 1 - abs(demScoreOff_10yr - 0.5)

ren dwnom1 dwnom
replace dwnom = -dwnom

drop distPost distType numWinners //unneeded for this analysis

gen years_to_elec = year - elec_year

gen beta3_overall = f2.partyComp_4yr * f2.uspDEMdm
gen beta1 = f2.partyComp_4yr
gen beta2 = f2.uspDEMdm
gen beta3 = beta3_overall
gen beta4 = f2.winMarg
gen beta5 = f2.uncontested
replace beta5 = 0 if missing(beta5)

gen beta1_ranney = f2.folded_ranney_4yrs
gen beta1_hvd = f2.hvd_4yr
gen beta3_ranney = f2.folded_ranney_4yrs * f2.uspDEMdm
gen beta3_hvd = f2.hvd_4yr * f2.uspDEMdm

label variable beta1 "Party Competition Index"
label variable beta2 "Democratic Share of Presidential Vote"
label variable beta3 "Party Competition Measure X Dem Pres. Share"
label variable beta4 "Winning Margin in Election"
label variable beta5 "Uncontested Election"

label variable south "Southern State"
label variable rep "Republican Incumbent"
label variable dem "Democratic Incumbent"

label variable beta1_ranney "Ranney Index"
label variable beta1_hvd "HVD Index"

merge m:1 idno state_icpsr cong district using ///
	"..\Data\VoteView\dwnom_tv.dta", keep(1 3) keepusing(dwnom1_tv) nogen
replace dwnom1_tv = -dwnom1_tv

merge m:1 state_icpsr office district year using "..\Data\cfScores\cfScores.dta"
replace cfscore = -cfscore
replace cfscoresdyn = -cfscoresdyn

keep if offSmall == 3
merge 1:1 cong idno using "..\Data\VoteView\legis_DWNOM.dta", keepusing(dwnom2) nogen keep(3)
//export delimited dwnom beta2 beta1 beta3 beta4 beta5 south rep year ///
//	if offSmall using "mfx_indiv_rdata.csv", delim(",") replace


*** Models by Marginality ***

*Table 1-1
reg dwnom beta2 beta4 beta5 south rep i.year if offSmall == 3
estimates store mainAll, title("All Districts")
reg dwnom beta2 beta4 south rep i.year if offSmall == 3 & beta4 < 0.25
estimates store main1, title("Margin: Under 25%")
reg dwnom beta2 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.25 & beta4 < 0.5
estimates store main2, title("Margin: 25%-49.9%")
reg dwnom beta2 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.5 & beta4 < 0.75
estimates store main3, title("Margin: 50%-74.9%")
reg dwnom beta2 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.75 & !beta5
estimates store main4, title("Margin: Over 75%")
reg dwnom beta2 south rep i.year if offSmall == 3 & beta5
estimates store main5, title("Uncontested")

esttab mainAll main? using "Tables\table1-1.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell varwidth(23) modelwidth(6) ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N"))

*Table 1-2
reg dwnom beta2 beta1 beta3 beta4 beta5 south rep i.year if offSmall == 3
estimates store ptyAll, title("All Districts")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 < 0.25
estimates store pty1, title("Margin: Under 25%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.25 & beta4 < 0.5
estimates store pty2, title("Margin: 25%-49.9%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.5 & beta4 < 0.75
estimates store pty3, title("Margin: 50%-74.9%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.75 & !beta5
estimates store pty4, title("Margin: Over 75%")
reg dwnom beta2 beta1 beta3 south rep i.year if offSmall == 3 & beta5
estimates store pty5, title("Uncontested")

esttab ptyAll pty? using "Tables\table1-2.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell varwidth(23) modelwidth(6) ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N"))

*Figure A1-1
gen margin = 1 if beta4 < 0.25
replace margin = 2 if beta4 >= 0.25 & beta4 < 0.5
replace margin = 3 if beta4 >= 0.5 & beta4 < 0.75
replace margin = 4 if beta4 >= 0.75 & !beta5
replace margin = 5 if beta5

twoway (lowess beta1 year if margin == 1, lcolor(red)) ///
	(lowess beta1 year if margin == 2, lcolor(red*0.6) lpattern(dash)) ///
	(lowess beta1 year if margin == 3, lcolor(purple)) ///
	(lowess beta1 year if margin == 4, lcolor(blue*0.6) lpattern(dash)) ///
	(lowess beta1 year if margin == 5, lcolor(blue)) ///
	if offSmall == 3, graphregion(color(white)) xtitle("Year of Election") ///
	ytitle("Party Competition") ylab(0.5(0.1)1, nogrid) ///
	leg(order(1 "Margin: Under 25%" 2 "Margin: 25%-49.9%" 3 "Margin: 50%-74.9%" ///
		4 "Margin: 75%+" 5 "Uncontested"))
graph export "Figs\fig_a1-1.png", height(800) replace

*Table A1-1
qui tab year, gen(yr)
collin beta2 beta1 beta3 beta4 beta5 south rep yr2-yr70 if offSmall == 3
collin beta2 beta1 beta3 beta4 south rep yr2-yr70 if offSmall == 3 & beta4 < 0.25
collin beta2 beta1 beta3 beta4 south rep yr2-yr70 if offSmall == 3 & beta4 >= 0.25 & beta4 < 0.5
collin beta2 beta1 beta3 beta4 south rep yr2-yr70 if offSmall == 3 & beta4 >= 0.5 & beta4 < 0.75
collin beta2 beta1 beta3 beta4 south rep yr2-yr70 if offSmall == 3 & beta4 >= 0.75 & !beta5
drop yr1 yr5 yr10 yr11 yr12 yr64 yr71
collin beta2 beta1 beta3 south rep yr* if offSmall == 3 & beta5
drop yr*

*Table A1-2 (Bonica)
reg cfscore beta2 beta1 beta3 beta4 beta5 south rep i.year if offSmall == 3
estimates store ptyAll, title("All Districts")
reg cfscore beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 < 0.25
estimates store pty1, title("Margin: Under 25%")
reg cfscore beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.25 & beta4 < 0.5
estimates store pty2, title("Margin: 25%-49.9%")
reg cfscore beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.5 & beta4 < 0.75
estimates store pty3, title("Margin: 50%-74.9%")
reg cfscore beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.75 & !beta5
estimates store pty4, title("Margin: Over 75%")
reg cfscore beta2 beta1 beta3 south rep i.year if offSmall == 3 & beta5
estimates store pty5, title("Uncontested")

esttab ptyAll pty? using "Tables\table_a1-2.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell varwidth(23) modelwidth(6) ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N"))

*Table A1-3 (Ranney)
replace beta1 = beta1_ranney
replace beta3 = beta3_ranney
label variable beta1 "Ranney Index"

reg dwnom beta2 beta1 beta3 beta4 beta5 south rep i.year if offSmall == 3
estimates store ptyAll, title("All Districts")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 < 0.25
estimates store pty1, title("Margin: Under 25%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.25 & beta4 < 0.5
estimates store pty2, title("Margin: 25%-49.9%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.5 & beta4 < 0.75
estimates store pty3, title("Margin: 50%-74.9%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.75 & !beta5
estimates store pty4, title("Margin: Over 75%")
reg dwnom beta2 beta1 beta3 south rep i.year if offSmall == 3 & beta5
estimates store pty5, title("Uncontested")

esttab ptyAll pty? using "Tables\table_a1-3.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell varwidth(23) modelwidth(6) ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N"))

*Table A1-4 (HVD)
replace beta1 = beta1_hvd
replace beta3 = beta3_hvd
label variable beta1 "HVD Index"

reg dwnom beta2 beta1 beta3 beta4 beta5 south rep i.year if offSmall == 3
estimates store ptyAll, title("All Districts")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 < 0.25
estimates store pty1, title("Margin: Under 25%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.25 & beta4 < 0.5
estimates store pty2, title("Margin: 25%-49.9%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.5 & beta4 < 0.75
estimates store pty3, title("Margin: 50%-74.9%")
reg dwnom beta2 beta1 beta3 beta4 south rep i.year if offSmall == 3 & beta4 >= 0.75 & !beta5
estimates store pty4, title("Margin: Over 75%")
reg dwnom beta2 beta1 beta3 south rep i.year if offSmall == 3 & beta5
estimates store pty5, title("Uncontested")

esttab ptyAll pty? using "Tables\table_a1-4.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell varwidth(23) modelwidth(6) ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N"))


*** Hypothetical Predictions ***

reg dwnom beta2 beta1 beta3 beta4 beta5 south rep i.year

gen beta1_original = beta1
gen beta3_original = beta3

*Party competition >= 0.75
replace beta1 = 0.75 if beta1 < 0.75
replace beta3 = beta1 * beta2
predict dwnom_hat_75

replace beta1 = beta1_original
replace beta3 = beta3_original

*Party competition >= 0.80
replace beta1 = 0.8 if beta1 < 0.8
replace beta3 = beta1 * beta2
predict dwnom_hat_80

replace beta1 = beta1_original
replace beta3 = beta3_original

*Party competition <= 0.70
replace beta1 = 0.7 if beta1 > 0.7 & !missing(beta1)
replace beta3 = beta1 * beta2
predict dwnom_hat_below_70

keep cong idno dwnom* south rep
save "C:\Users\Robbie\Documents\dissertation\Data\VoteView\roll_dictionaries\dwnom_predictions.dta"


/*
*** Models: Final ***

replace beta3 = beta3_overall
reg dwnom beta1-beta5 south rep if offSmall == 3 & beta4 < 0.75 //year >= 1980
estimates store m1, title("Overall")

reg cfscore beta1-beta5 south dem rep i.year if offSmall == 3
estimates store m1_alt, title("Overall")

*By Party
reg dwnom beta1-beta5 south i.year if offSmall == 3 & dem == 1
estimates store m2, title("DEM")
reg cfscore beta1-beta5 south i.year if offSmall == 3 & dem == 1
estimates store m2_alt, title("DEM")

reg dwnom beta1-beta5 south i.year if offSmall == 3 & rep == 1
estimates store m3, title("REP")
reg cfscore beta1-beta5 south i.year if offSmall == 3 & rep == 1
estimates store m3_alt, title("REP")

*Ranney, HVD
replace beta3 = beta3_ranney
reg dwnom beta1_ranney beta2-beta5 south dem rep i.year if offSmall == 3
estimates store m4, title("Ranney")

reg cfscore beta1_ranney beta2-beta5 south dem rep i.year if offSmall == 3
estimates store m4_alt, title("Ranney")

replace beta3 = beta3_hvd
reg dwnom beta1_hvd beta2-beta5 south dem rep i.year if offSmall == 3
estimates store m5, title("HVD")

reg cfscore beta1_hvd beta2-beta5 south dem rep i.year if offSmall == 3
estimates store m5_alt, title("HVD")

*Output
esttab m1 m2 m3 m4 m5 using "Tables\table1-1.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N")) ///
	order(beta1 beta1_ranney beta1_hvd) varwidth(23) modelwidth(6)

esttab m?_alt using "Tables\table1a-1.rtf", rtf replace ///
	b(2) se(2) mtitles legend onecell ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N")) ///
	order(beta1 beta1_ranney beta1_hvd) varwidth(23) modelwidth(6)

*Check different date ranges
replace beta3 = beta3_overall
reg dwnom beta1-beta5 south dem rep i.year if offSmall == 3 ///
	& year >= 1938 & year <= 2010 //compare to Ranney
reg dwnom beta1-beta5 south dem rep i.year if offSmall == 3 ///
	& year >= 1970 & year <= 2012 //compare to HVD

*/
*Figures
cap drop yr b3 b3_se b3_ll b3_ul b1 b1_se b1_ul b1_ll
replace stoff = (state_icpsr * 100000) + (office * 10000) + district
xtset stoff year
gen yr = 1890 + (2 * _n)
replace yr = . if yr > 2010

gen b3 = .
gen b3_se = .
gen b3_ll = .
gen b3_ul = .

gen b1 = .
gen b1_se = .
gen b1_ll = .
gen b1_ul = .

/*
levelsof yr, local(yrs)
qui foreach yr of local yrs {
	reg dwnom cf2.partyComp##cf2.uspDEMdm beta4 beta5 south ///
		dem rep i.years_to_elec i.offSmall i.state_icpsr if year == `yr'
	
	replace b3 = _b[cF2.partyComp#cF2.uspDEMdm] if yr == `yr'
	replace b3_se = _se[cF2.partyComp#cF2.uspDEMdm] if yr == `yr'
	replace b3_ll = _b[cF2.partyComp#cF2.uspDEMdm] ///
		- (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == `yr'
	replace b3_ul = _b[cF2.partyComp#cF2.uspDEMdm] ///
		+ (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == `yr'
	
	replace b1 = _b[F2.uspDEMdm] if yr == `yr'
	replace b1_se = _se[F2.uspDEMdm] if yr == `yr'
	replace b1_ll = _b[F2.uspDEMdm] ///
		- (1.96 * _se[F2.uspDEMdm]) if yr == `yr'
	replace b1_ul = _b[F2.uspDEMdm] ///
		+ (1.96 * _se[F2.uspDEMdm]) if yr == `yr'
}
*/

local yr = 1870
qui while (`yr' <= 1992) { //2000
	local yrmax = `yr' + 20 //10
	reg dwnom cf2.partyComp##cf2.uspDEMdm beta4 beta5 south ///
		dem rep i.years_to_elec if offSmall == 3 & year >= `yr' & year < `yrmax'
	
	replace b3 = _b[cF2.partyComp#cF2.uspDEMdm] if yr == `yrmax'
	replace b3_se = _se[cF2.partyComp#cF2.uspDEMdm] if yr == `yrmax'
	replace b3_ll = _b[cF2.partyComp#cF2.uspDEMdm] ///
		- (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == `yrmax'
	replace b3_ul = _b[cF2.partyComp#cF2.uspDEMdm] ///
		+ (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == `yrmax'
	
	replace b1 = _b[F2.uspDEMdm] if yr == `yr'
	replace b1_se = _se[F2.uspDEMdm] if yr == `yr'
	replace b1_ll = _b[F2.uspDEMdm] ///
		- (1.96 * _se[F2.uspDEMdm]) if yr == `yr'
	replace b1_ul = _b[F2.uspDEMdm] ///
		+ (1.96 * _se[F2.uspDEMdm]) if yr == `yr'
	
	local yr = `yr' + 2 //`yrmax'
}

/*
reg dwnom cf2.partyComp##cf2.uspDEMdm beta4 beta5 south ///
		dem rep i.years_to_elec if offSmall == 3 & year >= 2000
	
replace b3 = _b[cF2.partyComp#cF2.uspDEMdm] if yr == 2000
replace b3_se = _se[cF2.partyComp#cF2.uspDEMdm] if yr == 2000
replace b3_ll = _b[cF2.partyComp#cF2.uspDEMdm] ///
	- (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == 2000
replace b3_ul = _b[cF2.partyComp#cF2.uspDEMdm] ///
	+ (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == 2000

replace b1 = _b[F2.uspDEMdm] if yr == 2000
replace b1_se = _se[F2.uspDEMdm] if yr == 2000
replace b1_ll = _b[F2.uspDEMdm] ///
	- (1.96 * _se[F2.uspDEMdm]) if yr == 2000
replace b1_ul = _b[F2.uspDEMdm] ///
	+ (1.96 * _se[F2.uspDEMdm]) if yr == 2000
*/

twoway (line b3 b3_ul b3_ll yr, yaxis(1) lcolor(black gs8 gs8) ///
	lpattern(solid dash dash)), yline(0, lcolor(gs5)) leg(off) ///
	graphregion(color(white)) xtitle("Year") ylab(-2(2)4, nogrid) ///
	ytitle("Change in DW-NOMINATE Score") 
graph export "Figs\fig1-1.png", height(800) replace
//export delimited yr-b1_ul using "Figs\data_fig1-3.txt" ///
//	if !missing(b3), delim(tab) replace

/*
cap drop resph resp_ul resp_ll respl
gen resph = b1 + b3
gen resp_ul = b1_ul + b3_ul
gen resp_ll = b1_ll + b3_ll
gen respl = b1 + (b3/2)


twoway (line resph respl yr), yline(0) //xline(1962) xline(1982) xline(2002)


*** Models: New Pty Comp Index ***

*No fixed effects
reg dwnom c.partyComp##c.demPresShare
reg dwnom c.partyComp##c.demPresShare winMarg uncontested south
reg dwnom c.partyComp##c.demPresShare winMarg uncontested dem rep south

*No FE, Election at end of period
reg dwnom cf2.partyComp##cf2.demPresShare
estat ic //different N, so hard to compare IC. Fit is worse, but not by much
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested south
estat ic //this one is way better than the one below, though fit is worse
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south dem rep
estat ic //better than the FE models, but not as good as one above

*Year FE
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south dem rep i.year
estat ic //not as good BIC/AIC as without FE; only marginal improvement in fit

*State FE
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south dem rep i.state_icpsr
estat ic //not as good BIC/AIC as without FE; only marginal improvement in fit

*By party
reg dwnom cf2.partyComp##cf2.demPresShare if dem == 1
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south if dem == 1
estat ic
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south i.year if dem == 1
estat ic

reg dwnom cf2.partyComp##cf2.demPresShare if rep == 1
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south if rep == 1
estat ic
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south i.year if rep == 1
estat ic

*Single-year models, compare over time


*** Models: Ranney and HVD Indices ***

reg dwnom cf2.folded_ranney_4yrs##cf2.demPresShare f2.winMarg ///
	f2.uncontested south
reg dwnom cf2.hvd_4yr##cf2.demPresShare f2.winMarg ///
	f2.uncontested south
	
reg dwnom cf2.folded_ranney_4yrs##cf2.demPresShare f2.winMarg ///
	f2.uncontested south i.year
reg dwnom cf2.hvd_4yr##cf2.demPresShare f2.winMarg ///
	f2.uncontested south i.year
*/

