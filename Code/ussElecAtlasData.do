********************************
*  Election Atlas Senate Data  *
********************************

//Robbie Richards, 4/12/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections\stateResults"

*Read Data
import delimited using "ussData.txt", clear delim(tab)
drop url
destring votes voteperc, replace ignore("%,")

*Party variable
replace party = strtrim(party)
replace party = "REP" if party == "Republican" | party == "LA Republican" ///
	| party == "Republican/Tax Cut Now" | party == "Ind.-Republican"
replace party = "DEM" if party == "Democratic" | party == "Democrat" ///
	| party == "Democratic-F.L." | party == "LA Democratic" ///
	| party == "Democratic-NPL" | party == "Democratic-N.P.L."
replace party = "OTH" if party != "DEM" & party != "REP"

*Collapse and reshape
gsort statefips year -votes
collapse (sum) sumVotes=votes sumPerc=voteperc (max) maxVotes=votes ///
	maxPerc=voteperc (first) candName=candname, by(statefips year ///
	office class party)
reshape wide sumVotes maxVotes sumPerc maxPerc candName, string ///
	i(statefips year office class) j(party)

*Get state names, ICPSR IDs
ren statefips fips
merge m:1 fips using "C:\Users\Robbie\Documents\dissertation\Data\working\states.dta", ///
	nogen keep(1 3) keepusing(state state_icpsr)
order state state_icpsr, first

*Format office var
replace office = "4"
destring office, replace

gen district = .
save "ussData.dta", replace

/*
replace party = "GRN" if party == "Green" | party == "VT Green" ///
	| party == "Vermont Green" | party == "Wisconsin Green" ///
	| party == "Pacific Green" | party == "Desert Greens" ///
	| party == "Green CO"
replace party = "LIB" if party == "Libertarian" | party == "AK Libertarian"
replace party = "IND" if party == "Independent"
replace party = "CON" if party == "American Constitution" ///
	| party == "Constitution" | party == "Constitution IL"
replace party = "NLP" if party == "Natural Law"
replace party = "REF" if party == "Reform"
replace party = "NPA" if strpos(party,"Petition") > 0 ///
	| strpos(party, "No Party") > 0 | strpos(party, "Non-") > 0 ///
	| strpos(party, "Nonpart") > 0 | party == "Not Affiliated" ///
	| party == "Unaffiliated" | party == "Unenrolled"
replace party = "WI" if party == "-" | party == "Write-in"
replace party = "OTH" if strlen(party) > 3
*/

