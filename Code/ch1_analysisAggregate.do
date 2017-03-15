*******************************************
*  Aggregate Data and Analysis for Ch. 1  *
*******************************************

//Robbie Richards, 12/20/16


*** Setup ***

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

collapse (mean) mn_dwnom=dwnom mn_partyComp=partyComp_4yr ///
	mn_presMarg=presMarg mn_winMarg=winMarg perc_dem=dem ///
	mn_ranney4=folded_ranney_4yrs mn_hvd4=hvd_4yr mn_usp=uspDEMdm ///
	(median) med_dwnom=dwnom med_partyComp=partyComp_4yr ///
	med_presMarg=presMarg med_winMarg=winMarg med_usp=uspDEMdm ///
	med_ranney4=folded_ranney_4yrs med_hvd4=hvd_4yr ///
	(p25) p25_partyComp=partyComp_4yr, by(year offSmall)

merge m:1 year using "PolicyAgendasProject\mood.dta"
merge m:1 year using "elections\uspNational.dta", keep(1 3) nogen
ren demPerc demPercUSP

drop congress
gen cong = 1 + ((year - 1788) / 2)
merge 1:1 cong offSmall using "..\Analysis\quintileData.dta", gen(qmerge)

xtset offSmall year

merge m:1 cong using "VoteView\chamberMeans.dta", nogen keep(3)
foreach var of varlist mean1_* {
	replace `var' = -`var'
}

merge m:1 cong using "VoteView\partyMedians.dta", nogen keep(3)
replace med1Party = -med1Party

gen majPercChamber = numLegMaj / numLeg
gen dem = ptyMaj == "Democrat"
gen midterm = mod(year, 4) == 2

drop if offSmall != 3
tsset year

*Models vars
gen l_med_dwnom = l2.med_dwnom
gen l_mean1_chamber = l2.mean1_chamber
gen l_med1Party = l2.med1Party
gen l_mean1_maj = l2.mean1_maj
gen ldv = l_med_dwnom

gen ptyCompMood = mn_partyComp * mood
gen ptyCompPres = mn_partyComp * demPercUSP
gen ranneyMood = mn_ranney4 * mood
gen ranneyPres = mn_ranney4 * demPercUSP
gen hvdMood = mn_hvd4 * mood
gen hvdPres = mn_hvd4 * demPercUSP

*Labels
label variable ldv "Lagged Dependent Variable"
label variable mn_partyComp "Mean Party Competition"
label variable mood "Public Mood"
label variable demPercUSP "Democratic Presidential Vote Share"
label variable mn_ranney4 "Mean Ranney Index"
label variable mn_hvd4 "Mean HVD Index"
label variable majPercChamber "Majority Percentage in Chamber"
label variable dem "Democratic Majority"
label variable midterm "Election Was Midterm"
label variable ptyCompMood "Party Competition X Mood"
label variable ptyCompPres "Party Competition X Dem Votes"
label variable ranneyMood "Ranney X Mood"
label variable ranneyPres "Ranney X Dem Votes"
label variable hvdMood "HVD X Mood"
label variable hvdPres "HVD X Dem Votes"

//export delimited med_dwnom ldv mn_partyComp mood ptyCompMood ///
//	majPercChamber dem midterm using "..\Analysis\mfx_agg_rdata.csv", ///
//	replace delim(",")


*** Models ***

*Chamber Median
reg med_dwnom ldv mn_partyComp mood ptyCompMood majPercChamber dem midterm //it's weird that when you take out dem, the coefficients of interest go to 0.
estimates store m1, title("Chamber Median")
reg med_dwnom ldv mn_partyComp demPercUSP ptyCompPres majPercChamber dem midterm
estimates store m2, title("Chamber Median")

reg med_dwnom ldv mn_ranney4 mood ranneyMood majPercChamber dem midterm
estimates store m1_ran, title("Chamber Median")
reg med_dwnom ldv mn_ranney4 demPercUSP ranneyPres majPercChamber dem midterm
estimates store m2_ran, title("Chamber Median")

reg med_dwnom ldv mn_hvd4 mood hvdMood majPercChamber dem midterm
estimates store m1_hvd, title("Chamber Median")
reg med_dwnom ldv mn_hvd4 demPercUSP hvdPres majPercChamber dem midterm
estimates store m2_hvd, title("Chamber Median")

*Majority Median
replace ldv = l_med1Party
reg med1Party ldv mn_partyComp mood ptyCompMood majPercChamber dem midterm
estimates store m3, title("Majority Median")
reg med1Party ldv mn_partyComp demPercUSP ptyCompPres majPercChamber dem midterm
estimates store m4, title("Majority Median")

reg med1Party ldv mn_ranney4 mood ranneyMood majPercChamber dem midterm
estimates store m3_ran, title("Majority Median")
reg med1Party ldv mn_ranney4 demPercUSP ranneyPres majPercChamber dem midterm
estimates store m4_ran, title("Majority Median")

reg med1Party ldv mn_hvd4 mood hvdMood majPercChamber dem midterm
estimates store m3_hvd, title("Majority Median")
reg med1Party ldv mn_hvd4 demPercUSP hvdPres majPercChamber dem midterm
estimates store m4_hvd, title("Majority Median")

*Chamber Mean
replace ldv = l_mean1_chamber
reg mean1_chamber ldv mn_partyComp mood ptyCompMood majPercChamber dem midterm
estimates store m1_mn, title("Chamber Mean")
reg mean1_chamber ldv mn_partyComp demPercUSP ptyCompPres majPercChamber dem midterm
estimates store m2_mn, title("Chamber Mean")

*Majority Mean
replace ldv = l_mean1_maj
reg mean1_maj ldv mn_partyComp mood ptyCompMood majPercChamber dem midterm
estimates store m3_mn, title("Majority Mean")
reg mean1_maj ldv mn_partyComp demPercUSP ptyCompPres majPercChamber dem midterm
estimates store m4_mn, title("Majority Mean")


*** Output ***

*Table 1-3
esttab m1 m2 m3 m4 using "..\Analysis\Tables\table1-3.rtf", ///
	b(2) se(2) mtitles legend onecell replace rtf ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	order(ldv mn_partyComp mood ptyCompMood demPercUSP ptyCompPres)

*Table A1-5 (Means)
esttab m?_mn using "..\Analysis\Tables\table_a1-5.rtf", ///
	b(2) se(2) mtitles legend onecell replace rtf ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	order(ldv mn_partyComp mood ptyCompMood demPercUSP ptyCompPres)

*Table A1-6 (Ranney)
esttab m?_ran using "..\Analysis\Tables\table_a1-6.rtf", ///
	b(2) se(2) mtitles legend onecell replace rtf ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	order(ldv mn_ranney4 mood ranneyMood demPercUSP ranneyPres)

*Table A1-7 (HVD)
esttab m?_hvd using "..\Analysis\Tables\table_a1-7.rtf", ///
	b(2) se(2) mtitles legend onecell replace rtf ///
	star(* 0.05 ** 0.01) label varlabels(_cons Constant) ///
	stats(N r2, fmt(0 2) label(Observations R-squared)) ///
	order(ldv mn_hvd4 mood hvdMood demPercUSP hvdPres)


/*
*** OLD MODELS ***

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
*/

