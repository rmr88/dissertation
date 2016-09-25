*** National Presidential Data ***

//Robbie Richards, 8/29/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections"
import delimited using "uspNational.txt", clear delim(tab)
gen demPerc = demvotes / partyvotes
save "uspNational.dta", replace
