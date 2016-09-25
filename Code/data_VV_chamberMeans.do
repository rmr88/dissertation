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
