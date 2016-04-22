global path "C:\Users\Robbie\Documents\dissertation\Data\VoteView"

infix ///
		int cong 1-4 ///
		long idno 5-10 ///
		byte state_icpsr 11-13 ///
		byte district 14-16 ///
		str8 state_n 17-24 ///
		long mc_party 25-29 ///
		str12 mc_name 30-41 ///
		double dwnom1_tv 42-48 ///
		double dwnom2_tv 49-56 ///
		double loglike 57-67 ///
		int numVotes 68-71 ///
		int numErrors 72-76 ///
		double gmp 77-83 ///
	using "$path\uss_timevarying.DAT", clear

save "$path\dwnom_tv.dta", replace

infix ///
		int cong 1-4 ///
		long idno 5-10 ///
		byte state_icpsr 11-13 ///
		byte district 14-16 ///
		str8 state_n 17-24 ///
		long mc_party 25-29 ///
		str12 mc_name 30-41 ///
		double dwnom1_tv 42-48 ///
		double dwnom2_tv 49-56 ///
		double loglike 57-67 ///
		int numVotes 68-71 ///
		int numErrors 72-76 ///
		double gmp 77-83 ///
	using "$path\ush_timevarying.DAT", clear
	
drop if state_n == "USA"
append using "$path\dwnom_tv.dta"

save "$path\dwnom_tv.dta", replace

