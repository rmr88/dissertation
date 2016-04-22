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
