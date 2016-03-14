------------------------------------------------
--  Update, Standardize Elections Data Table  --
------------------------------------------------

--Robbie Richards, 2/23/16

--Remove quotes from state names
UPDATE dissertData..elections SET elections.state = REPLACE(elections.state, '"', '')
UPDATE dissertData..elections SET elections.county = REPLACE(elections.county, '"', '')
UPDATE dissertData..elections SET elections.precinct = REPLACE(elections.precinct, '"', '')
--select distinct state from dissertData..elections order by state

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

--Update CD values for states with multiple districts where cd is null
--(includes CO, GA, ID 2000, KS 2006, LA, NM, NY, PA 2012, SC 2004, TX 2002, and UT)

--CO
SELECT year,
		cd,
		county,
		precinct,
		vtd
	FROM dissertData..elections
	WHERE elections.state = 'CO'
	ORDER BY year

--DROP TABLE dissertData..COelec
SELECT elections.year,
		elections.cd,
		elections.county,
		elections.precinct,
		elections.vtd
	INTO dissertData..COelec
	FROM dissertData..elections
		WHERE elections.state = 'CO'

SELECT a.cd AS 'CD 2004',
		b.vtd AS 'Voting District 2008'
	FROM dissertData..COelec a
	JOIN dissertData..COelec b
		ON a.cd = b.county
	WHERE b.year = 2008 AND a.cd IS NOT NULL

--UPDATE dissertData..elections SET elections.cd = 3
--	WHERE elections.cd IS NULL
--		AND elections.county = 'ALAMOSA'

SELECT DISTINCT county, cd
	FROM dissertData..COelec
		WHERE COelec.year = 2004
		ORDER BY county, cd
SELECT COUNT(*) FROM dissertData..COelec GROUP BY COelec.year ORDER BY COelec.year

--GA
--DROP TABLE dissertData..GAelec
SELECT elections.year,
		elections.cd,
		elections.county,
		elections.precinct,
		elections.ld,
		elections.sd
	INTO dissertData..GAelec
	FROM dissertData..elections
		WHERE elections.state = 'GA'

select * from dissertdata..GAelec where county = 'Appling' or county = 'Appling County' order by year, precinct