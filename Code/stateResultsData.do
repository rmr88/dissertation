*******************************************
*  State Election Results from SQL Table  *
*******************************************

//Robbie Richards, 3/17/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections\stateResults"


*** Get Geography Types ***

clear all
odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=dissertData;UID=stataread;PWD=851hiatus;") ///
	exec("SELECT DISTINCT stateResults.geographyType FROM dissertData..stateResults WHERE stateResults.geographyType IS NOT NULL AND stateResults.geographyType != 'state'")
levelsof geographyType, local(geos) clean



*** Read in Statewide Data ***

clear
odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=dissertData;UID=stataread;PWD=851hiatus;") ///
	exec("SELECT * FROM dissertData..stateResults WHERE stateResults.geographyType = 'state'")
destring votes, replace
replace party = "OTH" if party != "DEM" & party != "REP"
replace candName = strupper(candName)

collapse (sum) sumVotes=votes (max) maxVotes=votes (firstnm) candName, ///
	by(state year office district party locationName geographyType)

reshape wide sumVotes maxVotes candName, i(state year office ///
	district locationName geographyType) j(party) string

save "stateResultsRaw.dta", replace


*** Read Data in By Geography Type ***

qui foreach geo of local geos {
	noi: di "Processing `geo' data"
	clear
	odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=dissertData;UID=stataread;PWD=851hiatus;") ///
		exec("SELECT * FROM dissertData..stateResults WHERE stateResults.geographyType = '`geo'' AND stateResults.party IS NOT NULL")
	destring votes, replace
	replace party = "OTH" if party != "DEM" & party != "REP"
	
	if ("`geo'" == "precinct" | "`geo'" == "county") {
		sort state year office district votes
		duplicates drop state-locationName if state == "AR", force //there's an issue in the AR data that is handled here.
	}
	
	collapse (sum) sumVotes=votes (max) maxVotes=votes (firstnm) candName, ///
		by(state year office district party locationName geographyType)
	
	reshape wide sumVotes maxVotes candName, i(state year office ///
		district locationName geographyType) j(party) string
		
	append using "stateResultsRaw.dta"
	save "stateResultsRaw.dta", replace
}

use stateResultsRaw.dta, clear
drop if year < 1990

replace office = strupper(office)
keep if (strlen(office) == 3 & regexm(office, "[A-Z][A-Z][A-Z]") == 1) | ///
	substr(office, 1, 3) == "COM"
drop if office == "CCJ" | office == "CPL" | office == "ADG" | ///
	office == "SCJ" | office == "USL" | office == "COMRR" | ///
	office == "PSC" | office == "STH" | office == "STS" | ///
	office == "COMMISSIONER"

replace district = "1" if district == "One" | ///
	district == "First Congressional District"
replace district = "2" if district == "Two"
replace district = "3" if district == "Three" | ///
	district == "3 DISTRICT-WESTERN ARKANSAS"
replace district = substr(district, 2, .) if state == "NJ" & year == 2014
replace district = "" if office != "USH"
destring district, replace

collapse (sum) sumVotes* maxVotes* (firstnm) candName*, ///
	by(state year geographyType office district)

drop if (state == "AR" & office == "USH" & year < 2000) ///
	| (state == "CA" & office == "USH" & year == 2000)

gen partyCands = 2 if sumVotesDEM != 0 & sumVotesREP != 0
replace partyCands = 1 if sumVotesDEM == 0 | sumVotesREP == 0
gen oneMajorCand = partyCands == 1
gen uncontested = (partyCands == 1 & sumVotesOTH == 0)

replace office = "1" if office == "USP"
replace office = "2" if office == "GOV"
replace office = "3" if office == "USH"
replace office = "4" if office == "USS"

replace district = 1001 if office == "SOS"
replace district = 1002 if office == "ATG"
replace district = 1003 if office == "AUD"
replace district = 1004 if office == "TRE"
replace district = 1006 if office == "PSC"
replace district = 1007 if office == "CON"
replace district = 1008 if office == "LTG"
replace district = 1009 if office == "COMLAB"
replace district = 1010 if office == "COMTAX"
replace district = 1011 if office == "COMCORP"
replace district = 1012 if office == "COMAG"
replace district = 1013 if office == "COMLAND"
replace district = 1014 if office == "COMINS"
replace office = "7" if regexm(office, "[A-Z]+")

destring office, replace force

gen partyVotes = sumVotesDEM + sumVotesREP
egen totalVotes = rowtotal(sumVotes*)

duplicates tag state year office district, gen(d)
drop if d == 1 & geographyType != "state"
drop d

compress
save "stateResults.dta", replace

