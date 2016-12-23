*******************************
*  Ch. 2 - Contribution Data  *
*******************************

//Robbie Richards, 8/16/16

clear all
odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=bonica;UID=stataread;PWD=851hiatus;") ///
	exec("SELECT recip.icpsrID2 AS icpsrID, recip.mcName, recip.cycle AS year, recip.bonica_rid AS rid, contrib.contributor_category_order AS cat, SUM(contrib.amount) AS totalAmount FROM bonica..contrib RIGHT JOIN bonica..recip ON contrib.bonica_rid = recip.bonica_rid AND contrib.cycle = recip.cycle WHERE SUBSTRING(contrib.contributor_category_order, 1, 1) = 'H' OR contrib.parent_organization_name = 'Blue Cross/Blue Shield' GROUP BY recip.bonica_rid, recip.icpsrID2, contrib.contributor_category_order, recip.cycle, recip.mcName")
drop if substr(cat, 1, 1) == "Q" | cat == "W02"
replace cat = "BCBS" if cat == "F09"

destring icpsrID, replace force
replace icpsrID = 20538 if mcName == "MATSUI, DORIS"
replace icpsrID = 20914 if mcName == "SCHOCK, AARON JON MR."
replace rid = "cand1041" if icpsrID == 20914

ren totalAmount amt
reshape wide amt, i(icpsrID rid year) j(cat) string

//foreach var of varlist amt* {
//	ren `var' `var'_
//}

drop if missing(icpsrID)
merge 1:1 icpsrID year using "C:\Users\Robbie\Documents\dissertation\Data\CRP\aarp_contribs.dta", nogen
replace year = ((year - 1788) / 2) + 1
ren year cong
replace mcName = substr(mcName, 1, strpos(mcName, ",")-1)
replace mcName = "CHRISTENSEN" if rid == "cand48942"
//reshape wide amt*, i(icpsrID rid) j(year)

//egen amt_missing = rowmiss(amt*)
foreach var of varlist amt* {
	replace `var' = 0 if missing(`var') //& amt_missing < 5
}

//drop amt_missing

save "C:\Users\Robbie\Documents\dissertation\Data\IssuePublics\contrib_data.dta", replace
