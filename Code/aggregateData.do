
cd "C:\Users\Robbie\Documents\dissertation\Data"
use "allElectionData.dta", clear

keep if offSmall == 3 | offSmall == 4
keep if year >= 1870

replace mc_party = . if mc_party != 100 & mc_party != 200
gen dem = mc_party == 100
replace dem = . if missing(mc_party)

gen partyComp = 1 - abs(demScoreOff - 0.5)
gen presMarg = 2 * abs(0.5 - uspDEMdm)
gen percDem = sumVotesDEM / partyVotes
gen winMarg = 2 * abs(0.5 - percDem)

gen stoff = (state_icpsr * 100000) + (office * 10000) + district //state-office-district ID for xtset (serves as x)
keep if !missing(stoff) & !missing(dwnom1) & year > 1870
xtset stoff year
gen demScoreOff_4yr = (demScoreOff + l2.demScore) / 2
gen partyComp_4yr = 1 - abs(demScoreOff_4yr - 0.5)

ren dwnom1 dwnom
replace dwnom = -dwnom

//gen south = (state_icpsr >= 40 & state_icpsr <= 49)

collapse (mean) mn_dwnom=dwnom mn_partyComp=partyComp_4yr ///
	mn_presMarg=presMarg mn_winMarg=winMarg perc_dem=dem ///
	mn_ranney4=folded_ranney_4yrs mn_hvd4=hvd_4yr mn_usp=uspDEMdm ///
	(median) med_dwnom=dwnom med_partyComp=partyComp_4yr ///
	med_presMarg=presMarg med_winMarg=winMarg med_usp=uspDEMdm ///
	med_ranney4=folded_ranney_4yrs med_hvd4=hvd_4yr ///
	(p25) p25_partyComp=partyComp_4yr, by(year offSmall)

merge m:1 year using "PolicyAgendasProject\mood.dta"
merge m:1 year using "elections\uspNational.dta", keep(1 3) nogen

drop congress
gen cong = 1 + ((year - 1788) / 2)
merge 1:1 cong offSmall using "..\Analysis\quintileData.dta", gen(qmerge)

xtset offSmall year

merge m:1 cong using "C:\Users\Robbie\Documents\dissertation\Data\VoteView\chamberMeans.dta", ///
	nogen keep(3)
foreach var of varlist mean1_* {
	replace `var' = -`var'
}

merge m:1 year using "C:\Users\Robbie\Documents\dissertation\Data\presMarginsOverall.dta", ///
	nogen keep(3)

gen dem = ptyMaj == "Democrat"

*Median DW-NOMINATE Score
cap drop abs_diff? diff?
reg d.mean1_chamber d.demmarg
predict diff1, resid
gen abs_diff1 = abs(diff1)

reg abs_diff1 mn_ranney4 demPerc mn_winMarg if offSmall == 3
reg abs_diff1 mn_partyComp perc_dem mn_winMarg if offSmall == 3

*Mean DW-NOMINATE Score
reg mn_dwnom mn_presMarg
predict diff2, resid
gen abs_diff2 = abs(diff2)

reg abs_diff2 med_partyComp i.offSmall perc_dem mn_winMarg



reg abs_diff1 l2.mnComp3 i.offSmall perc_dem mn_winMarg

twoway (scatter med_dwnom mood if mn_partyComp > 0.9, mcolor(red*0.7)) ///
	(scatter med_dwnom mood if mn_partyComp <= 0.9, mcolor(blue*0.7)) ///
	(lfit med_dwnom mood, lcolor(black)) ///
	if offSmall == 3
