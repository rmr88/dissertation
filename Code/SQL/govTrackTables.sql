---------------------
--  dissertData Data  --
---------------------

--Robbie Richards, 11/16/15


---  Make DB, Base Tables  ---

CREATE DATABASE dissertData

--XML Tables
--DROP TABLE dissertData..billsXML
CREATE TABLE dissertData..billsXML (
	fileName VARCHAR(100),
	congress INT,
	bills XML)

--DROP TABLE dissertData..rollsXML
CREATE TABLE dissertData..rollsXML (
	fileName VARCHAR(100),
	congress INT,
	rolls XML)

--DROP TABLE dissertData..peopleXML
CREATE TABLE dissertData..peopleXML (
	congress INT,
	people XML)

/*
--This code changes system settings to allow the usp_uploadfiles query to run. It should only need to be run once.
use master
go
sp_configure 'show advanced options', 1
reconfigure with override
go
sp_configure 'xp_cmdshell', 1
reconfigure with override
*/

--Bulk Inserting into XML tables; warning: this section takes over 14 hours to run.
--TRUNCATE TABLE dissertData..rollsXML
--TRUNCATE TABLE dissertData..billsXML
DECLARE @Path VARCHAR(200),
	@Congress VARCHAR(3),
	@Blobcolumn VARCHAR(10),
	@Table VARCHAR(13),
	@cong INT

SET @cong = 93

WHILE @cong <= 113
BEGIN
	SET @Congress = CAST(@cong AS VARCHAR)
	SET @Blobcolumn = 'rolls'
	SET @Table = @Blobcolumn + 'XML'
	SET @Path = 'c:\Users\Robbie\Documents\dissertation\Data\dissertData\' + @Congress + '\' + @Blobcolumn + '\'

	EXEC dissertData..[usp_uploadfiles]
		@databasename ='dissertData',
		@schemaname ='dbo',
		@tablename = @Table,
		@FileNameColumn ='fileName',
		@CongressColumn = 'congress',
		@blobcolumn = @Blobcolumn,
		@congress = @Congress,
		@path = @Path,
		@filetype ='*.xml',
		@printorexec ='exec'

	SET @Blobcolumn = 'bills'
	SET @Table = @Blobcolumn + 'XML'
	SET @Path = 'c:\Users\Robbie\Documents\dissertation\Data\dissertData\' + @Congress + '\' + @Blobcolumn + '\'

	EXEC dissertData..[usp_uploadfiles]
		@databasename ='dissertData',
		@schemaname ='dbo',
		@tablename = @Table,
		@FileNameColumn ='fileName',
		@CongressColumn = 'congress',
		@blobcolumn = @Blobcolumn,
		@congress = @Congress,
		@path = @Path,
		@filetype ='*.xml',
		@printorexec ='exec'

	SET @cong = @cong + 1
END

--People.xml Data Import
--TRUNCATE TABLE dissertData..peopleXML
DECLARE @cong2 INT,
	@Congress2 VARCHAR(3),
	@Path2 VARCHAR(MAX),
	@sql VARCHAR(MAX)

SET @cong2 = 93

WHILE @cong2 <= 113
BEGIN
	SET @Congress2 = CAST(@cong2 AS VARCHAR)
	SET @Path2 = 'C:\Users\Robbie\Documents\dissertation\Data\dissertData\' + @Congress2 + '\people.xml'
	SET @sql = 'UPDATE dissertData.dbo.peopleXML SET people =
		(SELECT * FROM OPENROWSET(BULK ''' + @Path2 + ''', SINGLE_BLOB) AS x )
		WHERE congress = ' + @Congress2

	INSERT INTO dissertData.dbo.peopleXML (congress) VALUES (@cong2)
	EXEC(@sql)

	SET @cong2 = @cong2 + 1
END


--- Flattening Roll Call XML Data  ---

--Flatten roll call XML data (vote-level) into its own table
--DROP TABLE dissertData..rolls
SELECT rolls.value('(/roll/category)[1]', 'VARCHAR(MAX)') AS category,
		rolls.value('(/roll/type)[1]', 'VARCHAR(MAX)') AS type,
		rolls.value('(/roll/question)[1]', 'VARCHAR(MAX)') AS question,
		rolls.value('(/roll/required)[1]', 'VARCHAR(MAX)') AS "required",
		rolls.value('(/roll/result)[1]', 'VARCHAR(MAX)') AS result,
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
	INTO dissertData..rolls
	FROM dissertData..rollsXML
--will need to use type column to infer the category for early congresses (probably all those for which category is unknown, or for which source is "keithpoole")

--Flatten legislator-vote level roll call data into table
--DROP TABLE dissertData..rollsVotes
SELECT rolls.value('(/roll/@where)[1]', 'VARCHAR(6)') AS "where",
		rolls.value('(/roll/@session)[1]', 'INT') AS congress,
		rolls.value('(/roll/@year)[1]', 'INT') AS "year",
		rolls.value('(/roll/@roll)[1]', 'INT') AS rollNum,
		CAST(CAST(r.query('data(@id)') AS VARCHAR) AS BIGINT) AS voterID,
		CAST(r.query('data(@vote)') AS VARCHAR) AS vote
	INTO dissertData..rollsVotes
	FROM dissertData..rollsXML CROSS APPLY rolls.nodes('/roll/voter') rollsCross(r)


