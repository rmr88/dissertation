****************************
*  Chapter 3: ACA Opinion  *
****************************

//Robbie Richards, 5/5/16


*** Setup ***

cd "C:\Users\Robbie\Documents\dissertation\Data\mturkSurvey"
use "analysis dataset.dta", clear
run "code\tabmatrix.do"
run "code\mat2txt.do"

gen primed = (aca_treatment == 2 | aca_treatment == 3)
gen mand = (aca_treatment == 1 | aca_treatment == 2)

/* Log:
local time = c(current_date) + " " + subinstr(c(current_time), ":", "-", .) 
cap log close
log using "logs\analysis`time'.smcl", replace
*/

*** Collapsing Variables ***

*Demographics
recode ins_stat (2/8=0) (9=.), gen(uninsured)
recode ins_stat (4/7=4) (8/9=5), gen(r_ins_stat)
label define RINS 1 "Uninsured" 2 "Employer" 3 "Private" 4 "Public" 5 "Other/ DK", modify
label values r_ins_stat RINS

recode religion (2/3=2) (4/7=3), gen(r_relig)
label define RRELIG 1 "None" 2 "Christian" 3 "Other", modify
label values r_relig RRELIG

recode race_ident (2/5=0), gen(white)

recode ideology (1/3=1) (4=2) (5/7=3) (8=4), gen(ideo3)
label define IDEO3 1 "Liberal" 2 "Moderate" 3 "Conservative" 4 "Other", modify
label values ideo3 IDEO3

recode pres_app (1/3=1) (4=2) (5/7=3), gen(r_pres_app)
label define RPRES 1 "Approve" 2 "Neutral" 3 "Disapprove", modify
label values r_pres_app RPRES

*ACA Questions
recode aca (1/3=1) (4/7=0), gen(aca_favor)
recode aca (1/3=1) (4=2) (5/7=3), gen(aca_3pt)

recode im_op (1/3=1) (4/7=0), gen(im_op_favor)
recode im_op (1/3=1) (4=2) (5/7=3), gen(im_op_3pt)

recode ya_op (1/3=1) (4/7=0), gen(ya_op_favor)
recode ya_op (1/3=1) (4=2) (5/7=3), gen(ya_op_3pt)

label define FAVOPP3 1 "Favor" 2 "Neutral" 3 "Oppose", modify
label values aca_3pt im_op_3pt ya_op_3pt FAVOPP3

recode ya_know (2/3=0), gen(ya_knows)
recode im_know (2/3=0), gen(im_knows)
recode ya_affect (2/3=0), gen(ya_affects)
recode im_affect (2/3=0), gen(im_affects)

revrs aca im_op ya_op

ren aca orig_aca
ren revaca aca
ren im_op orig_im_op
ren revim_op im_op
ren ya_op orig_ya_op
ren revya_op ya_op


*** Demographics, Initial Frequencies, Balance Tests ***

/*
*Table 1: Demographics
quietly {
	local vars = "r_pres_app pid ideo3 race_ident r_relig attentive r_ins_stat income"
	local rownames = `""r1""'
	foreach var of local vars {
		levelsof `var', local(lev)
		local labels = ""
		foreach l of local lev {
			local lab : label (`var') `l'
			local labels = `"`labels'"`lab'" "'
		}
		local rownames = `"`rownames' "`var'" `labels' "Total" "Chi2" " ""'
	}
	local rows = 1
	foreach l of local rownames {
		local ++rows
	}
	matrix define output = J(1, 6, .)
}

qui foreach var of local vars {
	tabmatrix `var', matrix(all)
	tabmatrix `var' if form == 1, matrix(form_1)
	tabmatrix `var' if form == 2, matrix(form_2)
	qui tab `var' form, chi2

	matrix chi2 = J(1, 6, .)
	matrix rownames chi2 = "Chi2"
	matrix chi2[1,3] = r(chi2)
	matrix chi2[1,5] = r(p)

	matrix var = J(1, 6, .)
	matrix rownames var = "`var'"

	matrix output = output \ var \ (all , form_1 , form_2) \ chi2 \ J(1,6,.)
}

matrix colnames output = "Freq" "Perc" "Freq" "Perc" "Freq" "Perc"
matrix rownames output = `rownames'
mat2txt, matrix(output) saving("figures\table1.csv") rows(`rows') cols(6) replace

*Table 2: ACA Vars
quietly {
	local vars = "aca repeal im_know im_op im_affect ya_know ya_op ya_affect"
	local rownames = `""r1""'
	foreach var of local vars {
		levelsof `var', local(lev)
		local labels = ""
		foreach l of local lev {
			local lab : label (`var') `l'
			local labels = `"`labels'"`lab'" "'
		}
		local rownames = `"`rownames' "`var'" `labels' "Total" "Chi2" " ""'
	}
	local rows = 1
	foreach l of local rownames {
		local ++rows
	}
	matrix define output = J(1, 6, .)
}

label define ACA 4 "Neither", modify
label define REPEAL 2 "Change some, leave rest", modify

foreach var of local vars {
	tabmatrix `var', matrix(all)
	tabmatrix `var' if form == 1, matrix(form_1)
	tabmatrix `var' if form == 2, matrix(form_2)
	qui tab `var' form, chi2

	matrix chi2 = J(1, 6, .)
	matrix rownames chi2 = "Chi2"
	matrix chi2[1,3] = r(chi2)
	matrix chi2[1,5] = r(p)
	
	matrix var = J(1, 6, .)
	matrix rownames var = "`var'"

	matrix output = output \ var \ (all , form_1 , form_2) \ chi2 \ J(1,6,.)
}

matrix colnames output = "Freq" "Perc" "Freq" "Perc" "Freq" "Perc"
matrix rownames output = `rownames'
mat2txt, matrix(output) saving("figures\table2.csv") rows(`rows') cols(6) replace

label define ACA 4 "Neither favorable nor unfavorable", modify
label define REPEAL 2 "Change some parts, but leave the rest in place", modify

tabstat pres_app partyID ideology race_ident religion attentive ins_stat income
fre form aca_treatment aca repeal im_know im_op im_affect ya_know ya_op ya_affect

misstable sum pid partyID ideology race_ident religion attentive ins_stat ///
	income form aca_treatment aca repeal im_know im_op im_affect ya_know ///
	ya_op ya_affect //missingness is minimal/ as expected; DKs for ins, ideo, and pid are 15, 24, and 63 respectively

//run "code\demog freq bal.do"
*/

