--- Roll Call Topics, Votes ---

--Robbie Richards, 4/15/16


--DROP TABLE dissertData..rollVotes
CREATE TABLE dissertData..rollVotes (
	cong SMALLINT,
	rollid CHAR(15),
	legisid BIGINT,
	billid CHAR(16),
	vote TINYINT,
	roll_major SMALLINT,
	roll_minor SMALLINT,
	bill_major SMALLINT,
	bill_minor SMALLINT)

BULK INSERT dissertData..rollVotes
	FROM 'C:\Users\Robbie\Documents\dissertation\Data\rollVotes.txt'
	WITH (FIELDTERMINATOR = '\t', FIRSTROW = 2)

--Sample SELECT statements:
--SELECT cong, legisid, rollid, vote FROM dissertData..rollVotes WHERE roll_major = 3

--SELECT * FROM dissertData..rollVotes WHERE legisid IS NULL AND vote IS NOT NULL

--SELECT DISTINCT rollid from dissertData..rollVotes WHERE roll_major = 3 AND cong = 111