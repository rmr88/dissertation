**********************************************************
*  Graphs of Ideology, Party Competition by Time Period  *
**********************************************************

//Robbie Richards, 6/1/16

*** Setup, Data ***

cd "C:\Users\Robbie\Documents\dissertation\Data"
use "allElectionData.dta", clear

keep if offSmall == 3 | offSmall == 4
keep if year >= 1870

replace mc_party = . if mc_party != 100 & mc_party != 200
gen dem = mc_party == 100
replace dem = . if missing(mc_party)

gen partyComp = 1 - abs(demScoreOff - 0.5)
gen south = (state_icpsr >= 40 & state_icpsr <= 49)
ren dwnom1 dwnom
replace dwnom = -dwnom


*** Graph Options ***

global grcopts = `"graphregion(color(white)) xcommon ycommon cols(2)"'
global hnote = `""Each dot is a district-election year observation. The party indicated by dot color is the party that won the" "seat that election, and the DW-NOMINATE score corresponds to the winner's roll call voting behavior" "in the next Congress. First-dimension DW-NOMINATE scores are reversed, so that -1 is conservative.""'
global snote = `""Each dot is a state-election year observation. The party indicated by dot color is the party that won the" "seat that election, and the DW-NOMINATE score corresponds to the winner's roll call voting behavior" "in the next Congress. First-dimension DW-NOMINATE scores are reversed, so that -1 is conservative.""'

global g1leg = `"leg(order(1 "Democrats" 2 "Republicans") region(lcolor(white) fcolor(gs15)) size(2.5))"'
global white = "graphregion(color(white))"
global ttl = "color(black) size(medsmall)"

global labs1 = `"xtitle(" ")"'
global labs2 = `"xtitle(" ") ytitle(" ")"'
global labs3 = `"xtitle("1st dim. DW-NOMINATE")"'
global labs4 = `"xtitle("1st dim. DW-NOMINATE") ytitle(" ")"'


*** House, Ranney ***

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue*0.8) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red*0.8) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1950 & year < 1990 & !south,  $white $g1leg ///
	name(nrth60h, replace) title("Non-South, 1952-1988", $ttl) $labs1 ytitle("Ranney Index")

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue*0.8) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red*0.8) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1950 & year < 1990 & south, leg(off) ///
	name(sth60h, replace) $white title("South, 1952-1988", $ttl) $labs2	

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue*0.8) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red*0.8) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1988 & !south, $white ytitle("Ranney Index") ///
	leg(off) name(nrth90h, replace) $labs3 title("Non-South, 1990-2010", $ttl)

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue*0.8) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red*0.8) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1988 & south, $white leg(off) ///
	name(sth90h, replace) $labs4 title("South, 1990-2010", $ttl)

grc1leg nrth60h sth60h nrth90h sth90h, $grcopts note($hnote)
graph export "C:\Users\Robbie\Documents\dissertation\Analysis\Figs\misc_fig1.png", replace height(800)

*** Senate, Ranney ***

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1950 & year < 1990 & !south, $white ytitle("Ranney Index") ///
	$g1leg name(nrth60s, replace) title("Non-South, 1952-1988", $ttl) $labs1

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1950 & year < 1990 & south, leg(off) ///
	name(sth60s, replace) $white title("South, 1952-1988", $ttl) $labs2

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1988 & !south, $white name(nrth90s, replace) ///
	leg(off) $labs3 ytitle("Ranney Index") title("Non-South, 1990-2010", $ttl)

