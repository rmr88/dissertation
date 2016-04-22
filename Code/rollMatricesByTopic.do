*** Get Roll Calls, Turn into Matrix ***

cd "C:\Users\Robbie\Documents\dissertation\Data\VoteView\matrices"

clear all
local topic = 3
odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=dissertData;UID=stataread;PWD=851hiatus;") ///
	exec("SELECT cong, legisid, rollid, vote FROM dissertData..rollVotes WHERE roll_major = `topic' AND legisid IS NOT NULL")

ren vote _
replace rollid = strtrim(subinstr(rollid, "-", "_", .))
destring legisid, replace

qui levelsof cong, local(congs)
foreach cong of local congs {
	preserve //Senate:
		keep if cong == `cong' & substr(rollid, 1, 1) == "s"
		
		if (_N > 0) {
			drop cong
			qui reshape wide _, i(legisid) j(rollid) string
			
			if (`cong' <= 87) gen first = 1 if legisid == 405253 //Carl Hayden
			else if (`cong' > 87 & `cong' < 111) gen first = 1 if legisid == 300059 //Edward Kennedy
			else gen first = 1 if legisid == 300011 // Barbara Boxer
			sort first
			drop first
			
			export delimited using "health_rolls_s`cong'.txt", ///
				delim(tab) replace
		}
	restore
	
	preserve //House:
		keep if cong == `cong' & substr(rollid, 1, 1) == "h"
		
		if (_N > 0) {
			drop cong
			qui reshape wide _, i(legisid) j(rollid) string
			
			if (`cong' <= 91) gen first = 1 if legisid == 407756 //Wilbur Mills
			else gen first = 1 if legisid == 400333 //Charles Rangel
			sort first
			drop first
			
			export delimited using "health_rolls_h`cong'.txt", ///
				delim(tab) replace
		}
	restore
}
