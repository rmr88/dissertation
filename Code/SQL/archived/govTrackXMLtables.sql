CREATE DATABASE govTrack

--DROP TABLE govTrack..billsXML
CREATE TABLE govTrack..billsXML (
	fileName VARCHAR(100),
	congress INT,
	bills XML)

--DROP TABLE govTrack..rollsXML
CREATE TABLE govTrack..rollsXML (
	fileName VARCHAR(100),
	congress INT,
	rolls XML)

--DROP TABLE govTrack..peopleXML
CREATE TABLE govTrack..peopleXML (
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

--TRUNCATE TABLE govTrack..rollsXML
--TRUNCATE TABLE govTrack..billsXML
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
	SET @Path = 'c:\Users\Robbie\Documents\dissertation\Data\GovTrack\' + @Congress + '\' + @Blobcolumn + '\'

	EXEC govTrack..[usp_uploadfiles]
		@databasename ='govTrack',
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
	SET @Path = 'c:\Users\Robbie\Documents\dissertation\Data\GovTrack\' + @Congress + '\' + @Blobcolumn + '\'

	EXEC govTrack..[usp_uploadfiles]
		@databasename ='govTrack',
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

--TRUNCATE TABLE govTrack..peopleXML
DECLARE @cong2 INT,
	@Congress2 VARCHAR(3),
	@Path2 VARCHAR(MAX),
	@sql VARCHAR(MAX)

SET @cong2 = 93

WHILE @cong2 <= 113
BEGIN
	SET @Congress2 = CAST(@cong2 AS VARCHAR)
	SET @Path2 = 'C:\Users\Robbie\Documents\dissertation\Data\GovTrack\' + @Congress2 + '\people.xml'
	SET @sql = 'UPDATE govTrack.dbo.peopleXML SET people =
		(SELECT * FROM OPENROWSET(BULK ''' + @Path2 + ''', SINGLE_BLOB) AS x )
		WHERE congress = ' + @Congress2

	INSERT INTO govTrack.dbo.peopleXML (congress) VALUES (@cong2)
	EXEC(@sql)

	SET @cong2 = @cong2 + 1
END
