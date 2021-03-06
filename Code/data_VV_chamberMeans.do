*** Chamber Means NOMINATE Data to Stata ***

//Robbie Richards, 7/5/16

cd "C:\Users\Robbie\Documents\dissertation\Data\VoteView"
import delimited cong numLeg numLegMaj numLegMin ptyMaj mean1_chamber ///
	mean2_chamber mean1_maj mean2_maj mean1_min mean2_min numRolls ///
	ptyMin mean1_win mean2_win using "winningPoliciesHouse.txt", ///
	clear delim(tab)
order cong numLeg mean?_chamber mean?_win ptyMaj numLegMaj mean?_maj ///
	ptyMin numLegMin mean?_min, first
save "chamberMeans.dta", replace

infix ///
		int cong 1-4 ///
		int nTotal 5-8 ///
		float med1Chamber 9-15 ///
		float med2Chamber 16-22 ///
		int party 23-28 ///
		int nParty 29-36 ///
		str23 partyName 37-60 ///
		int nScored 61-64 ///
		float med1Party 65-71 ///
		float med2Party 72-77 ///
	using "hmedians_DWNOM_1-113.txt", clear
drop if missing(cong)
keep cong med1Party party
ren party party2
save "partyMedians.dta"
