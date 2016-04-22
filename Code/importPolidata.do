*** Import PoliData Votes ***

//Robbie Richards, 2/29/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections\polidata"
import delimited using "_polidataResults.txt", clear delim(tab)
destring *vote, ignore(",") replace

keep state district year office demvote repvote othvote totvote

replace office = "3" if office == "Cong."
replace office = "1" if office == "Pres."
destring office, replace

ren demvote sumVotesDEM
ren repvote sumVotesREP
ren othvote sumVotesOTH
ren totvote totalVotes

append using "C:\Users\Robbie\Documents\dissertation\Data\mrpideo\cd.dta"

replace year = 2008 if cong == 112
replace year = 2012 if cong == 113
replace state = abb if state == ""
replace office = 1 if missing(office)
drop cd_fips-cong

replace sumVotesREP = 1 - sumVotesDEM if sumVotesDEM < 1 ///
	& missing(sumVotesREP)
gen partyVotes = sumVotesDEM + sumVotesREP
gen partyCands = 2 if sumVotesDEM != 0 & sumVotesREP != 0
replace partyCands = 1 if sumVotesDEM == 0 | sumVotesREP == 0
gen oneMajorCand = partyCands == 1
gen uncontested = (partyCands == 1 & ///
	(sumVotesOTH == 0 | missing(sumVotesOTH)))

merge m:1 state using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen keep(1 3) keepusing(state_icpsr)
replace district = 1 if district == 99 | district == 0

duplicates drop
compress
save "_polidataResults.dta", replace