*** Bivariate Hypothesis Tests ***

*IM Test Output for R
ttest aca_favor if mand == 1, by(primed)
matrix define output = [0, r(mu_1), (r(sd_1) / sqrt(r(N_1))), r(N_1), (invt(r(N_1)-1,0.975)) \ ///
	1, r(mu_2), (r(sd_2) / sqrt(r(N_2))), r(N_2), (invt(r(N_2)-1,0.975))]
matrix colnames output = "trt" "mean" "se" "N" "tcrit"
matrix rownames output = "Unprimed" "Primed"
mat2txt, matrix(output) saving("stata output\ttest_im.csv") rows(2) cols(5) replace

*YA Test Output for R
ttest aca_favor if mand == 0, by(primed)
matrix define output = [0, r(mu_1), (r(sd_1) / sqrt(r(N_1))), r(N_1), (invt(r(N_1)-1,0.975)) \ ///
	1, r(mu_2), (r(sd_2) / sqrt(r(N_2))), r(N_2), (invt(r(N_2)-1,0.975))]
matrix colnames output = "trt" "mean" "se" "N" "tcrit"
matrix rownames output = "Unprimed" "Primed"
mat2txt, matrix(output) saving("stata output\ttest_ya.csv") rows(2) cols(5) replace

*No priming effects in reverse direction for either policy...
ttest im_op_favor, by(primed)
ttest ya_op_favor, by(primed)

*IM Test by Opinion Output for R
ttest aca_favor if mand == 1 & im_op_favor == 1, by(primed)
matrix define output = [0, r(mu_1), (r(sd_1) / sqrt(r(N_1))), r(N_1), (invt(r(N_1)-1,0.975)) \ ///
	1, r(mu_2), (r(sd_2) / sqrt(r(N_2))), r(N_2), (invt(r(N_2)-1,0.975))]
matrix colnames output = "trt" "mean" "se" "N" "tcrit"
matrix rownames output = "Unprimed" "Primed"
mat2txt, matrix(output) saving("stata output\ttest_im_favor.csv") rows(2) cols(5) replace

ttest aca_favor if mand == 1 & im_op_favor == 0, by(primed)
matrix define output = [0, r(mu_1), (r(sd_1) / sqrt(r(N_1))), r(N_1), (invt(r(N_1)-1,0.975)) \ ///
	1, r(mu_2), (r(sd_2) / sqrt(r(N_2))), r(N_2), (invt(r(N_2)-1,0.975))]
matrix colnames output = "trt" "mean" "se" "N" "tcrit"
matrix rownames output = "Unprimed" "Primed"
mat2txt, matrix(output) saving("stata output\ttest_im_opp.csv") rows(2) cols(5) replace

*YA Test by Opinion Output for R
ttest aca_favor if mand == 0 & ya_op_favor == 1, by(primed)
matrix define output = [0, r(mu_1), (r(sd_1) / sqrt(r(N_1))), r(N_1), (invt(r(N_1)-1,0.975)) \ ///
	1, r(mu_2), (r(sd_2) / sqrt(r(N_2))), r(N_2), (invt(r(N_2)-1,0.975))]
