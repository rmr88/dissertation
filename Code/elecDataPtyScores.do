**DEPRECATED**

*** Election Data Party Scores ***

//Robbie Richards, 2/4/16

*** Setup ***

cd "C:\Users\Robbie\Documents\dissertation\Data"
global code = "C:\Users\Robbie\Documents\dissertation\Code"

run "$code\electionDataIcpsr0002.do"
//use "elections\electionDataPreScore.dta", clear


*** State-by-year Scores ***

drop if office == 1
run "$code\func_genPtyScores.do" "_all"

save "working\partyScoresOverall.dta", replace


*** Alternate Scores for Robustness Checks ***

*No state legislature
use "elections\electionDataPreScore.dta", clear

drop if office == 1 | office > 7
run "$code\func_genPtyScores.do" "_nostleg"
drop avgCands_nostleg percUncontested_nostleg percOneMCand_nostleg ///
	avgPartyCands_nostleg sumVotesRep_nostleg sumTotalVotes_nostleg
	
merge m:1 year state_icpsr using "working\partyScoresOverall.dta", nogen
save "working\partyScoresOverall.dta", replace

*Governor and federal only
use "elections\electionDataPreScore.dta", clear

drop if office == 1 | office >= 7
run "$code\func_genPtyScores.do" "_govfed"
drop avgCands_govfed percUncontested_govfed percOneMCand_govfed ///
	avgPartyCands_govfed sumVotesRep_govfed sumTotalVotes_govfed
	
merge m:1 year state_icpsr using "working\partyScoresOverall.dta", nogen
save "working\partyScoresOverall.dta", replace	

*Statewide only
use "elections\electionDataPreScore.dta", clear

drop if office == 1 | office == 3 | office > 7
run "$code\func_genPtyScores.do" "_statewide"
drop avgCands_statewide percUncontested_statewide percOneMCand_statewide ///
	avgPartyCands_statewide sumVotesRep_statewide sumTotalVotes_statewide
	
merge m:1 year state_icpsr using "working\partyScoresOverall.dta", nogen
save "working\partyScoresOverall.dta", replace	


*** Office-specific Party Scores ***

use "elections\electionDataPreScore.dta", clear

gen gov = office == 2
gen uss = office >= 4 & office <= 6
bys state_icpsr year: egen hasGov = max(gov)
bys state_icpsr year: egen hasUss = max(uss)
drop gov uss

merge m:1 year state_icpsr using "working\partyScoresOverall.dta", ///
	keep(3) nogen
	
ren sumVotesDEM votesDem
ren sumVotesREP votesRep
drop maxVotes*

gen demScoreOff = (sumVotesDem_all - votesDem) / ///
	(sumPartyVotes_all - partyVotes) if office != 1
replace demScoreOff = demScore_all if office == 1

gen demScoreOff_nostleg = (sumVotesDem_nostleg - votesDem) / ///
	(sumPartyVotes_nostleg - partyVotes) if office != 1

gen demScoreOff_govfed = (sumVotesDem_govfed - votesDem) / ///
	(sumPartyVotes_govfed - partyVotes) if office != 1
	
egen stoff = group(state_icpsr office district elec_type month ///
	distPost distType numWinners), missing //state-office-district ID for xtset (serves as x)
xtset stoff year

gen demScoreOff_4yr = (demScoreOff + l2.demScore_all) / 2
gen demScoreOff_6yr = (demScoreOff + l2.demScore_all + l4.demScore_all) / 3
gen demScoreOff_8yr = (demScoreOff + l2.demScore_all + l4.demScore_all + l6.demScore_all) / 4
gen demScoreOff_10yr = (demScoreOff + l2.demScore_all + l4.demScore_all + l6.demScore_all + l8.demScore_all) / 5

gen demScoreOff_4yr_alt = (demScoreOff + l2.demScoreOff) / 2
gen demScoreOff_6yr_alt = (demScoreOff + l2.demScoreOff + l4.demScoreOff) / 3
gen demScoreOff_8yr_alt = (demScoreOff + l2.demScoreOff + l4.demScoreOff + l6.demScoreOff) / 4
gen demScoreOff_10yr_alt = (demScoreOff + l2.demScoreOff + l4.demScoreOff + l6.demScoreOff + l8.demScoreOff) / 5

gen percDem = votesDem / partyVotes
gen percRep = votesRep / partyVotes

gen offSmall = office
replace offSmall = 4 if office == 5 | office == 6
label values offSmall OFF
drop stoff

pwcorr demScoreOff demScoreOff_nostleg demScoreOff_govfed demScore_* if year > 1968 & offSmall == 3, sig
//indices are all correlated at 0.8 or higher.

save "elections\partyScores.dta", replace

