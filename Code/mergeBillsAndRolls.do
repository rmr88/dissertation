
cd "C:\Users\Robbie\Documents\dissertation\Data"

*Merge PAP Bill and Roll Call Topic Data
import delimited using "PolicyAgendasProject\Roll_Call_Votes.txt", ///
	clear delim(tab)
gen billid = string(cong) + "-" + bill

merge m:1 billid using "PolicyAgendasProject\billsPAP.dta", ///
	keepusing(major minor) keep(1 3)

keep billid chamber rccount sesscount cong year majortopic ///
	subtopiccode major minor

ren majortopic roll_major
ren subtopiccode roll_minor
ren major bill_major
ren minor bill_minor

gen rollid = "h-" if chamber == 1
replace rollid = "s-" if chamber == 2
replace rollid = rollid + string(cong) + "-" + string(sesscount) ///
	+ "-" + string(year) if cong >= 101
replace rollid = rollid + string(cong) + "-" + string(rccount) ///
	+ "-" + string(year) if cong < 101
drop chamber rccount year sesscount

duplicates tag rollid, gen(d)
drop if d
drop d

compress
save "PolicyAgendasProject\rollTopics.dta", replace

*Read in Roll Call Votes, Merge Topic Data
import delimited using "GovTrack\rolls.txt", clear delim(tab)
ren v1 rollid
ren v2 legisid
ren v3 vote

replace vote = "1" if vote == "+" | vote == "YEA"
replace vote = "6" if vote == "-"
replace vote = "8" if vote == "P"
replace vote = "9" if vote == "0"
destring vote, replace force

merge m:1 rollid using "PolicyAgendasProject\rollTopics.dta"

export delimited cong rollid legisid billid vote roll_* bill_* ///
	using "rollVotes.txt", delim(tab) replace

