clear all

set seed 1523

set obs 10000
gen normal = rnormal()
gen bimodal = normal + 2 if mod(_n, 2) == 1
replace bimodal = normal - 2 if missing(bimodal)
gen normal_shift = normal + 2
gen bimodal_shift = bimodal + 2
gen bimodal_skewed = bimodal + 4 if mod(_n, 4) == 2
replace bimodal_skewed = bimodal if missing(bimodal_skewed)
twoway (kdensity bimodal_skewed if bimodal_skewed >= 0, lwidth(none) fcolor(red) recast(area)) ///
	(kdensity bimodal_skewed if bimodal_skewed < 0, lwidth(none) fcolor(blue) recast(area))
	

