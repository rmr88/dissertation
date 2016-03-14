*** Precinct Data to Stata ***

//Robbie Richards, 2/29/16

cd "C:\Users\Robbie\Documents\dissertation\Data\elections\EDAD"

*USP and USH by CD
clear all
odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=dissertData;UID=stataread;PWD=851hiatus;") ///
	exec("SELECT elections.state, elections.year, elections.cd AS cd1, elections.cd2, elections.cd3, elections.cd4, elections.cd5, elections.g_USP_dv, elections.g_USP_rv, elections.g_USH_dv AS g_USH_dv1, elections.g_USH_rv AS g_USH_rv1, elections.g_USH_dv2, elections.g_USH_rv2, elections.g_USH_dv3, elections.g_USH_rv3, elections.g_USH_dv4, elections.g_USH_rv4, elections.g_USH_dv5, elections.g_USH_rv5, elections.g_USH_d2v, elections.g_USH_r2v, elections.g_USH_r3v FROM dissertData..elections")
	
ren g_USP_dv g_USP_dv1
ren g_USP_rv g_USP_rv1
gen n = _n

reshape long cd g_USH_dv g_USH_rv g_USP_dv g_USP_rv, ///
	i(state year n g_USH_d2v g_USH_r2v g_USH_r3v) j(d)

drop if missing(cd)
drop d n

collapse (sum) g_*, by(state year cd)
save "heda_cd.dta", replace

*Other offices, statewide
clear all
odbc load, connectionstring("DRIVER={SQL Server Native Client 11.0};SERVER=ROBBIE-HP\SQLEXPRESS;DSN=dissertData;UID=stataread;PWD=851hiatus;") ///
	exec("SELECT elections.state, elections.year, elections.cd, elections.county, elections.precinct, elections.precinct_code, elections.sd, elections.county_code, elections.ld, elections.svprec, elections.svprec_key, elections.town, elections.vtd, elections.ed, elections.ward, elections.fips, elections.ld_code, elections.ld_name, elections.mcd, elections.mcd_code, elections.countyprecinct_code, elections.geo_code, elections.small, elections.county_name, elections.fips_cnty, elections.fips_pct, elections.precinct_name, elections.cd2010, elections.g_GOV_dv AS gov_dem, elections.g_GOV_rv AS gov_rep, elections.g_USS_dv AS uss_dem, elections.g_USS_rv AS uss_rep, elections.g_USP_dv AS usp_dem, elections.g_USP_rv AS usp_rep, elections.g_LTG_dv AS ltg_dem, elections.g_LTG_rv AS ltg_rep, elections.g_ATG_dv AS atg_dem, elections.g_ATG_rv AS atg_rep, elections.g_SOS_dv AS sos_dem, elections.g_SOS_rv AS sos_rep FROM dissertData..elections")

drop if state == "AZ" & precinct == "Election Total"

drop if state == "CA" & strpos(svprec, "TOT") > 0
duplicates drop county_code svprec svprec_key usp_dem ///
	usp_rep year if state == "CA", force
drop if state == "CA" & svprec == `""NULL""'

drop if state == "IA" & year == 2004

foreach off in gov usp uss ltg atg sos {
	replace `off'_rep = `off'_rep / 2 if state == "KS" & ///
		year == 2012 & county == "Johnson"
	replace `off'_dem = `off'_dem / 2 if state == "KS" & ///
		year == 2012 & county == "Johnson"
}

foreach off in gov usp uss ltg atg sos {
	replace `off'_rep = `off'_rep / 2 if state == "KY" & ///
		year == 2008 & (county == "ADAIR" | county == "BELL" ///
		| county == "BARREN" | county == "BOYD")
	replace `off'_dem = `off'_dem / 2 if state == "KY" & ///
		year == 2008 & (county == "ADAIR" | county == "BELL" ///
		| county == "BARREN" | county == "BOYD")
}

drop if precinct == "Statewide Totals" & state == "MN"

gen temp = usp_dem
replace usp_dem = usp_rep if state == "NH" & year == 2008 ///
	& (county == "Strafford" | county == "Sullivan")
replace usp_rep = temp if state == "NH" & year == 2008 ///
	& (county == "Strafford" | county == "Sullivan")
drop temp

duplicates drop county precinct usp_dem usp_rep if state == "NM" ///
	& year == 2000, force
duplicates drop county precinct usp_dem usp_rep if state == "NM" ///
	& year == 2004, force
duplicates drop county precinct usp_dem usp_rep if state == "NM" ///
	& year == 2008, force

foreach var of varlist usp_* uss_* {
	bys county: egen temp = max(`var') if state == "SC" & year == 2004
	replace precinct = "County" if state == "SC" & year == 2004 ///
		 & precinct == "County Totals" & temp != `var'
	replace `var' = temp if state == "SC" & year == 2004 ///
		& precinct == "County"
	drop temp
}
gen a = precinct == "County"
by county: egen b = max(a)
by county: egen ctyTot = total(usp_dem) if state == "SC" & ///
	year == 2004 & precinct != "County Totals" & precinct != "County"
by county: egen ctyTot2 = max(ctyTot) if state == "SC" & ///
	year == 2004
replace usp_dem = ctyTot2 if usp_dem != ctyTot2 & state == "SC" & ///
	year == 2004 & (precinct == "County Totals" | precinct == "County")

drop if precinct == "County Totals" & state == "SC" & year == 2004
drop if state == "SC" & year == 2004 & (county == "UNION" | county == "YORK" ///
	| county == "SUMTER" | county == "SPARTANBURG" | county == "WILLIAMSBURG")
append using "C:\Users\Robbie\Documents\dissertation\Data\elections\stateResults\SC\stub_SC.dta"

replace town = subinstr(town, `"""', "", .)
merge m:1 state year town using "C:\Users\Robbie\Documents\dissertation\Data\elections\stateResults\CT\stub_CT.dta", ///
	nogen update



collapse (sum) *_rep *_dem, by(state year)
reshape long @_rep @_dem, i(state year) j(office) string

ren _dem sumVotesDem
ren _rep sumVotesRep

gen partyVotes = sumVotesDem + sumVotesRep
drop if partyVotes == 0
gen oneMajorCand = (sumVotesDem == 0 | missing(sumVotesDem))
replace oneMajorCand = 1 if sumVotesRep == 0 | missing(sumVotesRep)

*Check USP votes against Wikipedia
merge 1:1 state year office using ///
	"C:\Users\Robbie\Documents\dissertation\Data\elections\wikipediaUSPcheck.dta", ///
	nogen keep(1 3)

gen demDiff = sumVotesDem - wikiVotesDem
gen repDiff = sumVotesRep - wikiVotesRep

/*
sum demDiff repDiff, d
hist demDiff, freq discrete
hist repDiff, freq discrete
*/

gen demDiffPerc = abs(demDiff / sumVotesDem)
gen repDiffPerc = abs(repDiff / sumVotesRep)

/*
browse state year sumVotesRep wikiVotesRep repDiffPerc sumVotesDem ///
	wikiVotesDem demDiffPerc if (demDiffPerc > 0.005 | repDiffPerc > 0.005) ///
	& office == "usp" //gives 41 state-years
*/

