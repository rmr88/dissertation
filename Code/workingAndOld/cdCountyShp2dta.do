cd "C:\Users\Robbie\Documents\dissertation\Data\cdShp\output106"
shp2dta using "106cong_identified.shp", data("106cong.dta") coord("106coord.dta") genid(id) replace
use "106cong.dta", clear

