**********************************************
*  Test Different Party Competition Indices  *
**********************************************

//Robbie Richards, 8/29/16


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
gen rep = mc_party == 200

gen stoff = (state_icpsr * 100000) + (office * 10000) + district //state-office-district ID for xtset (serves as x)
keep if !missing(stoff) & !missing(dwnom1) & year > 1870
//duplicates tag stoff year elec_year, gen(d)
//drop if d & missing(sumVotesDEM) & missing(sumVotesREP)
//drop d

xtset stoff year
gen ldem = l2.dem //MC in previous cong, elected in l2.year is a Democrat
gen lrep = l2.rep //MC in previous cong, elected in l2.year is a Republican

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


*** Models ***

*All offices
reg dwnom beta1-beta5 south dem rep i.year if offSmall == 3
estimates store m1, title("Overall")

reg dwnom beta1-beta5 south dem rep i.year has* if offSmall == 3
estimates store m1a, title("Overall")

*No State Legislature
xtset
replace partyComp = 1 - abs(demScoreOff_nostl - 0.5)
replace beta1 = f2.partyComp
replace beta3_overall = f2.partyComp * f2.uspDEMdm
replace beta3 = beta3_overall

reg dwnom beta1-beta5 south dem rep i.year if offSmall == 3
estimates store m2, title("No STL")

reg dwnom beta1-beta5 south dem rep i.year has* if offSmall == 3
estimates store m2a, title("No STL")

*Governor and Federal only
xtset
replace partyComp = 1 - abs(demScoreOff_govfed - 0.5)
replace beta1 = f2.partyComp
replace beta3_overall = f2.partyComp * f2.uspDEMdm
replace beta3 = beta3_overall

reg dwnom beta1-beta5 south dem rep i.year if offSmall == 3
estimates store m3, title("Gov/ Fed")

reg dwnom beta1-beta5 south dem rep i.year has* if offSmall == 3
estimates store m3a, title("Gov/ Fed")

*Compare
estimates table m1 m1a m2 m2a m3 m3a, star(0.05 0.01 0.001) drop(i.year)