matrix colnames output = "trt" "mean" "se" "N" "tcrit"
matrix rownames output = "Unprimed" "Primed"
mat2txt, matrix(output) saving("stata output\ttest_ya_favor.csv") rows(2) cols(5) replace

ttest aca_favor if mand == 0 & ya_op_favor == 0, by(primed)
matrix define output = [0, r(mu_1), (r(sd_1) / sqrt(r(N_1))), r(N_1), (invt(r(N_1)-1,0.975)) \ ///
	1, r(mu_2), (r(sd_2) / sqrt(r(N_2))), r(N_2), (invt(r(N_2)-1,0.975))]
matrix colnames output = "trt" "mean" "se" "N" "tcrit"
matrix rownames output = "Unprimed" "Primed"
mat2txt, matrix(output) saving("stata output\ttest_ya_opp.csv") rows(2) cols(5) replace


*** Models ***

*Mandate
reg aca im_op pres_app ib3.pid ib2.ideo3 if primed == 1
matrix define model = r(table)'
outreg2 using "stata output\im_models_table.xml", replace excel 2aster e(chi2 r2_p) ctitle("Primed")
mat2txt, matrix(model) saving("stata output\model_im_p.csv") rows(12) cols(9) replace

reg aca im_op pres_app ib3.pid ib2.ideo3 if primed == 0
matrix define model = r(table)'
outreg2 using "stata output\im_models_table.xml", append excel 2aster e(chi2 r2_p) ctitle("Unprimed")
mat2txt, matrix(model) saving("stata output\model_im_u.csv") rows(12) cols(9) replace

reg aca i.primed##c.im_op i.primed##c.pres_app i.primed##ib3.pid i.primed##ib2.ideo3
testparm primed#c.im_op primed#c.pres_app primed#pid primed#ideo3

reg im_op i.primed##c.aca i.primed##c.pres_app i.primed##ib3.pid i.primed##ib2.ideo3
testparm primed#c.aca primed#pres_app primed#pid

*YAcov
reg aca ya_op pres_app ib3.pid ib2.ideo3 if primed == 1
matrix define model = r(table)'
outreg2 using "stata output\ya_models_table.xml", replace excel 2aster e(chi2 r2_p) ctitle("Primed")
mat2txt, matrix(model) saving("stata output\model_ya_p.csv") rows(12) cols(9) replace

reg aca ya_op pres_app ib3.pid ib2.ideo3 if primed == 0
matrix define model = r(table)'
outreg2 using "stata output\ya_models_table.xml", append excel 2aster e(chi2 r2_p) ctitle("Unprimed")
mat2txt, matrix(model) saving("stata output\model_ya_u.csv") rows(12) cols(9) replace

reg aca i.primed##c.ya_op i.primed##c.pres_app i.primed##ib3.pid i.primed##ib2.ideo3
testparm primed#c.ya_op primed#c.pres_app primed#pid primed#ideo3

reg ya_op i.primed##c.aca i.primed##c.pres_app i.primed##ib3.pid i.primed##ib2.ideo3
testparm primed#c.aca primed#pres_app primed#pid

*Ordered Logit Robustness Checks
ologit aca i.primed##c.im_op i.primed##c.pres_app i.primed##ib3.pid i.primed##ib2.ideo3
testparm primed#c.im_op primed#c.pres_app primed#pid primed#ideo3

foreach var in c.im_op c.pres_app 1.pid 2.pid 4.pid 1.ideo3 3.ideo3 4.ideo3 {
	lincom _b[`var'] + _b[1.primed#`var']
}

ologit aca i.primed##c.ya_op i.primed##c.pres_app i.primed##ib3.pid i.primed##ib2.ideo3
testparm primed#c.ya_op primed#pres_app primed#pid

foreach var in c.ya_op c.pres_app 1.pid 2.pid 4.pid 1.ideo3 3.ideo3 4.ideo3 {
	lincom _b[`var'] + _b[1.primed#`var']
}

*** Power Analysis for models ***

reg aca im_op i.primed##c.pres_app i.primed##ib3.pid //restricted
local r2r = e(r2)
reg aca i.primed##c.im_op i.primed##c.pres_app i.primed##ib3.pid //full
local r2f = e(r2)
powerreg, r2f(`r2f') r2r(`r2r') nvar(11) ntest(1) power(0.7)
powerreg, r2f(`r2f') r2r(`r2r') nvar(11) ntest(1) power(0.8)
powerreg, r2f(`r2f') r2r(`r2r') nvar(11) ntest(1) power(0.9)

