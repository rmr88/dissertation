*** Append PAP Data, Save as DTA ***

//Robbie Richards, 11/12/15

cd "C:\Users\Robbie\Documents\dissertation\Data\PolicyAgendasProject"

import delimited using "bills93-113.txt", clear varnames(1)
destring minor oldminor comc, replace force
save billsPAP.dta, replace

import delimited using "bills80-92.txt", clear varnames(1)
destring byreq month mult private year age cumhserv-majority party state, replace force
tostring plawnum, replace force
append using billsPAP.dta
save billsPAP.dta, replace
