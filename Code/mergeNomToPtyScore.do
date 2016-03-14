*** Merge NOMINATE Data with Party Scores ***

//Robbie Richards, 2/8/16

cd "C:\Users\Robbie\Documents\dissertation\Data"
use "VoteView\legis_DWNOM.DTA", clear

*Rename variables
ren state state_icpsr
ren cd district
ren party mc_party
ren name mc_name
ren statenm state_n

*Get other variables
replace state_n = strtrim(state_n)
compress
merge m:1 state_n using "working\states.dta", keep(3) nogen

gen year = 1788 + (2 * (cong - 1))
//merge m:1 state year using "elections\senateClasses.dta", nogen keep(3)

gen offSmall = 3 if district != 0 & !missing(district)
replace offSmall = 4 if district == 0

/*
replace mc_name = strtrim(mc_name)
gen winnerLast = substr(mc_name, 1, strpos(mc_name, " ")-1)
replace winnerLast = mc_name if missing(winnerLast)
gen winnerFirst2 = substr(mc_name, strpos(mc_name, " ")+1, .)
replace winnerFirst2 = "" if winnerFirst2 == winnerLast
replace winnerFirst2 = strtrim(winnerFirst2)
*/
