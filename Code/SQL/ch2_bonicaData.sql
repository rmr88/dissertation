------------------------------
--  Ch 2 Contribution Data  --
------------------------------

--Robbie Richards, 8/16/16
--See bonicaDataTables, code file in gun project, for table creation statements.

--Explore contributor codes
SELECT contrib.contributor_category_order,
		COUNT(contrib.contributor_category_order) AS count
	FROM bonica..contrib
	GROUP BY contrib.contributor_category_order
	ORDER BY contrib.contributor_category_order
--Looks like we want all the H categories (H01-H05).
--	H01- Health professionals
--	H02- Hospitals/ nursing homes, etc.
--	H03- Payers/ HMOs
--	H04- Pharma, devices, etc.
--	H05- Misc? May not end up using this one.

SELECT recip.icpsrID2 AS icpsrID,
		recip.mcName,
		recip.cycle AS year,
		recip.bonica_rid AS rid,
		contrib.contributor_category_order AS cat,
		SUM(contrib.amount) AS totalAmount
	FROM bonica..contrib
	RIGHT JOIN bonica..recip
		ON contrib.bonica_rid = recip.bonica_rid
			AND contrib.cycle = recip.cycle
	WHERE SUBSTRING(contrib.contributor_category_order, 1, 1) = 'H'
	GROUP BY recip.bonica_rid,
		recip.icpsrID2,
		contrib.contributor_category_order,
		recip.cycle,
		recip.mcName