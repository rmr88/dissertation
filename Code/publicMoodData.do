*** Public Mood Data ***

cd "C:\Users\Robbie\Documents\dissertation\Data\PolicyAgendasProject\publicOpinion"

*Policy Moods
import delimited using "Policy_Moods.csv", delim(",") clear
drop if majortopic == 99
drop keyid majortopic subtopic
reshape wide mood, i(year congress) j(topic) str

save "..\mood.dta", replace

*Global Mood
import excel year mood using "globalMood.xls", clear cellrange(A3:B65)
merge 1:1 year using "..\mood.dta", nogen

replace year = year + mod(year, 2)
replace congress = (year - 1788) / 2 if missing(congress)
collapse mood*, by(congress year)

save "..\mood.dta", replace
