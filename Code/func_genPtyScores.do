*** Generate Party Scores ***

//Robbie Richards, 8/29/16
//run as a function by elecDataPtyScores.do
//Parameters: 1 - varname suffix

collapse (mean) avgCands=cands percUncontested=uncontested ///
	percOneMCand=oneMajorCand avgPartyCands=partyCands ///
	(sum) sumVotesDem=sumVotesDEM sumVotesRep=sumVotesREP ///
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

foreach var of varlist avgCands-demScore {
	ren `var' `var'`1'
}
