*** Election Data Party Scores ***

//Robbie Richards, 2/4/16

*Setup overall stats
run "C:\Users\Robbie\Documents\dissertation\Code\electionDataIcpsr0002.do"

*Generate state-by-year scores
drop if office == 1
collapse (mean) avgCands=cands percUncontested=uncontested ///
	percOneMCand=oneMajorCand avgPartyCands=partyCands ///
	(sum) sumVotesDem=votesSumDem sumVotesRep=votesSumRep ///
	sumTotalVotes=totalVotes sumPartyVotes=partyVotes, ///
	by(state_icpsr year) //may want some indication of number of offices, total number of candidates overall, etc.

xtset state_icpsr year
gen oddYr = mod(year, 2) //==0 if year is even, 1 otherwise
gen lsumVotesDem = l.sumVotesDem
replace lsumVotesDem = 0 if missing(lsumVotesDem)
gen lsumPartyVotes = l.sumPartyVotes
replace lsumPartyVotes = 0 if missing(lsumPartyVotes)

gen demScore = (sumVotesDem + lsumVotesDem) / (sumPartyVotes + lsumPartyVotes) if oddYr == 0
drop oddYr lsum*

save "C:\Users\Robbie\Documents\dissertation\Data\working\partyScoresOverall.dta", replace

*Merge partyScores back into data
run "C:\Users\Robbie\Documents\dissertation\Code\electionDataIcpsr0002.do"

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

egen stoff = group(state_icpsr office district elec_type month ///
	distPost distType numWinners), missing //state-office-district ID for xtset (serves as x)
xtset stoff year

gen demScoreOff_4yr = (demScoreOff + l2.demScore) / 2
gen demScoreOff_6yr = (demScoreOff + l2.demScore + l4.demScore) / 3
gen demScoreOff_8yr = (demScoreOff + l2.demScore + l4.demScore + l6.demScore) / 4
gen demScoreOff_10yr = (demScoreOff + l2.demScore + l4.demScore + l6.demScore + l8.demScore) / 5

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

save "C:\Users\Robbie\Documents\dissertation\Data\elections\partyScores.dta", replace

