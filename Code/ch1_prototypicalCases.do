***********************************************
*  Prototypical Roll Call Votes Data (Ch. 1)  *
***********************************************

//Robbie Richards, 3/7/17


*** Setup ***

cd "C:\Users\Robbie\Documents\dissertation\Data\VoteView\roll_dictionaries"

*Read in roll call list
import delimited using "dictionaries.txt", clear delim(tab)
ren chamber hs

*Merge with cutpoints file
merge 1:1 cong rcnum hs using "HC01113_CUT33_PRE_DATES.DTA"
drop if cong < 41
keep cong rcnum bill info mid1 mid2 clangle
save "cutpoints_41-106.dta", replace

joinby cong using "dwnom_predictions.dta"


*** Predictions ***

gen cutpoint = ((dwnom2 - mid2) / clangle) + mid1
gen vote_hat_actual = dwnom > cutpoint & !missing(cutpoint) ///
	& !missing(dwnom) //predicted votes are conservative position or not, NOT yea or nay
gen vote_hat_75 = dwnom_hat_75 > cutpoint & !missing(cutpoint) ///
	& !missing(dwnom_hat_75)
gen vote_hat_80 = dwnom_hat_80 > cutpoint & !missing(cutpoint) ///
	& !missing(dwnom_hat_80)
gen vote_hat_below_70 = dwnom_hat_below_70 > cutpoint ///
	& !missing(cutpoint) & !missing(dwnom_hat_below_70)


*** Cases ***
/*
Race:
Civil Rights Act- HR 7152 (88th)
Voting Rights Act- S 1564 (89th)
Voting Rights Act Reauth ***
	HR 9 (109th)
	S 1992 (97th)

Health:
Medicare (Social Security Amendments, 1965)- HR 6675 (89th)
Medicare Catastrophic- HR 2470 (100th)
MMA- HR 1 (108th) ***
ACA- HR 3590 (111th)- roll 165

Guns:
Gun Control Act- HR 17735 (90th)
Firearm Owners Protection Act- S. 49 (99th) ***
Brady Handgun Violence Prevention Act- HR 1025 (103rd)
Assault Weapons Ban- HR 3355 (103rd) ***
Gun liability law from gun paper ***
	HR 1036 (108th)
	S 397 (109th)

Abortion?
*/

