*******************************************
*  Checking Outliers and Functional Form  *
*******************************************

//Robbie Richards, 1/20/17

use "C:\Users\Robbie\Documents\dissertation\Data\ch2_analysisData.dta", clear
encode vote_group, gen(grp)


*** Outliers ***

//Used scatterplots of the IV with agree_dem to determine outlier thresholds
forvalues n = 1/6 {
	local lab : label grp `n'
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n'
	estimates store full, title("All Data")
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n' & amtAARP < 1.5 //change the last logic item to the appropriate variable, outlier threshold value
	estimates store part, title("Outliers Removed")
	
	estimates table full part, b(%5.3f) star title("`lab'")
}

/*
Outlier Notes:
- Physician %: Outliers (> 1.0) do not affect results
- Uninsured Rate: No real outliers
- Senior %: No real outliers; excluding top observations (> 20.0) doesn't change results
- Industry $: Outliers (> 375) don't make much difference
- Provider $: Outliers (> 600) don't make much difference
- BCBS $: no outliers
- AARP $: Outliers (> 1.5) don't make much difference; this variable is very skewed, with only a few non-zero observations
*/


*** Functional Form ***

/*
gen contribAARP = amtAARP > 0 if !missing(amtAARP)
gen contribBCBS = amtBCBS > 0 if !missing(amtBCBS)
gen contribH01 = amtH01 > 0 if !missing(amtH01)
gen contribInd = amt > 0 if !missing(amt)

sum amtBCBS, d
local p90 = r(p90)
gen amtBCBS_trim = amtBCBS
replace amtBCBS_trim = `p90' if amtBCBS > `p90'

sum amtH01, d
local p90 = r(p90)
gen amtH01_trim = amtH01
replace amtH01_trim = `p90' if amtH01 > `p90'

sum amt, d
local p90 = r(p90)
gen amt_trim = amt
replace amt_trim = `p90' if amt > `p90'
*/

forvalues n = 1/6 {
	local lab : label grp `n'
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n'
	estimates store regular, title("Regular")
	
	qui logit agree_dem amt_trim amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n'
	estimates store trimmed, title("Trimmed")
	
	qui logit agree_dem contribInd amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior unins_rate phys_perc raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n'
	estimates store dummy, title("Dummy")
	
	estimates table regular trimmed dummy, b(%5.3f) star title("`lab'")
}

/*
Functinal Form Notes:
- AARP $: functional form inconsequential
- BCBS $: some changes in the SGR and 108th models, but not other models
- Provider $: not many significant changes (the dummy is useless because most are 1)
- Industry $: Some changes in MMA, 108th, and HEALTH Act, but not other models; again, dummy is not too useful (most = 1).
*/


*** Interactions ***

forvalues n = 1/6 {
	local lab : label grp `n'
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior phys_perc unins_rate raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n'
	estimates store regular, title("Regular")
	
	qui logit agree_dem amt amtH01 amtBCBS amtAARP healthOpinion IP_voter ///
		percSenior c.phys_perc##c.unins_rate raceWhite raceHisp educHS medianIncome ///
		partyLineVote i.party birthYear i.rollnum if grp == `n'
	estimates store interaction, title("Interactions")
	
	estimates table regular interaction, b(%5.3f) star title("`lab'")
}

