//DEPRECATED//

*********************
*  Vote Level Data  *
*********************

//Robbie Richards, 10/6/16


*** Individual Legislator-Votes ***

cd "C:\Users\Robbie\Documents\dissertation\Data"

cap erase "GovTrack\votesLong.dta"

forvalues cong = 108/112 {
	import delimited using "VoteView\matrices\health_rolls_h`cong'.txt", ///
		clear delim(tab) varnames(1)
		
	reshape long _h, i(legisid) j(info) string
	ren _h vote
	
	replace info = strtrim(subinstr(info, "_", " ", .)) 
	gen cong = word(info, 1)
	gen year = word(info, 3)
	gen roll_num = word(info, 2)
	drop info
	destring cong year roll_num, replace
	
	cap append using "GovTrack\votesLong.dta"
	save "GovTrack\votesLong.dta", replace
}


*** Bill and Vote Data ***

use "PolicyAgendasProject\rollCalls.dta", clear
keep if chamber == 1 & cong >= 108 & cong <= 112
keep rccount sesscount year bill cong subtopiccode
ren rccount roll_num
merge 1:m roll_num year cong using "GovTrack\votesLong.dta"

