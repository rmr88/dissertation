SELECT DISTINCT papRolls.chamber, papRolls."where" FROM dissertData..papRolls

SELECT DISTINCT billType, COUNT(*) FROM dissertData..bills GROUP BY bills.billType
SELECT DISTINCT billType, COUNT(*) FROM dissertData..papRolls GROUP BY papRolls.billType

SELECT TOP 1000 bill, billType FROM dissertData..papRolls WHERE billType = 'h'

SELECT TOP 1000 bill FROM dissertData..papRolls

SELECT bill FROM dissertData..papRolls WHERE papRolls.bill = 'S27'

SELECT bill, count(*) FROM dissertData..papRolls WHERE billType IS NULL GROUP BY bill

SELECT TOP 100 * FROM dissertData..billsVotes WHERE billsVotes.how != '' ORDER BY congress, billType, billNum, dateAction

SELECT p.congress,
		p.billType,
		p.billNum,
		p."where",
		p.rcCount,
		p.sessCount,
		r.rollNum,
		r.question,
		r.category,
		r.type
	FROM dissertData..rolls r
		INNER JOIN dissertData..papRolls p
			ON p.congress = r.congress
			AND p.rcCount = r.rollNum
			AND p."where" = r."where"
		WHERE p.billType IS NOT NULL
	ORDER BY p.congress, p."where", p.rcCount, r.congress

PRINT LEN('TO SUSPEND THE RULES AND PASS')
-- =29
PRINT LEN('TO SUSPEND THE RULES AND AGREE')
-- =30
PRINT LEN('ON MOTION TO SUSPEND THE RULES AND PASS')
-- =39
PRINT LEN('ON MOTION TO SUSPEND THE RULES AND AGREE')
-- =40
SELECT rolls.congress, rolls.category, rolls.type FROM dissertData..rolls ORDER BY rolls.congress, rolls.rollNum

SELECT rolls.congress, rolls.category, COUNT(rolls.type) FROM dissertData..rolls
	GROUP BY rolls.congress, rolls.category ORDER BY rolls.congress, rolls.category
--can analyze the trends over time by putting these results into stata, running the following:
/*
ren var1 cong
ren var2 type
ren var3 count
gen type4 = type if type == "amendment" | type == "passage" | type == "passage-suspension"
replace type4 = "unknown" if missing(type4)
collapse (sum) count, by(cong type4)
replace type4 = "ps" if type4 == "passage-suspension"
replace type4 = substr(type4, 1, 1) if type4 != "ps"
reshape wide count, i(cong) j(type4) str
line count* cong
pwcorr _all, sig
*/

SELECT rolls.congress, COUNT(*) FROM dissertData..rolls WHERE rolls.category = 'passage' OR rolls.category = 'passage-suspension' GROUP BY rolls.congress ORDER BY rolls.congress
SELECT DISTINCT SUBSTRING(rolls.type, 1, 40), rolls.category, COUNT(*) FROM dissertData..rolls GROUP BY SUBSTRING(rolls.type, 1, 40), rolls.category ORDER BY rolls.category ASC, COUNT(*) DESC

SELECT people.name,
		people.state,
		people.district,
		rollsVotes.congress,
		papRolls.billType,
		papRolls.billNum,
		rollsVotes.vote
	FROM dissertData..rollsVotes
		INNER JOIN dissertData..people
			ON rollsVotes.voterID = people.govTrackID
		LEFT JOIN dissertData..papRolls
			ON papRolls.rcCount = rollsVotes.rollNum
			AND papRolls.congress = rollsVotes.congress
	WHERE papRolls.billType IS NOT NULL --throws out of memory error