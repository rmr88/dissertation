---------------------------
--  State Results Table  --
---------------------------

--Robbie Richards, 3/17/16

--Create Table, load data
--DROP TABLE dissertData..stateResults
CREATE TABLE dissertData..stateResults (
	state CHAR(2),
	year INT,
	geographyType VARCHAR(10),
	candName VARCHAR(MAX),
	office VARCHAR(MAX),
	district VARCHAR(MAX),
	party VARCHAR(MAX),
	locationName VARCHAR(MAX),
	votes BIGINT,
	votesPerc FLOAT)

BULK INSERT dissertData..stateResults
	FROM 'C:\Users\Robbie\Documents\dissertation\data\elections\stateResults\stateResults.txt'
	WITH (FIELDTERMINATOR = '\t', FIRSTROW = 2)

--Delete unnecessary rows
DELETE FROM dissertData..stateResults
	WHERE stateResults.locationName LIKE '%Total%'
		OR stateResults.candName LIKE '%Total%'
		OR stateResults.office = 'Votes Cast'
		OR stateResults.office = 'Voting Statistics'
		OR stateResults.office = 'Registered Voters'
		OR stateResults.office LIKE '%district%'
		OR stateResults.office LIKE '%shall%'
		OR stateResults.office LIKE '%initiative&'
		OR stateResults.office IS NULL
		OR stateResults.party = 'NOP' --takes care of an issue with some of the FL data.
		OR (stateResults.office = 'TRE' AND stateResults.locationName = 'CarsonCity' AND stateResults.party = 'NP') --One part of NV scraping code mistakenly identified two state treasurer races in Carson City.

--Change negative votes to 0
UPDATE dissertData..stateResults SET stateResults.votes = 0
	WHERE stateResults.votes < 0

--Standardize major party names
UPDATE dissertData..stateResults SET stateResults.party = 'REP'
	WHERE stateResults.party = 'Republican Party'
		OR stateResults.party = 'Republican'
		OR stateResults.party = 'Rupublican'
		OR stateResults.party = 'Republican ( Unopposed)'
		OR stateResults.party = 'Republican( Unopposed)'
		OR stateResults.party = 'Reupublican( Unopposed)'
		OR stateResults.party = 'R'
		OR stateResults.party = '(R)'
		OR stateResults.party = 'REP2'

UPDATE dissertData..stateResults SET stateResults.party = 'DEM'
	WHERE stateResults.party = 'Democratic Party'
		OR stateResults.party = 'Democrat'
		OR stateResults.party = 'Democratic'
		OR stateResults.party = 'Democrat ( Unopposed)'
		OR stateResults.party = 'D'
		OR stateResults.party = '(D)'
		OR stateResults.party = 'Deomorat'
		OR stateResults.party = 'Democat'
		OR stateResults.party = 'Democatic'

--Standardize important office names
UPDATE dissertData..stateResults SET stateResults.office = 'AUD'
	WHERE stateResults.office = 'Audidtor'
		OR stateResults.office = 'Auditor'
		OR stateResults.office = 'Auditor of State'
		OR stateResults.office = 'AUDITOR/RECORDER'
		OR stateResults.office = 'RECORDER AND AUDITOR'
		OR stateResults.office = 'RECORDER/AUDITOR'
		OR stateResults.office = 'RECORDER'
		OR stateResults.office LIKE 'State Auditor%'

UPDATE dissertData..stateResults SET stateResults.office = 'ATG'
	WHERE stateResults.office = 'Attourney General'
		OR stateResults.office = 'STATE ATTORNEY'
		OR stateResults.office = 'State''s Attorney'

UPDATE dissertData..stateResults SET stateResults.office = 'Super'
	WHERE stateResults.office = 'Supt of Publ Instr'
		OR stateResults.office = 'Supt Pub Instr'
		OR stateResults.office = 'Supt. of Pub. Inst.'
		OR stateResults.office = 'Supt. of Public Instruction- Candidate 1'
		OR stateResults.office = 'Supt. of Public Instruction- Candidate 2'
		OR stateResults.office = 'COMMISSIONER OF EDUCATION'

UPDATE dissertData..stateResults SET stateResults.office = 'ComLand'
	WHERE stateResults.office = 'ComLands'
		OR stateResults.office = 'Commissioner of State Lands'
		OR stateResults.office = 'Land Commissioner'
		OR stateResults.office LIKE 'Commissioner of Public Lands%'

UPDATE dissertData..stateResults SET stateResults.office = 'ComAg'
	WHERE stateResults.office = 'COMMISSIONER OF AGRICULTURE'
		OR stateResults.office = 'SecAg'
		OR stateResults.office = 'Secretary of Agriculture'

UPDATE dissertData..stateResults SET stateResults.office = 'SOS'
	WHERE stateResults.office = 'Sec of State'
		OR stateResults.office = 'Secretary of  State'
		OR stateResults.office = 'Secretary of State'

UPDATE dissertData..stateResults SET stateResults.office = 'ComIns'
	WHERE stateResults.office = 'Commissioner of Insurance'
		OR stateResults.office LIKE 'Insurance Commissioner%'

UPDATE dissertData..stateResults SET stateResults.office = 'CON'
	WHERE stateResults.office = 'Controller'
		OR stateResults.office = 'Comptroller'
		OR stateResults.office = 'STATE CONTROLLER'

UPDATE dissertData..stateResults SET stateResults.office = 'TRE'
	WHERE stateResults.office = 'Treasurer'

--Testing
--SELECT stateResults.office, COUNT(*) AS 'count' FROM dissertData..stateResults
--	WHERE stateResults.office LIKE '%district%'
--	GROUP BY stateResults.office
--	ORDER BY stateResults.office
--
--SELECT stateResults.geographyType, COUNT(*)
--	FROM dissertData..stateResults
--	WHERE stateResults.geographyType IS NOT NULL
--	GROUP BY stateResults.geographyType
--
--SELECT DISTINCT stateResults.state
--	FROM dissertData..stateResults
--	WHERE stateResults.geographyType = 'precinct'
