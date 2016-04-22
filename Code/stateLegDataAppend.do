*** Append State Leg Data to Federal/ Statewide Data ***

//Robbie Richards, 2/5/16

*Read file, collapse
cd "C:\Users\Robbie\Documents\dissertation\Data\elections\stateLegData"
use "stateLegResults.dta", clear

collapse (firstnm) numCand-othVotes, by(year month stateICPSR ///
	state distNum distPost distType numWinners elecType senOrHouse)
compress

*Make elec_type consistent
replace elecType = "S" if elecType == "SG"
replace elecType = "G" if elecType == "LAF" | elecType == "LAR"
keep if elecType == "G" | elecType == "S"

*Generate party variables
gen partyCands = numDem + numRep
drop numDem numRep numOth
gen partyVotes = demVotes + repVotes
drop othVotes

*Make varnames consistent
ren senOrHouse office
ren distNum district
ren stateICPSR state_icpsr
ren elecType elec_type
ren numCand cands
ren repVotes sumVotesREP
ren demVotes sumVotesDEM

save "stateLegDataWide.dta", replace

