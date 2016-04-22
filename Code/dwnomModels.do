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
gen rep = mc_party == 200 //MC in cong elected in year (elec_year) is a Republican

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

gen partyComp_4yr = 1 - abs(demScoreOff_4yr - 0.5)
gen partyComp_6yr = 1 - abs(demScoreOff_6yr - 0.5)
gen partyComp_8yr = 1 - abs(demScoreOff_8yr - 0.5)
gen partyComp_10yr = 1 - abs(demScoreOff_10yr - 0.5)

ren dwnom1 dwnom
replace dwnom = -dwnom

drop distPost distType numWinners //unneeded for this analysis

gen years_to_elec = year - elec_year

gen beta3_overall = f2.partyComp * f2.uspDEMdm
gen beta1 = f2.partyComp
gen beta2 = f2.uspDEMdm
gen beta3 = beta3_overall
gen beta4 = f2.winMarg
gen beta5 = f2.uncontested

gen beta1_ranney = f2.folded_ranney_4yrs
gen beta1_hvd = f2.hvd_4yr
gen beta3_ranney = f2.folded_ranney_4yrs * f2.uspDEMdm
gen beta3_hvd = f2.hvd_4yr * f2.uspDEMdm

label variable beta1 "Election-based Index"
label variable beta2 "State Democratic Share of Presidential Vote"
label variable beta3 "Party Competition Measure X Dem Pres. Share"
label variable beta4 "Winning Margin in Election"
label variable beta5 "Uncontested Election"

label variable south "Southern State"
label variable rep "Republican Incumbent"
label variable dem "Democratic Incumbent"

label variable beta1_ranney "Ranney Index"
label variable beta1_hvd "HVD Index"

merge m:1 idno state_icpsr cong district using ///
	"C:\Users\Robbie\Documents\dissertation\Data\VoteView\dwnom_tv.dta", ///
	keep(1 3) keepusing(dwnom1_tv) nogen
replace dwnom1_tv = -dwnom1_tv


*** Models: Final ***

replace beta3 = beta3_overall
reg dwnom1_tv beta1-beta5 south dem rep i.years_to_elec i.offSmall i.year //if offSmall == 4
estimates store m1, title("Overall")
//outreg2 using "Tables\prelimModels.xml", excel replace 2aster drop(i.year) dec(3) label ctitle("Overall") policy(beta3) 
	
*By Party
reg dwnom beta1-beta5 south i.year if dem == 1
estimates store m2, title("DEM")
//outreg2 using "Tables\prelimModels.xml", excel append 2aster drop(i.year) dec(3) label ctitle("Democrats") policy(beta3) 
reg dwnom beta1-beta5 south i.year if rep == 1
estimates store m3, title("REP")
//outreg2 using "Tables\prelimModels.xml", excel append 2aster drop(i.year) dec(3) label ctitle("Republicans") policy(beta3) 

*Ranney, HVD
replace beta3 = beta3_ranney
reg dwnom beta1_ranney beta2-beta5 south dem rep i.years_to_elec i.offSmall i.year
estimates store m4, title("Ranney")
//outreg2 using "Tables\prelimModels.xml", excel append 2aster drop(i.year) dec(3) label ctitle("Ranney") policy(beta3_ranney)
replace beta3 = beta3_hvd
reg dwnom beta1_hvd beta2-beta5 south dem rep i.years_to_elec i.offSmall i.year
estimates store m5, title("HVD")
//outreg2 using "Tables\prelimModels.xml", excel append 2aster drop(i.year) dec(3) label ctitle("HVD") policy(beta3_hvd) groupvar("Party Competition" beta1 beta1_ranney beta1_hvd)

esttab m1 m2 m3 m4 m5 using "Tables\table1_v2.rtf", rtf replace ///
	b(2) se(2) mtitles legend ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	indicate(Year Fixed Effects = *.year, labels("Y" "N")) ///
	order(beta1 beta1_ranney beta1_hvd) varwidth(43) modelwidth(7)

	//cells(b(star fmt(2) label(" ")) se(par fmt(2) label(" ")))

xtset stoff year
gen yr = 1870 + (2 * _n)
replace yr = . if yr > 2010

gen b3 = .
gen b3_se = .
gen b3_ll = .
gen b3_ul = .

levelsof yr, local(yrs)
qui foreach yr of local yrs {
	reg dwnom1_tv cf2.partyComp##cf2.uspDEMdm beta4 beta5 south ///
		dem rep i.years_to_elec i.offSmall i.state_icpsr if year == `yr'
	replace b3 = _b[cF2.partyComp#cF2.uspDEMdm] if yr == `yr'
	replace b3_se = _se[cF2.partyComp#cF2.uspDEMdm] if yr == `yr'
	replace b3_ll = _b[cF2.partyComp#cF2.uspDEMdm] ///
		- (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == `yr'
	replace b3_ul = _b[cF2.partyComp#cF2.uspDEMdm] ///
		+ (1.96 * _se[cF2.partyComp#cF2.uspDEMdm]) if yr == `yr'	
}

twoway (line b3 b3_ul b3_ll yr), yline(0) //xline(1962) xline(1982) xline(2002)

/*
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