twoway (scatter folded_ranney_4yrs dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter folded_ranney_4yrs dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess folded_ranney_4yrs dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1988 & south, $white name(sth90s, replace) ///
	leg(off) $labs4 title("South, 1990-2010", $ttl)

grc1leg nrth60s sth60s nrth90s sth90s, $grcopts note($snote)


*** House, PartyComp ***

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year < 1902 & !south, $white	$g1leg ytitle("PartyComp Index") ///
	name(nrth18h, replace) title("Non-South, 1870-1900", $ttl) $labs3

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year < 1902 & south, $labs4 leg(off) ///
	name(sth18h, replace) $white title("South, 1870-1900", $ttl)

grc1leg nrth18h sth18h, $grcopts note($hnote)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1900 & year < 1932 & !south, $white $g1leg ///
	name(nrth10h, replace) title("Non-South, 1902-1930", $ttl) $labs1 ytitle("PartyComp Index") 

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1900 & year < 1932 & south, leg(off) ///
	name(sth10h, replace) $white title("South, 1902-1930", $ttl) $labs2

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1930 & year < 1952 & !south, $white $labs3 ///
	leg(off) name(nrth30h, replace) title("Non-South, 1932-1950", $ttl) ytitle("PartyComp Index")

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1930 & year < 1952 & south, $white $labs4 ///
	name(sth30h, replace) leg(off) title("South, 1932-1950", $ttl)

grc1leg nrth10h sth10h nrth30h sth30h, $grcopts note($hnote)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1950 & year < 1990 & !south, $white $g1leg ///
	name(nrth60h, replace) title("Non-South, 1952-1988", $ttl) $labs1 ytitle("PartyComp Index")

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1950 & year < 1990 & south, $white $labs2 ///
	name(sth60h, replace) leg(off) title("South, 1952-1988", $ttl)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1988 & !south, $white $labs3 ytitle("PartyComp Index") ///
	name(nrth90h, replace) leg(off) title("Non-South, 1990-2010", $ttl)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1988 & south, $white $labs4 ///
	name(sth90h, replace) leg(off) title("South, 1990-2010", $ttl)

grc1leg nrth60h sth60h nrth90h sth90h, $grcopts note($hnote)
	

*** Senate, PartyComp ***

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1900 & year < 1932 & !south, $white $g1leg ///
	name(nrth10s, replace) title("Non-South, 1912-1930", $ttl) $labs1 ytitle("PartyComp Index")

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1900 & year < 1932 & south, $white $labs2 ///
	name(sth10s, replace) leg(off) title("South, 1912-1930", $ttl)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1930 & year < 1952 & !south, $white ///
	name(nrth30s, replace) title("Non-South, 1932-1950", $ttl) $labs3 ytitle("PartyComp Index")

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1930 & year < 1952 & south, $white $labs4 ///
	name(sth30s, replace) leg(off) title("South, 1932-1950", $ttl)

grc1leg nrth10s sth10s nrth30s sth30s, $grcopts note($snote)
	
twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1950 & year < 1990 & !south, $white $g1leg ///
	name(nrth60s, replace) title("Non-South, 1952-1988", $ttl) $labs1 ytitle("PartyComp Index")

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1950 & year < 1990 & south, $white $labs2 ///
	name(sth60s, replace) leg(off) title("South, 1952-1988", $ttl)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1988 & !south, $white $labs3 ytitle("PartyComp Index") ///
	name(nrth90s, replace) leg(off) title("Non-South, 1990-2010", $ttl)

twoway (scatter partyComp dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter partyComp dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess partyComp dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1988 & south, $white $labs4 ///
	name(sth90s, replace) leg(off)title("South, 1990-2010", $ttl)

grc1leg nrth60s sth60s nrth90s sth90s, $grcopts note($snote)
	
	
*** House, HVD ***

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1950 & year < 1990 & !south,  $white $g1leg ///
	name(nrth60h, replace) title("Non-South, 1972-1988", $ttl) $labs1 ytitle("HVD Index")

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1950 & year < 1990 & south, leg(off) ///
	name(sth60h, replace) $white title("South, 1972-1988", $ttl) $labs2	

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1988 & year < 2012 & !south, $white leg(off) ///
	name(nrth90h, replace) $labs3 title("Non-South, 1990-2010", $ttl) ytitle("HVD Index")

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 3 & year > 1988 & year < 2012 & south, $white leg(off) ///
	name(sth90h, replace) $labs4 title("South, 1990-2010", $ttl)

grc1leg nrth60h sth60h nrth90h sth90h, $grcopts note($hnote)


*** Senate, HVD ***

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1950 & year < 1990 & !south,  $white $g1leg ///
	name(nrth60s, replace) title("Non-South, 1972-1988", $ttl) $labs1 ytitle("HVD Index")

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1950 & year < 1990 & south, leg(off) ///
	name(sth60s, replace) $white title("South, 1972-1988", $ttl) $labs2	

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1988 & year < 2012 & !south, $white leg(off) ///
	name(nrth90s, replace) $labs3 title("Non-South, 1990-2010", $ttl) ytitle("HVD Index")

twoway (scatter hvd_4yr dwnom if dem == 1, mcolor(blue) msize(small)) ///
	(scatter hvd_4yr dwnom if dem == 0, mcolor(red) msize(small)) ///
	(lowess hvd_4yr dwnom, lcolor(black) lwidth(medthick)) ///
	if offSmall == 4 & year > 1988 & year < 2012 & south, $white leg(off) ///
	name(sth90s, replace) $labs4 title("South, 1990-2010", $ttl)

grc1leg nrth60s sth60s nrth90s sth90s, $grcopts note($snote)

