-- HEDA Data Table --

--Robbie Richards, last modified 3/28/16

--DROP TABLE dissertData..elections
CREATE TABLE dissertData..elections (
	state VARCHAR(4),
	year INT,
	ed_precinct VARCHAR(MAX),
	precinct VARCHAR(MAX),
	ed VARCHAR(MAX),
	precinct_code VARCHAR(MAX),
	g_REG_tv DECIMAL(9,0),
	g_GOV_tv VARCHAR(MAX),
	g_GOV_dv DECIMAL(9,0),
	g_GOV_rv DECIMAL(9,0),
	g_STH_dv DECIMAL(9,0),
	g_STH_rv DECIMAL(9,0),
	g_STS_dv DECIMAL(9,0),
	g_STS_rv DECIMAL(9,0),
	g_USH_dv DECIMAL(9,0),
	g_USH_rv DECIMAL(9,0),
	g_USS_dv DECIMAL(9,0),
	g_USS_rv DECIMAL(9,0),
	g_USP_tv DECIMAL(9,0),
	g_USP_dv DECIMAL(9,0),
	g_USP_rv DECIMAL(9,0),
	g_USS_tv DECIMAL(9,0),
	g_USH_tv DECIMAL(9,0),
	g_STS_tv DECIMAL(9,0),
	g_STH_tv DECIMAL(9,0),
	g_BALL_tv DECIMAL(9,0),
	sd VARCHAR(10),
	ld DECIMAL(9,0),
	cd DECIMAL(9,0),
	county VARCHAR(MAX),
	cd2 DECIMAL(9,0),
	g_USH_dv2 DECIMAL(9,0),
	g_USH_rv2 DECIMAL(9,0),
	g_USH_tv2 DECIMAL(9,0),
	g_LTG_dv DECIMAL(9,0),
	g_LTG_rv DECIMAL(9,0),
	g_LTG_tv DECIMAL(9,0),
	g_ATG_dv DECIMAL(9,0),
	g_ATG_rv DECIMAL(9,0),
	g_ATG_tv DECIMAL(9,0),
	g_SOS_dv DECIMAL(9,0),
	g_SOS_rv DECIMAL(9,0),
	g_SOS_tv DECIMAL(9,0),
	g_AUD_rv DECIMAL(9,0),
	g_AUD_dv DECIMAL(9,0),
	g_AUD_tv DECIMAL(9,0),
	g_TRE_rv DECIMAL(9,0),
	g_TRE_dv DECIMAL(9,0),
	g_TRE_tv DECIMAL(9,0),
	g_COM_rv DECIMAL(9,0),
	g_COM_dv DECIMAL(9,0),
	g_COM_tv DECIMAL(9,0),
	g_INS_rv DECIMAL(9,0),
	g_INS_dv DECIMAL(9,0),
	g_INS_tv DECIMAL(9,0),
	g_LND_rv DECIMAL(9,0),
	g_LND_dv DECIMAL(9,0),
	g_LND_tv DECIMAL(9,0),
	g_AGR_rv DECIMAL(9,0),
	g_AGR_dv DECIMAL(9,0),
	g_AGR_tv DECIMAL(9,0),
	g_SPI_rv DECIMAL(9,0),
	g_SPI_dv DECIMAL(9,0),
	g_SPI_tv DECIMAL(9,0),
	g_LBR_rv DECIMAL(9,0),
	g_LBR_dv DECIMAL(9,0),
	g_LBR_tv DECIMAL(9,0),
	fips_cnty DECIMAL(9,0),
	box VARCHAR(MAX),
	ward VARCHAR(MAX),
	sd2 DECIMAL(9,0),
	sd3 DECIMAL(9,0),
	sd4 DECIMAL(9,0),
	sd5 DECIMAL(9,0),
	ld2 DECIMAL(9,0),
	ld3 DECIMAL(9,0),
	ld4 DECIMAL(9,0),
	ld5 DECIMAL(9,0),
	sboed2 VARCHAR(MAX),
	sboed VARCHAR(MAX),
	g_STS_dv2 DECIMAL(9,0),
	g_STS_rv2 DECIMAL(9,0),
	g_STS_tv2 DECIMAL(9,0),
	g_STS_dv3 DECIMAL(9,0),
	g_STS_rv3 DECIMAL(9,0),
	g_STS_tv3 DECIMAL(9,0),
	g_STS_dv4 DECIMAL(9,0),
	g_STS_rv4 DECIMAL(9,0),
	g_STS_tv4 DECIMAL(9,0),
	g_STS_dv5 DECIMAL(9,0),
	g_STS_rv5 DECIMAL(9,0),
	g_STS_tv5 DECIMAL(9,0),
	g_STH_dv2 DECIMAL(9,0),
	g_STH_rv2 DECIMAL(9,0),
	g_STH_tv2 DECIMAL(9,0),
	g_STH_dv3 DECIMAL(9,0),
	g_STH_rv3 DECIMAL(9,0),
	g_STH_tv3 DECIMAL(9,0),
	g_STH_dv4 DECIMAL(9,0),
	g_STH_rv4 DECIMAL(9,0),
	g_STH_tv4 DECIMAL(9,0),
	g_STH_dv5 DECIMAL(9,0),
	g_STH_rv5 DECIMAL(9,0),
	g_STH_tv5 DECIMAL(9,0),
	cd3 DECIMAL(9,0),
	g_USH_dv3 DECIMAL(9,0),
	g_USH_rv3 DECIMAL(9,0),
	g_USH_tv3 DECIMAL(9,0),
	g_USP_lrv DECIMAL(9,0),
	g_USP_erv DECIMAL(9,0),
	g_USP_arv DECIMAL(9,0),
	g_USP_prv DECIMAL(9,0),
	g_USP_ldv DECIMAL(9,0),
	g_USP_edv DECIMAL(9,0),
	g_USP_adv DECIMAL(9,0),
	g_USP_pdv DECIMAL(9,0),
	g_USH_adv DECIMAL(9,0),
	g_USH_arv DECIMAL(9,0),
	g_USH_atv DECIMAL(9,0),
	g_USH_edv DECIMAL(9,0),
	g_USH_erv DECIMAL(9,0),
	g_USH_etv DECIMAL(9,0),
	g_USH_ldv DECIMAL(9,0),
	g_USH_lrv DECIMAL(9,0),
	g_USH_ltv DECIMAL(9,0),
	g_BALL_eev DECIMAL(9,0),
	g_BALL_epv DECIMAL(9,0),
	g_BALL_lev DECIMAL(9,0),
	g_BALL_lpv DECIMAL(9,0),
	county_code VARCHAR(MAX),
	svprec_key VARCHAR(MAX),
	svprec VARCHAR(MAX),
	g_VOTE_dv DECIMAL(9,0),
	g_VOTE_rv DECIMAL(9,0),
	g_VOTE_tv DECIMAL(9,0),
	vtd VARCHAR(MAX),
	g_REG_dv DECIMAL(9,0),
	g_REG_rv DECIMAL(9,0),
	town VARCHAR(MAX),
	g_SOS_lv DECIMAL(9,0),
	g_USS_iv DECIMAL(9,0),
	g_USP_mdv DECIMAL(9,0),
	g_USP_mrv DECIMAL(9,0),
	g_USP_mtv DECIMAL(9,0),
	g_USP_atv DECIMAL(9,0),
	g_USS_mdv DECIMAL(9,0),
	g_USS_adv DECIMAL(9,0),
	g_USS_mrv DECIMAL(9,0),
	g_USS_arv DECIMAL(9,0),
	g_USS_mtv DECIMAL(9,0),
	g_USS_atv DECIMAL(9,0),
	g_USH_mdv DECIMAL(9,0),
	g_USH_mrv DECIMAL(9,0),
	g_USH_mtv DECIMAL(9,0),
	g_GOV_mdv DECIMAL(9,0),
	g_GOV_adv DECIMAL(9,0),
	g_GOV_mrv DECIMAL(9,0),
	g_GOV_arv DECIMAL(9,0),
	g_GOV_atv DECIMAL(9,0),
	g_GOV_mtv DECIMAL(9,0),
	g_LTG_mdv DECIMAL(9,0),
	g_LTG_adv DECIMAL(9,0),
	g_LTG_mrv DECIMAL(9,0),
	g_LTG_arv DECIMAL(9,0),
	g_LTG_mtv DECIMAL(9,0),
	g_LTG_atv DECIMAL(9,0),
	g_STS_mdv DECIMAL(9,0),
	g_STS_adv DECIMAL(9,0),
	g_STS_mrv DECIMAL(9,0),
	g_STS_arv DECIMAL(9,0),
	g_STS_mtv DECIMAL(9,0),
	g_STS_atv DECIMAL(9,0),
	g_STH_mdv DECIMAL(9,0),
	g_STH_adv DECIMAL(9,0),
	g_STH_mrv DECIMAL(9,0),
	g_STH_arv DECIMAL(9,0),
	g_STH_mtv DECIMAL(9,0),
	g_STH_atv DECIMAL(9,0),
	g_REG_iv DECIMAL(9,0),
	g_BALL_dv DECIMAL(9,0),
	g_BALL_rv DECIMAL(9,0),
	g_BALL_iv DECIMAL(9,0),
	g_USP_etv DECIMAL(9,0),
	g_USP_ltv DECIMAL(9,0),
	g_USP_ptv DECIMAL(9,0),
	g_USH_prv DECIMAL(9,0),
	g_USH_pdv DECIMAL(9,0),
	g_REG_tv2 DECIMAL(9,0),
	g_USH_lrv2 DECIMAL(9,0),
	g_USH_arv2 DECIMAL(9,0),
	g_USH_erv2 DECIMAL(9,0),
	g_USH_prv2 DECIMAL(9,0),
	g_USH_ldv2 DECIMAL(9,0),
	g_USH_adv2 DECIMAL(9,0),
	g_USH_edv2 DECIMAL(9,0),
	g_USH_pdv2 DECIMAL(9,0),
	g_REG_tv3 DECIMAL(9,0),
	g_USH_lrv3 DECIMAL(9,0),
	g_USH_arv3 DECIMAL(9,0),
	g_USH_erv3 DECIMAL(9,0),
	g_USH_prv3 DECIMAL(9,0),
	g_USH_ldv3 DECIMAL(9,0),
	g_USH_adv3 DECIMAL(9,0),
	g_USH_edv3 DECIMAL(9,0),
	g_USH_pdv3 DECIMAL(9,0),
	cd4 DECIMAL(9,0),
	g_REG_tv4 DECIMAL(9,0),
	g_USH_lrv4 DECIMAL(9,0),
	g_USH_arv4 DECIMAL(9,0),
	g_USH_erv4 DECIMAL(9,0),
	g_USH_prv4 DECIMAL(9,0),
	g_USH_rv4 DECIMAL(9,0),
	g_USH_ldv4 DECIMAL(9,0),
	g_USH_adv4 DECIMAL(9,0),
	g_USH_edv4 DECIMAL(9,0),
	g_USH_pdv4 DECIMAL(9,0),
	g_USH_dv4 DECIMAL(9,0),
	g_USH_tv4 DECIMAL(9,0),
	g_STH_lrv DECIMAL(9,0),
	g_STH_erv DECIMAL(9,0),
	g_STH_prv DECIMAL(9,0),
	g_STH_ldv DECIMAL(9,0),
	g_STH_edv DECIMAL(9,0),
	g_STH_pdv DECIMAL(9,0),
	g_STH_lrv2 DECIMAL(9,0),
	g_STH_arv2 DECIMAL(9,0),
	g_STH_erv2 DECIMAL(9,0),
	g_STH_prv2 DECIMAL(9,0),
	g_STH_ldv2 DECIMAL(9,0),
	g_STH_adv2 DECIMAL(9,0),
	g_STH_edv2 DECIMAL(9,0),
	g_STH_pdv2 DECIMAL(9,0),
	g_STH_lrv3 DECIMAL(9,0),
	g_STH_arv3 DECIMAL(9,0),
	g_STH_erv3 DECIMAL(9,0),
	g_STH_prv3 DECIMAL(9,0),
	g_STH_ldv3 DECIMAL(9,0),
	g_STH_adv3 DECIMAL(9,0),
	g_STH_edv3 DECIMAL(9,0),
	g_STH_pdv3 DECIMAL(9,0),
	g_STS_lrv DECIMAL(9,0),
	g_STS_erv DECIMAL(9,0),
	g_STS_prv DECIMAL(9,0),
	g_STS_ldv DECIMAL(9,0),
	g_STS_edv DECIMAL(9,0),
	g_STS_pdv DECIMAL(9,0),
	g_STS_lrv2 DECIMAL(9,0),
	g_STS_arv2 DECIMAL(9,0),
	g_STS_erv2 DECIMAL(9,0),
	g_STS_prv2 DECIMAL(9,0),
	g_STS_ldv2 DECIMAL(9,0),
	g_STS_adv2 DECIMAL(9,0),
	g_STS_edv2 DECIMAL(9,0),
	g_STS_pdv2 DECIMAL(9,0),
	g_STS_lrv3 DECIMAL(9,0),
	g_STS_arv3 DECIMAL(9,0),
	g_STS_erv3 DECIMAL(9,0),
	g_STS_prv3 DECIMAL(9,0),
	g_STS_ldv3 DECIMAL(9,0),
	g_STS_adv3 DECIMAL(9,0),
	g_STS_edv3 DECIMAL(9,0),
	g_STS_pdv3 DECIMAL(9,0),
	precinct_name VARCHAR(MAX),
	g_USS_edv DECIMAL(9,0),
	g_USS_erv DECIMAL(9,0),
	g_USS_etv DECIMAL(9,0),
	g_USS_ldv DECIMAL(9,0),
	g_USS_lrv DECIMAL(9,0),
	g_USS_ltv DECIMAL(9,0),
	g_STH_etv DECIMAL(9,0),
	g_STH_ltv DECIMAL(9,0),
	g_STS_etv DECIMAL(9,0),
	g_STS_ltv DECIMAL(9,0),
	ld6 DECIMAL(9,0),
	g_STH_dv6 DECIMAL(9,0),
	g_STH_rv6 DECIMAL(9,0),
	g_STH_tv6 DECIMAL(9,0),
	ld7 DECIMAL(9,0),
	g_STH_dv7 DECIMAL(9,0),
	g_STH_rv7 DECIMAL(9,0),
	g_STH_tv7 DECIMAL(9,0),
	ld8 DECIMAL(9,0),
	g_STH_dv8 DECIMAL(9,0),
	g_STH_rv8 DECIMAL(9,0),
	g_STH_tv8 DECIMAL(9,0),
	ld9 DECIMAL(9,0),
	g_STH_dv9 DECIMAL(9,0),
	g_STH_rv9 DECIMAL(9,0),
	g_STH_tv9 DECIMAL(9,0),
	ld10 DECIMAL(9,0),
	g_STH_dv10 DECIMAL(9,0),
	g_STH_rv10 DECIMAL(9,0),
	g_STH_tv10 DECIMAL(9,0),
	ld11 DECIMAL(9,0),
	g_STH_dv11 DECIMAL(9,0),
	g_STH_rv11 DECIMAL(9,0),
	g_STH_tv11 DECIMAL(9,0),
	ld12 DECIMAL(9,0),
	g_STH_dv12 DECIMAL(9,0),
	g_STH_rv12 DECIMAL(9,0),
	g_STH_tv12 DECIMAL(9,0),
	ld13 DECIMAL(9,0),
	g_STH_dv13 DECIMAL(9,0),
	g_STH_rv13 DECIMAL(9,0),
	g_STH_tv13 DECIMAL(9,0),
	g_STS_dv6 DECIMAL(9,0),
	g_STS_rv6 DECIMAL(9,0),
	sd6 DECIMAL(9,0),
	g_STS_tv6 DECIMAL(9,0),
	g_STS_dv7 DECIMAL(9,0),
	g_STS_rv7 DECIMAL(9,0),
	sd7 DECIMAL(9,0),
	g_STS_tv7 DECIMAL(9,0),
	g_STS_dv8 DECIMAL(9,0),
	g_STS_rv8 DECIMAL(9,0),
	sd8 DECIMAL(9,0),
	g_STS_tv8 DECIMAL(9,0),
	g_STS_dv9 DECIMAL(9,0),
	g_STS_rv9 DECIMAL(9,0),
	sd9 DECIMAL(9,0),
	g_STS_tv9 DECIMAL(9,0),
	g_STS_dv10 DECIMAL(9,0),
	g_STS_rv10 DECIMAL(9,0),
	sd10 DECIMAL(9,0),
	g_STS_tv10 DECIMAL(9,0),
	g_STS_dv11 DECIMAL(9,0),
	g_STS_rv11 DECIMAL(9,0),
	sd11 DECIMAL(9,0),
	g_STS_tv11 DECIMAL(9,0),
	g_STS_dv12 DECIMAL(9,0),
	g_STS_rv12 DECIMAL(9,0),
	sd12 DECIMAL(9,0),
	g_STS_tv12 DECIMAL(9,0),
	g_STS_dv13 DECIMAL(9,0),
	g_STS_rv13 DECIMAL(9,0),
	sd13 DECIMAL(9,0),
	g_STS_tv13 DECIMAL(9,0),
	g_REG_cv DECIMAL(9,0),
	g_REG_ev DECIMAL(9,0),
	g_REG_ov DECIMAL(9,0),
	g_REG_mv DECIMAL(9,0),
	g_REG_fv DECIMAL(9,0),
	g_STS_iv DECIMAL(9,0),
	cd5 DECIMAL(9,0),
	parish VARCHAR(MAX),
	r_STS_dv DECIMAL(9,0),
	r_STS_rv DECIMAL(9,0),
	r_STS_tv DECIMAL(9,0),
	r_STH_dv DECIMAL(9,0),
	r_STH_rv DECIMAL(9,0),
	r_STH_tv DECIMAL(9,0),
	jud_circ VARCHAR(MAX),
	r_GOV_rv DECIMAL(9,0),
	r_GOV_dv DECIMAL(9,0),
	r_GOV_tv DECIMAL(9,0),
	r_STS_dv2 DECIMAL(9,0),
	r_STS_rv2 DECIMAL(9,0),
	r_STS_tv2 DECIMAL(9,0),
	r_STH_dv2 DECIMAL(9,0),
	r_STH_rv2 DECIMAL(9,0),
	r_STH_tv2 DECIMAL(9,0),
	r_STH_dv3 DECIMAL(9,0),
	r_STH_rv3 DECIMAL(9,0),
	r_STH_tv3 DECIMAL(9,0),
	r_ATG_dv DECIMAL(9,0),
	r_ATG_rv DECIMAL(9,0),
	r_ATG_tv DECIMAL(9,0),
	s2007_STH_dv DECIMAL(9,0),
	s2007_STH_rv DECIMAL(9,0),
	s2007_STH_tv DECIMAL(9,0),
	sr2007_STH_dv DECIMAL(9,0),
	sr2007_STH_rv DECIMAL(9,0),
	sr2007_STH_tv DECIMAL(9,0),
	jud_dist VARCHAR(MAX),
	jud_elec_sec VARCHAR(MAX),
	jud_div VARCHAR(MAX),
	g_USH_d2v DECIMAL(9,0),
	g_USH_r2v DECIMAL(9,0),
	g_USH_r3v DECIMAL(9,0),
	s2010_USS_rv DECIMAL(9,0),
	s2010_USS_dv DECIMAL(9,0),
	s2010_USS_tv DECIMAL(9,0),
	town_name VARCHAR(MAX),
	ward_precinct VARCHAR(MAX),
	county_name VARCHAR(MAX),
	fips VARCHAR(MAX),
	ld_name VARCHAR(MAX),
	ld_code VARCHAR(MAX),
	mcd VARCHAR(MAX),
	mcd_code VARCHAR(MAX),
	ld14 DECIMAL(9,0),
	g_STH_dv14 DECIMAL(9,0),
	g_STH_rv14 DECIMAL(9,0),
	g_STH_tv14 DECIMAL(9,0),
	sd14 DECIMAL(9,0),
	g_STS_dv14 DECIMAL(9,0),
	g_STS_rv14 DECIMAL(9,0),
	g_STS_tv14 DECIMAL(9,0),
	g_STH_dv1 DECIMAL(9,0),
	g_STH_rv1 DECIMAL(9,0),
	g_STH_tv1 DECIMAL(9,0),
	g_STS_dv1 DECIMAL(9,0),
	g_STS_rv1 DECIMAL(9,0),
	g_STS_tv1 DECIMAL(9,0),
	g_USH_tv1 DECIMAL(9,0),
	countyprecinct_code VARCHAR(MAX),
	s2008_USS_dv DECIMAL(9,0),
	s2008_USS_rv DECIMAL(9,0),
	s2008_USS_tv DECIMAL(9,0),
	electiondistrictbeat VARCHAR(MAX),
	g_USH_dv5 DECIMAL(9,0),
	g_USH_rv5 DECIMAL(9,0),
	g_USH_tv5 DECIMAL(9,0),
	g_STS_odv DECIMAL(9,0),
	g_STS_orv DECIMAL(9,0),
	g_STS_odv2 DECIMAL(9,0),
	g_STS_orv2 DECIMAL(9,0),
	g_STS_odv3 DECIMAL(9,0),
	g_STS_orv3 DECIMAL(9,0),
	g_STS_ldv4 DECIMAL(9,0),
	g_STS_odv4 DECIMAL(9,0),
	g_STS_adv4 DECIMAL(9,0),
	g_STS_pdv4 DECIMAL(9,0),
	g_STS_lrv4 DECIMAL(9,0),
	g_STS_orv4 DECIMAL(9,0),
	g_STS_arv4 DECIMAL(9,0),
	g_STS_prv4 DECIMAL(9,0),
	g_STS_ldv5 DECIMAL(9,0),
	g_STS_odv5 DECIMAL(9,0),
	g_STS_adv5 DECIMAL(9,0),
	g_STS_pdv5 DECIMAL(9,0),
	g_STS_lrv5 DECIMAL(9,0),
	g_STS_orv5 DECIMAL(9,0),
	g_STS_arv5 DECIMAL(9,0),
	g_STS_prv5 DECIMAL(9,0),
	g_STH_odv DECIMAL(9,0),
	g_STH_orv DECIMAL(9,0),
	g_STH_odv2 DECIMAL(9,0),
	g_STH_orv2 DECIMAL(9,0),
	g_STH_odv3 DECIMAL(9,0),
	g_STH_orv3 DECIMAL(9,0),
	g_STH_ldv4 DECIMAL(9,0),
	g_STH_odv4 DECIMAL(9,0),
	g_STH_adv4 DECIMAL(9,0),
	g_STH_pdv4 DECIMAL(9,0),
	g_STH_lrv4 DECIMAL(9,0),
	g_STH_orv4 DECIMAL(9,0),
	g_STH_arv4 DECIMAL(9,0),
	g_STH_prv4 DECIMAL(9,0),
	g_STH_ldv5 DECIMAL(9,0),
	g_STH_odv5 DECIMAL(9,0),
	g_STH_adv5 DECIMAL(9,0),
	g_STH_pdv5 DECIMAL(9,0),
	g_STH_lrv5 DECIMAL(9,0),
	g_STH_orv5 DECIMAL(9,0),
	g_STH_arv5 DECIMAL(9,0),
	g_STH_prv5 DECIMAL(9,0),
	g_STH_ldv6 DECIMAL(9,0),
	g_STH_odv6 DECIMAL(9,0),
	g_STH_adv6 DECIMAL(9,0),
	g_STH_pdv6 DECIMAL(9,0),
	g_STH_lrv6 DECIMAL(9,0),
	g_STH_orv6 DECIMAL(9,0),
	g_STH_arv6 DECIMAL(9,0),
	g_STH_prv6 DECIMAL(9,0),
	g_STH_ldv7 DECIMAL(9,0),
	g_STH_odv7 DECIMAL(9,0),
	g_STH_adv7 DECIMAL(9,0),
	g_STH_pdv7 DECIMAL(9,0),
	g_STH_lrv7 DECIMAL(9,0),
	g_STH_orv7 DECIMAL(9,0),
	g_STH_arv7 DECIMAL(9,0),
	g_STH_prv7 DECIMAL(9,0),
	g_STH_ldv8 DECIMAL(9,0),
	g_STH_odv8 DECIMAL(9,0),
	g_STH_adv8 DECIMAL(9,0),
	g_STH_pdv8 DECIMAL(9,0),
	g_STH_lrv8 DECIMAL(9,0),
	g_STH_orv8 DECIMAL(9,0),
	g_STH_arv8 DECIMAL(9,0),
	g_STH_prv8 DECIMAL(9,0),
	g_STH_ldv9 DECIMAL(9,0),
	g_STH_odv9 DECIMAL(9,0),
	g_STH_adv9 DECIMAL(9,0),
	g_STH_pdv9 DECIMAL(9,0),
	g_STH_lrv9 DECIMAL(9,0),
	g_STH_orv9 DECIMAL(9,0),
	g_STH_arv9 DECIMAL(9,0),
	g_STH_prv9 DECIMAL(9,0),
	g_STH_ldv10 DECIMAL(9,0),
	g_STH_odv10 DECIMAL(9,0),
	g_STH_adv10 DECIMAL(9,0),
	g_STH_pdv10 DECIMAL(9,0),
	g_STH_lrv10 DECIMAL(9,0),
	g_STH_orv10 DECIMAL(9,0),
	g_STH_arv10 DECIMAL(9,0),
	g_STH_prv10 DECIMAL(9,0),
	g_STH_ldv11 DECIMAL(9,0),
	g_STH_odv11 DECIMAL(9,0),
	g_STH_adv11 DECIMAL(9,0),
	g_STH_pdv11 DECIMAL(9,0),
	g_STH_lrv11 DECIMAL(9,0),
	g_STH_orv11 DECIMAL(9,0),
	g_STH_arv11 DECIMAL(9,0),
	g_STH_prv11 DECIMAL(9,0),
	g_STH_ldv12 DECIMAL(9,0),
	g_STH_odv12 DECIMAL(9,0),
	g_STH_adv12 DECIMAL(9,0),
	g_STH_pdv12 DECIMAL(9,0),
	g_STH_lrv12 DECIMAL(9,0),
	g_STH_orv12 DECIMAL(9,0),
	g_STH_arv12 DECIMAL(9,0),
	g_STH_prv12 DECIMAL(9,0),
	g_USH_odv DECIMAL(9,0),
	g_USH_orv DECIMAL(9,0),
	g_USH_odv2 DECIMAL(9,0),
	g_USH_orv2 DECIMAL(9,0),
	g_USH_odv3 DECIMAL(9,0),
	g_USH_orv3 DECIMAL(9,0),
	g_USH_odv4 DECIMAL(9,0),
	g_USH_orv4 DECIMAL(9,0),
	g_ATG_adv DECIMAL(9,0),
	g_ATG_ldv DECIMAL(9,0),
	g_ATG_odv DECIMAL(9,0),
	g_ATG_pdv DECIMAL(9,0),
	g_GOV_ldv DECIMAL(9,0),
	g_GOV_lrv DECIMAL(9,0),
	g_GOV_odv DECIMAL(9,0),
	g_GOV_orv DECIMAL(9,0),
	g_GOV_pdv DECIMAL(9,0),
	g_GOV_prv DECIMAL(9,0),
	g_LTG_ldv DECIMAL(9,0),
	g_LTG_lrv DECIMAL(9,0),
	g_LTG_odv DECIMAL(9,0),
	g_LTG_orv DECIMAL(9,0),
	g_LTG_pdv DECIMAL(9,0),
	g_LTG_prv DECIMAL(9,0),
	g_SOS_adv DECIMAL(9,0),
	g_SOS_arv DECIMAL(9,0),
	g_SOS_ldv DECIMAL(9,0),
	g_SOS_lrv DECIMAL(9,0),
	g_SOS_odv DECIMAL(9,0),
	g_SOS_orv DECIMAL(9,0),
	g_SOS_pdv DECIMAL(9,0),
	g_SOS_prv DECIMAL(9,0),
	g_USP_odv DECIMAL(9,0),
	g_USP_orv DECIMAL(9,0),
	g_VOTE_adv DECIMAL(9,0),
	g_VOTE_arv DECIMAL(9,0),
	g_VOTE_ldv DECIMAL(9,0),
	g_VOTE_lrv DECIMAL(9,0),
	g_VOTE_odv DECIMAL(9,0),
	g_VOTE_orv DECIMAL(9,0),
	g_VOTE_pdv DECIMAL(9,0),
	g_VOTE_prv DECIMAL(9,0),
	g_BALL_rtv DECIMAL(9,0),
	g_BALL_atv DECIMAL(9,0),
	geo_code VARCHAR(MAX),
	g_STH2_dv DECIMAL(9,0),
	g_STH2_rv DECIMAL(9,0),
	g_STH2_tv DECIMAL(9,0),
	g_STHa_dv DECIMAL(9,0),
	g_STHa_rv DECIMAL(9,0),
	g_STHa_tv DECIMAL(9,0),
	small VARCHAR(MAX),
	cousub VARCHAR(MAX),
	vtd08 VARCHAR(MAX),
	vtdid VARCHAR(MAX),
	ward2 VARCHAR(MAX),
	ward3 VARCHAR(MAX),
	ward4 VARCHAR(MAX),
	ward5 VARCHAR(MAX),
	ward6 VARCHAR(MAX),
	ed2 VARCHAR(MAX),
	ed3 VARCHAR(MAX),
	ed4 VARCHAR(MAX),
	ed5 VARCHAR(MAX),
	ed6 VARCHAR(MAX),
	ed7 VARCHAR(MAX),
	ed8 VARCHAR(MAX),
	ed9 VARCHAR(MAX),
	ed10 VARCHAR(MAX),
	ed11 VARCHAR(MAX),
	ed12 VARCHAR(MAX),
	ed13 VARCHAR(MAX),
	ed14 VARCHAR(MAX),
	ed15 VARCHAR(MAX),
	ed16 VARCHAR(MAX),
	ed17 VARCHAR(MAX),
	ed18 VARCHAR(MAX),
	ed19 VARCHAR(MAX),
	ed20 VARCHAR(MAX),
	ed21 VARCHAR(MAX),
	ed22 VARCHAR(MAX),
	ed23 VARCHAR(MAX),
	ed24 VARCHAR(MAX),
	ed25 VARCHAR(MAX),
	ed26 VARCHAR(MAX),
	ed27 VARCHAR(MAX),
	ed28 VARCHAR(MAX),
	ed29 VARCHAR(MAX),
	ad VARCHAR(MAX),
	nopad_vtdid VARCHAR(MAX),
	g_USH_atv2 DECIMAL(9,0),
	g_USH_etv2 DECIMAL(9,0),
	g_USH_ltv2 DECIMAL(9,0),
	g_STS_atv2 DECIMAL(9,0),
	g_STS_etv2 DECIMAL(9,0),
	g_STS_ltv2 DECIMAL(9,0),
	g_STH_atv2 DECIMAL(9,0),
	g_STH_etv2 DECIMAL(9,0),
	g_STH_ltv2 DECIMAL(9,0),
	g_STH_atv3 DECIMAL(9,0),
	g_STH_etv3 DECIMAL(9,0),
	g_STH_ltv3 DECIMAL(9,0),
	g_STH_edv4 DECIMAL(9,0),
	g_STH_erv4 DECIMAL(9,0),
	g_STH_atv4 DECIMAL(9,0),
	g_STH_etv4 DECIMAL(9,0),
	g_STH_ltv4 DECIMAL(9,0),
	g_STH_edv5 DECIMAL(9,0),
	g_STH_erv5 DECIMAL(9,0),
	g_STH_atv5 DECIMAL(9,0),
	g_STH_etv5 DECIMAL(9,0),
	g_STH_ltv5 DECIMAL(9,0),
	g_STH_edv6 DECIMAL(9,0),
	g_STH_erv6 DECIMAL(9,0),
	g_STH_atv6 DECIMAL(9,0),
	g_STH_etv6 DECIMAL(9,0),
	g_STH_ltv6 DECIMAL(9,0),
	g_STH_edv7 DECIMAL(9,0),
	g_STH_erv7 DECIMAL(9,0),
	g_STH_atv7 DECIMAL(9,0),
	g_STH_etv7 DECIMAL(9,0),
	g_STH_ltv7 DECIMAL(9,0),
	g_STH_edv8 DECIMAL(9,0),
	g_STH_erv8 DECIMAL(9,0),
	g_STH_atv8 DECIMAL(9,0),
	g_STH_etv8 DECIMAL(9,0),
	g_STH_ltv8 DECIMAL(9,0),
	g_STH_edv9 DECIMAL(9,0),
	g_STH_erv9 DECIMAL(9,0),
	g_STH_atv9 DECIMAL(9,0),
	g_STH_etv9 DECIMAL(9,0),
	g_STH_ltv9 DECIMAL(9,0),
	g_GOV_iv DECIMAL(9,0),
	ld15 DECIMAL(9,0),
	g_STH_dv15 DECIMAL(9,0),
	g_STH_rv15 DECIMAL(9,0),
	g_STH_tv15 DECIMAL(9,0),
	ld16 DECIMAL(9,0),
	g_STH_dv16 DECIMAL(9,0),
	g_STH_rv16 DECIMAL(9,0),
	g_STH_tv16 DECIMAL(9,0),
	cntyvtd VARCHAR(MAX),
	fips_pct DECIMAL(9,0),
	g_ATG_iv DECIMAL(9,0),
	g_USH_iv DECIMAL(9,0),
	cd2010 DECIMAL(9,0),
	s2012_USH_dv DECIMAL(9,0),
	s2012_USH_rv DECIMAL(9,0),
	s2012_USH_tv DECIMAL(9,0))

BULK INSERT dissertData..elections
	FROM 'C:\Users\Robbie\Documents\dissertation\data\elections\edadCombined.txt'
	WITH (FIELDTERMINATOR = '\t', FIRSTROW = 2)

--Remove quotes from state names
UPDATE dissertData..elections SET elections.state = REPLACE(elections.state, '"', '')
UPDATE dissertData..elections SET elections.county = REPLACE(elections.county, '"', '')
UPDATE dissertData..elections SET elections.precinct = REPLACE(elections.precinct, '"', '')

--Update CD value for single-district states
UPDATE dissertData..elections SET elections.cd = 1.0
		WHERE elections.cd IS NULL
			AND (elections.state = 'AK'
				OR elections.state = 'DE'
				OR elections.state = 'MT'
				OR elections.state = 'ND'
				OR elections.state = 'SD'
				OR elections.state = 'VT'
				OR elections.state = 'WY')

SELECT elections.state,
		elections.year,
		COUNT(*)
	FROM dissertData..elections
	GROUP BY elections.state, elections.year
	ORDER BY elections.state, elections.year
