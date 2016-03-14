SELECT state, year, ed_precinct, precinct, ed,
		g_GOV_tv, g_GOV_dv, g_GOV_rv,
		g_STH_tv, g_STH_dv, g_STH_rv,
		g_STS_tv, g_STS_dv, g_STS_rv,
		g_USH_tv, g_USH_dv, g_USH_rv,
		g_USS_tv, g_USS_dv, g_USS_rv
	FROM dissertData..elections
	WHERE state = '"AK"' and year = 2002
	order by ed, ed_precinct

SELECT state,
		year,
		ed_precinct,
		precinct,
		ed,
		precinct_code,
		g_STS_dv,
		g_STS_rv,
		g_STS_dv+g_STS_rv AS STStwoPty,
		g_STS_dv/(g_STS_dv+g_STS_rv) AS demMargin,
		g_STS_rv/(g_STS_dv+g_STS_rv) AS repMargin
	FROM dissertData..elections
	WHERE state = '"AK"'
		AND year = 2004
		AND (g_STS_dv IS NOT NULL OR g_STS_rv IS NOT NULL)
		AND (g_STS_dv > 0 OR g_STS_rv > 0)
	ORDER BY precinct_code