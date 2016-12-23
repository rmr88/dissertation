***********************
*  District Analysis  *
***********************

//Robbie Richards, 11/29/16


*** Setup ***

global cd111 = "C:\Users\Robbie\Documents\dissertation\Data\cdShp\census_cd111"
global cd108 = "C:\Users\Robbie\Documents\dissertation\Data\cdShp\census_cd108"

/*
shp2dta using "$cd111\tl_2010_us_cd111.shp", replace genid(id111) ///
	data("$cd111\cd111.dta") coord("$cd111\coord111.dta")

use "$cd111\cd111.dta", clear
keep STATEFP10 CD111FP id111
ren STATEFP10 fips
ren CD111FP district
destring fips district, replace
replace district = 1 if district == 0
save "$cd111\cd111.dta", replace

use "$cd111\coord111.dta", clear
drop if _ID == 50 | _ID == 160 | _ID == 301 | _ID == 306
save "$cd111\coord111.dta", replace

shp2dta using "$cd108\tl_2010_us_cd108.shp", replace genid(id108) ///
	data("$cd108\cd108.dta") coord("$cd108\coord108.dta")

use "$cd108\cd108.dta", clear
keep STATEFP00 CD108FP id108
ren STATEFP00 fips
ren CD108FP district
destring fips district, replace
replace district = 1 if district == 0
save "$cd108\cd108.dta", replace

use "$cd108\coord108.dta", clear
drop if _ID == 158 | _ID == 312 | _ID == 315 | _ID == 51
save "$cd108\coord108.dta", replace
*/

use "C:\Users\Robbie\Documents\dissertation\Data\districtData.dta", clear
merge m:1 fips district using "$cd111\cd111.dta", nogen keep(1 3)
merge m:1 fips district using "$cd108\cd108.dta", nogen keep(1 3)

gen percSenior = pop65to74 + popOver75
replace pop = pop - popUnder5 - pop5to17
gen phys_perc = 100 * count_corrected / pop
replace unins_rate = unins_rate * 100

factor healthChip10 healthACA10 healthChip08 healthMand08 healthCost06 healthSatis06 healthEmplSpons06 healthPers06, factors(1)
rotate
predict healthOpinion

cd "C:\Users\Robbie\Documents\dissertation\Analysis"


*** Maps ***

spmap unins_rate if cong == 111 using "$cd111\coord111.dta", id(id111) ///
	leg(order(5 "Top 25%" 4 "" 3 "" 2 "Bottom 25%"))

foreach var of varlist unins_rate phys_perc percSenior healthOpinion {
	spmap `var' if cong == 111 using "$cd111\coord111.dta", id(id111) ///
		leg(order(5 "Top 25%" 4 "" 3 "" 2 "Bottom 25%"))
	qui graph export "Figs\ch2\maps\\`var'111.png", replace height(800)
}

//spmap unins_rate if cong == 108 using "$cd108\coord108.dta", id(id108)

