****************************
*  Ch. 2 - Roll Call Data  *
****************************

//Robbie Richards, 8/17/16
//TODO: figure out how to do cosponsorships as well (NOMINATE-like calculations?)

cd "C:\Users\Robbie\Documents\dissertation\Data"

cap erase "VoteView\healthWNOM.dta"
forvalues cong = 108/112 {
	import delimited using "VoteView\results\health_rolls_h`cong'.txt", ///
		delim(tab) clear
	keep id coord1d coord2d

	ren coord1d wnom1_`cong'
	ren coord2d wnom2_`cong'
	
	cap merge 1:1 id using "VoteView\healthWNOM.dta", nogen
	save "VoteView\healthWNOM.dta", replace
}
destring wnom*, replace force
ren id govTrackID

merge 1:m govTrackID using "working\govTrackIDs.dta", nogen keep(3)


save "VoteView\healthWNOM.dta", replace
