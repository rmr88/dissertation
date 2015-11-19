-----------------------------------
--  Policy Agendas Project Data  --
-----------------------------------

--Robbie Richards, 11/16/15


--- Bill Topics  ---

--CREATE DATABASE dissertData

--DROP TABLE dissertData..polAgendas
CREATE TABLE dissertData..polAgendas (
	papID VARCHAR(10),
	billID VARCHAR(20),
	billNum	SMALLINT,
	billType VARCHAR(10),
	byReq BIT,
	chamber BIT,
	commem BIT,
	congress SMALLINT,
	cosponsr SMALLINT,
	intrDate VARCHAR(20),
	oldMajor INT,
	oldMinor INT,
	major INT,
	minor INT,
	month TINYINT,
	mult BIT,
	multNo TINYINT,
	passH BIT,
	passS BIT,
	pLaw BIT,
	pLawDate VARCHAR(20),
	pLawNum VARCHAR(20),
	private BIT,
	referArr VARCHAR(90),
	reportH BIT,
	reportS BIT,
	title VARCHAR(MAX),
	veto BIT,
	year SMALLINT,
	age TINYINT,
	class VARCHAR(5),
	comC BIT,
	comMArr VARCHAR(20),
	comR BIT,
	cumHServ VARCHAR(20),
	cumSServ VARCHAR(20),
	delegate BIT,
	district TINYINT,
	dw1 FLOAT(24),
	dw2 FLOAT(24),
	frstConH TINYINT,
	frstConS TINYINT,
	gender BIT,
	leadCham BIT,
	leadComm BIT,
	leadSubC BIT,
	majority BIT,
	memberID VARCHAR(30),
	mRef BIT,
	nameFirst VARCHAR(30),
	nameFull VARCHAR(MAX),
	nameLast VARCHAR(40),
	party SMALLINT,
	pooleID VARCHAR(10),
	postal CHAR(2),
	state TINYINT,
	url VARCHAR(90),
	chRef SMALLINT,
	rankRef BIT,
	subChRef BIT,
	subRankRef BIT)
--need to fix plawdate and plawnum columns; switched in the two files

BULK INSERT dissertData..polAgendas
	FROM 'C:\Users\Robbie\Documents\dissertation\data\PolicyAgendasProject\billsPAP.txt'
	WITH (FIELDTERMINATOR = '\t', FIRSTROW = 2)


---  Roll Call Topics  ---

--DROP TABLE dissertData..papRolls
CREATE TABLE dissertData..papRolls (
	keyID INT,
	prCount INT,
	chamber TINYINT,
	rcCount INT,
	sessCount INT,
	bill VARCHAR(20),
	month TINYINT,
	day TINYINT,
	year SMALLINT,
	congress TINYINT,
	session TINYINT,
	yeas SMALLINT,
	nays SMALLINT,
	presSupport TINYINT,
	name VARCHAR(MAX),
	state VARCHAR(5),
	party VARCHAR(10),
	description VARCHAR(MAX),
	govTrackURL VARCHAR(MAX),
	major SMALLINT,
	minor SMALLINT,
	capMajor SMALLINT,
	capMinor SMALLINT,
	nom1sprd FLOAT(24),
	nom1mid FLOAT(24),
	nom2sprd FLOAT(24),
	nom2mid FLOAT(24),
	cong2 TINYINT)

BULK INSERT dissertData..papRolls
	FROM 'C:\Users\Robbie\Documents\dissertation\data\PolicyAgendasProject\Roll_Call_Votes_LegacyVersion_mod.txt'
	WITH (FIELDTERMINATOR = '\t', FIRSTROW = 2)


---  Edit Tables (for IDs)  ---

ALTER TABLE dissertData..papRolls
	ADD billType VARCHAR(2),
		billNum INT,
		"where" CHAR(6)

UPDATE dissertData..papRolls
	SET "where" = 'house' WHERE chamber = 1
UPDATE dissertData..papRolls
	SET "where" = 'senate' WHERE chamber = 2

UPDATE dissertData..papRolls
	SET billType = 'h',
		billNum = CAST(SUBSTRING(bill, 3, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 2) = 'HR'
		AND SUBSTRING(bill, 1, 4) != 'HRES'
UPDATE dissertData..papRolls
	SET billType = 'hr',
		billNum = CAST(SUBSTRING(bill, 5, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 4) = 'HRES'
UPDATE dissertData..papRolls
	SET billType = 'hj',
		billNum = CAST(SUBSTRING(bill, 6, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 5) = 'HJRES'
UPDATE dissertData..papRolls
	SET billType = 'hc',
		billNum = CAST(SUBSTRING(bill, 8, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 7) = 'HCONRES'
UPDATE dissertData..papRolls
	SET billType = 's',
		billNum = CAST(SUBSTRING(bill, 2, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 1) = 'S'
		AND SUBSTRING(bill, 1, 4) != 'SRES'
		AND SUBSTRING(bill, 1, 5) != 'SJRES'
		AND SUBSTRING(bill, 1, 7) != 'SCONRES'
UPDATE dissertData..papRolls
	SET billType = 'sr',
		billNum = CAST(SUBSTRING(bill, 5, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 4) = 'SRES'
UPDATE dissertData..papRolls
	SET billType = 'sj',
		billNum = CAST(SUBSTRING(bill, 6, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 5) = 'SJRES'
UPDATE dissertData..papRolls
	SET billType = 'sc',
		billNum = CAST(SUBSTRING(bill, 8, 50) AS INT)
	WHERE SUBSTRING(bill, 1, 7) = 'SCONRES'

