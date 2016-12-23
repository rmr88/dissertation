*********************
*  Vote Level Data  *
*********************

//Robbie Richards, 10/6/16


*** Bills ***

cd "C:\Users\Robbie\Documents\dissertation\Data\PolicyAgendasProject"

import delimited using "billsPAP.txt", clear delim(tab) varnames(1)

keep if major == 3 & cong >= 108 & cong <= 112
keep billnum billtype cong minor passh passs plaw

save "healthBillsList.dta", replace


*** Votes ***

import delimited using "healthBillVotes.txt", clear delim(tab) varnames(1)

replace billtype = strupper(billtype)
replace billtype = "HR" if billtype == "H"

merge m:1 cong billtype billnum using "healthBillsList.dta", nogen keep(3)

ren id govTrackID
drop if strpos(result, "SENATE") > 0
drop result

save "healthVotesList.dta", replace