---  Flattening Bill XML Data  ---

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		bills.value('(/bill/@updated)[1]', 'VARCHAR(30)') AS updated,
		bills.value('(/bill/state)[1]', 'VARCHAR(40)') AS lastStatus,
		bills.value('(/bill/state/@datetime)[1]', 'VARCHAR(30)') AS lastStatusDate,
		bills.value('(/bill/introduced/@datetime)[1]', 'VARCHAR(30)') AS introDate,
		bills.value('(/bill/sponsor/@id)[1]', 'BIGINT') AS sponsorID
	INTO dissertData..bills
	FROM dissertData..billsXML

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(CAST(b.query('data(@id)') AS VARCHAR) AS BIGINT) AS cosponsorID,
		CAST(b.query('data(@joined)') AS VARCHAR) AS dateJoined
	INTO dissertData..billsCosponsors
	FROM dissertData..billsXML CROSS APPLY bills.nodes('/bill/cosponsors/cosponsor') billsCross(b)

--DROP TABLE dissertData..billsActions
SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@datetime)') AS VARCHAR) AS dateAction,
		CAST(b.query('data(@state)') AS VARCHAR) AS "state",
		CAST(b.query('data(text)') AS VARCHAR(MAX)) AS actionText
	INTO dissertData..billsActions
	FROM dissertData..billsXML CROSS APPLY bills.nodes('/bill/actions/action') billsCross(b)

--DROP TABLE dissertData..billsVotes
SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@datetime)') AS VARCHAR) AS dateAction,
		CAST(b.query('data(@state)') AS VARCHAR(MAX)) AS "state",
		CAST(b.query('data(text)') AS VARCHAR(MAX)) AS actionText,
		CAST(b.query('data(@how)') AS VARCHAR(MAX)) AS how,
		CAST(b.query('data(@type)') AS VARCHAR) AS actType,
		CAST(CAST(b.query('data(@roll)') AS VARCHAR) AS INT) rollNum,
		CAST(b.query('data(@where)') AS VARCHAR) AS "where",
		CAST(b.query('data(@result)') AS VARCHAR) AS result
	INTO dissertData..billsVotes
	FROM dissertData..billsXML CROSS APPLY bills.nodes('/bill/actions/vote') billsCross(b)

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@code)') AS VARCHAR) AS committeeCode
	INTO dissertData..billsCommittees
	FROM dissertData..billsXML CROSS APPLY bills.nodes('/bill/committees/committee') billsCross(b)
--need to get committee code names/ definitions for a smaller table to join in as needed

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@relation)') AS VARCHAR) AS relation,
		CAST(CAST(b.query('data(@session)') AS VARCHAR) AS INT) AS otherCongress,
		CAST(b.query('data(@type)') AS VARCHAR) AS otherBillType,
		CAST(CAST(b.query('data(@number)') AS VARCHAR) AS BIGINT) AS otherBillNum
	INTO dissertData..billsRelated
	FROM dissertData..billsXML CROSS APPLY bills.nodes('/bill/relatedbills/bill') billsCross(b)

SELECT bills.value('(/bill/@session)[1]', 'INT') AS congress,
		bills.value('(/bill/@type)[1]', 'VARCHAR(10)') AS billType,
		bills.value('(/bill/@number)[1]', 'INT') AS billNum,
		CAST(b.query('data(@number)') AS VARCHAR) AS amendNum
	INTO dissertData..billsAmendments
	FROM dissertData..billsXML CROSS APPLY bills.nodes('/bill/amendments/amendment') billsCross(b)


---  Flattening People XML Data  ---

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
	INTO dissertData..people
	FROM dissertData..peopleXML CROSS APPLY people.nodes('/people/person') peopleCross(p)

/*
--Do I need any of this data? could join it in later if necessary
people.value('(/people/@session)[1]', 'INT') AS congress,
CAST(p.query('data(role/@startdate)[1]') AS VARCHAR(MAX)) AS startDate,
CAST(p.query('data(role/@enddate)[1]') AS VARCHAR(MAX)) AS endDate,
CAST(p.query('data(role/@party)[1]') AS VARCHAR(MAX)) AS party
*/


---  Altering Tables  ---

UPDATE dissertData..rolls
	SET rolls.category = 'passage'
	WHERE (rolls.type = 'On Passage'
			OR rolls.type = 'On Passage of the Bill'
			OR rolls.type = 'On the Resolution'
			OR rolls.type = 'On the Conference Report'
			OR SUBSTRING(UPPER(rolls.type), 1, 33) = 'TO AGREE TO THE CONFERENCE REPORT')
		AND rolls.category = 'unknown'
UPDATE dissertData..rolls
	SET rolls.category = 'passage-suspension'
	WHERE (SUBSTRING(UPPER(rolls.type), 1, 29) = 'TO SUSPEND THE RULES AND PASS'
			OR SUBSTRING(UPPER(rolls.type), 1, 39) = 'ON MOTION TO SUSPEND THE RULES AND PASS'
			OR SUBSTRING(UPPER(rolls.type), 1, 40) = 'ON MOTION TO SUSPEND THE RULES AND AGREE')
		AND rolls.category = 'unknown'
UPDATE dissertData..rolls
	SET rolls.category = 'amendment'
	WHERE rolls.type = 'On the Amendment'
		AND rolls.category = 'unknown'
UPDATE dissertData..rolls
	SET rolls.category = 'cloture'
	WHERE SUBSTRING(UPPER(rolls.type), 1, 17) = 'TO INVOKE CLOTURE'
		AND rolls.category = 'unknown'
