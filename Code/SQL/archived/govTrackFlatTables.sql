-------------------------
-- Flattening XML Data --
-------------------------

--Robbie Richards, 11/12/15

--Flatten roll call XML data (vote-level) into its own table
--DROP TABLE govTrack..rolls
SELECT rolls.value('(/roll/category)[1]', 'VARCHAR(100)') AS category,
		rolls.value('(/roll/type)[1]', 'VARCHAR(100)') AS type,
		rolls.value('(/roll/question)[1]', 'VARCHAR(100)') AS question,
		rolls.value('(/roll/required)[1]', 'VARCHAR(100)') AS "required",
		rolls.value('(/roll/result)[1]', 'VARCHAR(100)') AS result,
		rolls.value('(/roll/@where)[1]', 'VARCHAR(6)') AS "where",
		rolls.value('(/roll/@session)[1]', 'INT') AS congress,
		rolls.value('(/roll/@year)[1]', 'INT') AS "year",
		rolls.value('(/roll/@roll)[1]', 'INT') AS rollNum,
		rolls.value('(/roll/@source)[1]', 'VARCHAR(20)') AS "source",
		rolls.value('(/roll/@datetime)[1]', 'VARCHAR(30)') AS dateRecorded,
		rolls.value('(/roll/@updated)[1]', 'VARCHAR(30)') AS dateUpdated,
		rolls.value('(/roll/@aye)[1]', 'INT') AS aye,
		rolls.value('(/roll/@nay)[1]', 'INT') AS nay,
		rolls.value('(/roll/@nv)[1]', 'INT') AS nv,
		rolls.value('(/roll/@present)[1]', 'INT') AS present
	INTO govTrack..rolls
	FROM govTrack..rollsXML
--will need to use type column to infer the category for early congresses (probably all those for which category is unknown, or for which source is "keithpoole")

--Flatten legislator-vote level roll call data into table
--DROP TABLE govTrack..rollsVotes
SELECT rolls.value('(/roll/@where)[1]', 'VARCHAR(6)') AS "where",
		rolls.value('(/roll/@session)[1]', 'INT') AS congress,
		rolls.value('(/roll/@year)[1]', 'INT') AS "year",
		rolls.value('(/roll/@roll)[1]', 'INT') AS rollNum,
		CAST(CAST(r.query('data(@id)') AS VARCHAR) AS BIGINT) AS voterID,
		CAST(r.query('data(@vote)') AS VARCHAR) AS vote
	INTO govTrack..rollsVotes
	FROM govTrack..rollsXML CROSS APPLY rolls.nodes('/roll/voter') rollsCross(r)

--Flatten bill data
SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'CHAR(1)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		bills.value('(/bill/@updated)[1]', 'VARCHAR(30)') AS updated,
		bills.value('(/bill/state)[1]', 'VARCHAR(40)') AS lastStatus,
		bills.value('(/bill/state/@datetime)[1]', 'VARCHAR(30)') AS lastStatusDate,
		bills.value('(/bill/introduced/@datetime)[1]', 'VARCHAR(30)') AS introDate,
		bills.value('(/bill/sponsor/@id)[1]', 'BIGINT') AS sponsorID
	INTO govTrack..bills
	FROM govTrack..billsXML

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'CHAR(1)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(CAST(b.query('data(@id)') AS VARCHAR) AS BIGINT) AS cosponsorID,
		CAST(b.query('data(@joined)') AS VARCHAR) AS dateJoined
	INTO govTrack..billsCosponsors
	FROM govTrack..billsXML CROSS APPLY bills.nodes('/bill/cosponsors/cosponsor') billsCross(b)


SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'CHAR(1)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@datetime)') AS VARCHAR) AS dateAction,
		CAST(b.query('data(@state)') AS VARCHAR) AS "state",
		CAST(b.query('data(text)') AS VARCHAR(MAX)) AS actionText
	INTO govTrack..billsActions
	FROM govTrack..billsXML CROSS APPLY bills.nodes('/bill/actions/action') billsCross(b)

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'CHAR(1)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@code)') AS VARCHAR) AS committeeCode
	INTO billsCommittees
	FROM govTrack..billsXML CROSS APPLY bills.nodes('/bill/committees/committee') billsCross(b)
--need to get committee code names/ definitions for a smaller table to join in as needed

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'CHAR(1)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@relation)') AS VARCHAR) AS relation,
		CAST(CAST(b.query('data(@session)') AS VARCHAR) AS INT) AS otherCongress,
		CAST(b.query('data(@type)') AS VARCHAR) AS otherBillType,
		CAST(CAST(b.query('data(@number)') AS VARCHAR) AS BIGINT) AS otherBillNum
	INTO govTrack..billsRelated
	FROM govTrack..billsXML CROSS APPLY bills.nodes('/bill/relatedbills/bill') billsCross(b)

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'CHAR(1)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@number)') AS VARCHAR) AS amendNum
	INTO govTrack..billsAmendments
	FROM govTrack..billsXML CROSS APPLY bills.nodes('/bill/amendments/amendment') billsCross(b)

--Flatten People Data
SELECT DISTINCT CAST(CAST(p.query('data(@id)') AS VARCHAR(MAX)) AS BIGINT) AS govTrackID,
		CAST(p.query('data(@lastname)') AS VARCHAR(MAX)) AS lastName,
		CAST(p.query('data(@firstname)') AS VARCHAR(MAX)) AS firstName,
		CAST(p.query('data(@namemod)') AS VARCHAR(MAX)) AS nameMod,
		CAST(p.query('data(@birthday)') AS VARCHAR(MAX)) AS birthday,
		CAST(p.query('data(@gender)') AS VARCHAR(MAX)) AS gender,
		CAST(p.query('data(@religion)') AS VARCHAR(MAX)) AS religion,
		CAST(CAST(p.query('data(@pvsid)') AS VARCHAR(MAX)) AS BIGINT) AS pvsID,
		CAST(p.query('data(@osid)') AS VARCHAR(MAX)) AS osID,
		CAST(p.query('data(@bioguideid)') AS VARCHAR(MAX)) AS bioGuideID,
		CAST(p.query('data(@metavidid)') AS VARCHAR(MAX)) AS metaVidID,
		CAST(p.query('data(@youtubeid)') AS VARCHAR(MAX)) AS youtubeID,
		CAST(p.query('data(@twitterid)') AS VARCHAR(MAX)) AS twitterID,
		CAST(CAST(p.query('data(@icpsrid)') AS VARCHAR(MAX)) AS BIGINT) AS icpsrID,
		CAST(p.query('data(@facebookgraphid)') AS VARCHAR(MAX)) AS facebookID,
		CAST(p.query('data(@thomasid)') AS VARCHAR(MAX)) AS thomasID,
		CAST(p.query('data(@name)') AS VARCHAR(MAX)) AS name,
		CAST(p.query('data(@title)') AS VARCHAR(MAX)) AS title,
		CAST(p.query('data(@state)') AS VARCHAR(MAX)) AS "state",
		CAST(CAST(p.query('data(@district)') AS VARCHAR(MAX)) AS INT) AS district
	INTO govTrack..people
	FROM govTrack..peopleXML CROSS APPLY people.nodes('/people/person') peopleCross(p)

/*
--Do I need any of this data? could join it in later if necessary
people.value('(/people/@session)[1]', 'INT') AS congress,
CAST(p.query('data(role/@startdate)[1]') AS VARCHAR(MAX)) AS startDate,
CAST(p.query('data(role/@enddate)[1]') AS VARCHAR(MAX)) AS endDate,
CAST(p.query('data(role/@party)[1]') AS VARCHAR(MAX)) AS party
*/
