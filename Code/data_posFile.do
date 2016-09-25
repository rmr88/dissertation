***********************************************
*  Provider of Services File - Address Export *
***********************************************

//Robbie Richards, 8/30/16

cd "C:\Users\Robbie\Documents\dissertation\Data\IssuePublics"

import delimited using "POS_CLIA_DEC10.csv", delim(",") clear
drop in 1
keep prov3225 prov3230 prov2720 prov2905 fipstate fipcnty ssamsacd
save "pos10.dta", replace

import delimited using "POS_OTHER_DEC10.csv", delim(",") clear
drop in 1
keep prov3225 prov3230 prov2720 prov2905 fipstate fipcnty ssamsacd
append using "pos10.dta"
save "pos10.dta", replace

export delimited using "pos10.txt", delim(tab) replace
