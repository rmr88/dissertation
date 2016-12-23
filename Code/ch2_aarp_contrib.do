*********************************************
*  AARP Contribution Data from Opensecrets  *
*********************************************

//Robbie Richards, 11/14/16
//Data from https://www.opensecrets.org/orgs/recips.php?id=D000023726&type=P&state=&sort=A&cycle=2010 (chage the year at the end to get others)

cd "C:\Users\Robbie\Documents\dissertation\Data\CRP"

import delimited using "aarp_contribs.txt", varnames(1) clear

drop office state party
ren contrib amtAARP_
destring amtAARP_, ignore(",") replace

reshape wide amtAARP_, i(name) j(year)

outsheet delimited using "aarp_contribs_wide.txt", replace delim(tab)
//use this to enter ICPSR IDs manually for merging with rest of data.

/*
//After running the above and entering icpsrID column, do this:
import delimited using "aarp_contribs_wide.txt", clear varnames(1) case(preserve)
drop name
reshape long amtAARP_, i(icpsrID) j(year)
ren amtAARP_ amtAARP
drop if missing(amtAARP)
save "aarp_contribs.dta", replace
*/

