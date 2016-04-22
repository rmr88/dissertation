***********************************************
*  CD-County Cross Referencing and Weighting  *
***********************************************

//Robbie Richards, 3/18/16


*** Setup ***

global shpDir "C:\Users\Robbie\Documents\dissertation\Data\cdShp"
global dataDir "C:\Users\Robbie\Documents\dissertation\Data\elections\stateResults"

use "$shpDir\output106\106cong.dta", clear
drop if FID_cd106 == -1 | STATENAME != STATENAM

egen countyArea = sum(shapeArea), by(STATENAM NHGISNAM)
gen countyWeight = shapeArea / countyArea

gen year = 1788 + ((106 - 1) * 2)

