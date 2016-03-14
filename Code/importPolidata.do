*** Import PoliData Votes ***

//Robbie Richards, 2/29/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections\polidata"
import delimited using "_polidataResults.txt", clear delim(tab)
destring *vote, ignore(",") replace

gen partyCands = 2 if demvote != 0 & repvote != 0
replace partyCands = 1 if demvote == 0 | repvote == 0
gen oneMajorCand = partyCands == 1
gen uncontested = (partyCands == 1 & othvote == 0)

keep state district year office demvote repvote othvote totvote ///
	partyCands oneMajorCand uncontested

replace office = "3" if office == "Cong."
replace office = "1" if office == "Pres."
destring office, replace

gen month = 11
gen elec_type = "G"
ren totvote totalVotes
gen partyVotes = demvote + repvote
ren demvote votesSumDem
ren repvote votesSumRep
ren othvote votesSumOth

merge m:1 state using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen keep(1 3) keepusing(state_icpsr)

compress
save "_polidataResults.dta", replace
