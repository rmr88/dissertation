***************************
*  CD and County Mapping  *
***************************

//Robbie Richards, 4/4/16

//ssc install shp2dta
cd "C:\Users\Robbie\Documents\dissertation\Data\cdShp"

//need to deal with cases where SHAPE_AREA is not present
quietly forvalues cong = 97/101 { //42/112
	noi: di "Processing Congress `cong'..."
	shp2dta using "output`cong'\\`cong'cong_identified.shp", ///
		replace genid(id) data("output`cong'\data`cong'.dta") ///
		coord("output`cong'\coord`cong'.dta")

	use "output`cong'\data`cong'.dta", clear

	destring DECADE DISTRICT STARTCONG ENDCONG, replace
	cap destring ICPSRST, replace
	cap destring ICPSRCTY, replace
	replace ICPSRSTI = ICPSRST if !missing(ICPSRST) & ICPSRSTI == 0
	replace ICPSRCTYI = ICPSRCTY if !missing(ICPSRCTY) & ICPSRCTYI == 0
	
	drop if DISTRICT == .
	capture confirm variable SHAPE_AREA
	if (_rc > 0) egen countyArea = total(shapeArea), by(ICPSRSTI ICPSRCTYI)
	else ren SHAPE_AREA countyArea
	
	keep FID_US_cou DECADE NHGISNAM NHGISST NHGISCTY STATENAM ///
		ICPSRSTI ICPSRCTYI STATE COUNTY PID countyArea FID_cd`cong' ///
		ID DISTRICT STARTCONG ENDCONG shapeArea id

	ren FID_US_cou fid_county
	ren DECADE decade
	ren NHGISNAM county_name
	ren NHGISST state_nhgis
	ren NHGISCTY county_nhgis
	ren STATENAM state_name
	ren ICPSRSTI state_icpsr
	ren ICPSRCTYI county_icpsr
	ren STATE state_fips
	ren COUNTY county_fips
	ren PID gis_id
	ren FID_cd`cong' fid_cd
	ren ID long_state_id
	ren DISTRICT district
	ren STARTCONG startCong
	ren ENDCONG endCong
	ren shapeArea countyCDarea
	ren id stata_id

	gen areaProp = countyCDarea / countyArea
	bys state_icpsr county_icpsr: gen cdsInCounty = _N
	gen cong = `cong'
	gen year = 1788 + (2 * (cong - 1))
	
	order state_icpsr state_name county_icpsr county_name district ///
		year cong cdsInCounty areaProp countyCDarea countyArea decade, first
		
	save "output`cong'\data`cong'.dta", replace
}

use "C:\Users\Robbie\Documents\dissertation\Data\elections\ICPSRfedResults\presData.dta", clear
forvalues cong = 42/101 {
	di "Merging data for Congress `cong'"
	merge m:m state_icpsr county_icpsr year using "output`cong'\data`cong'.dta", ///
		update nogen
}

cd "C:\Users\Robbie\Documents\dissertation\Data\elections"
save "presByCDraw.dta", replace

use "presByCDraw.dta", clear

replace state_icpsr = 81 if state_name == "Alaska" & state_icpsr == 0
replace state_icpsr = 63 if state_name == "Idaho" & state_icpsr == 0
replace state_icpsr = 23 if state_name == "Michigan" & state_icpsr == 0
replace state_icpsr = 33 if state_name == "Minnesota" & state_icpsr == 0
replace state_icpsr = 35 if state_name == "Nebraska" & state_icpsr == 0
replace state_icpsr = 37 if state_name == "South Dakota" & state_icpsr == 0
replace state_icpsr = 40 if state_name == "Virginia" & state_icpsr == 0
replace state_icpsr = 32 if state_name == "Kansas" & state_icpsr == 0
replace state_icpsr = 36 if state_name == "North Dakota" & state_icpsr == 0
replace state_icpsr = 49 if state_name == "Texas" & state_icpsr == 0
replace state_icpsr = 68 if state_name == "Wyoming" & state_icpsr == 0

collapse (sum) countyCDarea areaProp (mean) sumVotes* totalVotes ///
	partyVotes countyArea, by(county_name state_icpsr year county_icpsr ///
	state_name district cong cdsInCounty) //takes care of at-large districts that were split for some reason in ArcGIS
duplicates tag state_icpsr county_icpsr district year, gen(d)
drop if d > 0

egen distID = group(state_icpsr county_icpsr district), missing
xtset distID year
foreach var of varlist sumVotes* totalVotes partyVotes {
	replace `var' = l2.`var' if missing(`var') & !missing(l2.`var')
}
drop d distID

replace areaProp = 1 if areaProp > 0.99 & !missing(areaProp)
replace areaProp = 0 if areaProp < 0.01

foreach var of varlist sumVotes* totalVotes partyVotes {
	replace `var' = `var' * areaProp
}

collapse (sum) sumVotes* totalVotes partyVotes, ///
	by(state_icpsr state_name district year cong)

label values sumVotes* totalVotes partyVotes .
compress
drop if totalVotes == 0 | district == .

save "presByCD.dta", replace

