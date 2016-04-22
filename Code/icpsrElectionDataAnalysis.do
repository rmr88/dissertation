*** Election Data, ICPSR, 1788-1990 ***

//Robbie Richards, 2/4/16

*Setup overall stats
run "C:\Users\Robbie\Documents\dissertation\Code\electionDataIcpsr0002.do"

*Generate state-by-year scores
drop if office == 1
//append using "C:\Users\Robbie\Documents\dissertation\Data\elections\polidata\_polidataResults.dta"

collapse (mean) avgCands=cands percUncontested=uncontested ///
	percOneMCand=oneMajorCand avgPartyCands=partyCands ///
	(sum) sumVotesDem=votesSumDem sumVotesRep=votesSumRep ///
	sumTotalVotes=totalVotes sumPartyVotes=partyVotes, ///
	by(state_icpsr year) //may want some indication of number of offices, total number of candidates overall, etc.
gen demScore = sumVotesDem / sumPartyVotes

save "C:\Users\Robbie\Documents\dissertation\Data\working\partyScoresOverall.dta", replace

*Merge partyScores back into data
run "C:\Users\Robbie\Documents\dissertation\Code\electionDataIcpsr0002.do"
//append using "C:\Users\Robbie\Documents\dissertation\Data\elections\polidata\_polidataResults.dta"

merge m:1 year state_icpsr using ///
	"C:\Users\Robbie\Documents\dissertation\Data\working\partyScoresOverall.dta", ///
	keep(3) nogen

*Generate office-specific party scores
ren votesSumDem votesDem
ren votesSumRep votesRep
drop votesMax*

gen demScoreOff = (sumVotesDem - votesDem) / (sumPartyVotes - partyVotes) ///
	if office != 1
replace demScoreOff = demScore if office == 1
gen percDem = votesDem / partyVotes
gen percRep = votesRep / partyVotes

gen offSmall = office
replace offSmall = 4 if office == 5 | office == 6
label values offSmall OFF

save "C:\Users\Robbie\Documents\dissertation\Data\elections\partyScores.dta", replace

