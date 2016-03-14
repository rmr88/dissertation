****************************************
*  Congress Only Models (DW-NOMINATE)  *
****************************************

//Robbie Richards, 2/16/16


*** Setup ***

cd  "C:\Users\Robbie\Documents\dissertation\Analysis"
use "scoresMerged.dta", clear

gen partyComp = 1 - abs(demScoreOff - 0.5) //higher values -> more party competition (range is 0.5-1)
gen partyComp2 = 1 - abs(demScore - 0.5)
gen partyComp_4yr = 1 - abs(demScoreOff_4yr - 0.5)
gen partyComp_6yr = 1 - abs(demScoreOff_6yr - 0.5)
gen partyComp_8yr = 1 - abs(demScoreOff_8yr - 0.5)
gen partyComp_10yr = 1 - abs(demScoreOff_10yr - 0.5)

gen presMarg = 2 * abs(0.5 - demPresShare) //winner's margin in the presidential election (state-level)
gen winMarg = 2 * abs(0.5 - percDem) //winner's margin in the last election

gen south = (state_icpsr >= 40 & state_icpsr <= 49) //state is in the Solid South (as defined by codebook for ICPSR election data)
gen dem = mc_party == 100 //MC in cong elected in year (elec_year) is a Democrat
gen rep = mc_party == 200 //MC in cong elected in year (elec_year) is a Republican

gen stoff = (state_icpsr * 100000) + (office * 10000) + district //state-office-district ID for xtset (serves as x)
keep if !missing(stoff) & !missing(dwnom1) & year > 1870 & elec_type == "G" //ensure no duplicate stoff-year combinations
xtset stoff year
gen ldem = l2.dem //MC in previous cong, elected in l2.year is a Democrat
gen lrep = l2.rep //MC in previous cong, elected in l2.year is a Republican

ren dwnom1 dwnom
replace dwnom = -dwnom

drop elec_type distPost distType numWinners //unneeded for this analysis



*** Models: Final ***

reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south dem rep i.year
outreg2 using "Tables\prelimModels.xml", excel replace 2aster
	
*By Party
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south i.year if dem == 1
outreg2 using "Tables\prelimModels.xml", excel append 2aster
reg dwnom cf2.partyComp##cf2.demPresShare f2.winMarg f2.uncontested ///
	south i.year if rep == 1
outreg2 using "Tables\prelimModels.xml", excel append 2aster

*Ranney, HVD
reg dwnom cf2.folded_ranney_4yrs##cf2.demPresShare f2.winMarg ///
	f2.uncontested south dem rep i.year
outreg2 using "Tables\prelimModels.xml", excel append 2aster
reg dwnom cf2.hvd_4yr##cf2.demPresShare f2.winMarg ///
	f2.uncontested south dem rep i.year
outreg2 using "Tables\prelimModels.xml", excel append 2aster

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

