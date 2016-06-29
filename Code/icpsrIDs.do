*** ICPSR IDs ***

//Robbie Richards, 6/2/16

infix ///
	cong 1-4 ///
	icpsrID 5-11 ///
	state_icpsr 12-13 ///
	district 14-16 ///
	str state_n 17-24 ///
	pty 25-29 ///
	str nameLast 30-40 ///
	str nameMC 41-66 ///
	using "mcIDs_ICPSR_house.txt", clear
save "icpsrIDs.dta", replace

infix ///
	cong 1-4 ///
	icpsrID 5-11 ///
	state_icpsr 12-13 ///
	district 14-16 ///
	str state_n 17-24 ///
	pty 25-29 ///
	str nameLast 30-40 ///
	str nameMC 41-66 ///
	using "mcIDs_ICPSR_senate.txt", clear
append using "icpsrIDs.dta"

gen party = "R" if pty == 200
replace party = "D" if pty == 100
replace party = "I" if pty == 328

preserve
	duplicates drop
	replace nameLast = substr(nameLast, 1, 9)

	collapse (firstnm) nameLast nameMC pty party district ///
		(max) max_cong=cong (min) min_cong=cong, ///
		by(icpsrID state_icpsr state_n)
	drop if max_cong < 102

	save "icpsrIDs.dta", replace
restore

drop if cong < 108 | cong > 112
drop if district == 0

save "icpsrIDs_108-112.dta", replace

