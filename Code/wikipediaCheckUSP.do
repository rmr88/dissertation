*** Wikipedia Data (for check) ***

//Robbie Richards, 3/1/16

import excel using "C:\Users\Robbie\Documents\dissertation\Data\elections\wikipediaUSPcheck.xlsx", ///
	firstrow clear
gen office = "usp"
save "C:\Users\Robbie\Documents\dissertation\Data\elections\wikipediaUSPcheck.dta", replace
