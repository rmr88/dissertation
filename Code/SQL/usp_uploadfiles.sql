USE [govTrack]
GO
/****** Object:  StoredProcedure [dbo].[usp_uploadfiles]    Script Date: 11/13/2015 10:05:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER procedure [dbo].[usp_uploadfiles] 
@databasename varchar(128),
@schemaname varchar(128),
@tablename varchar(128),
@FileNameColumn varchar(128),
@CongressColumn varchar(128),
@blobcolumn varchar(128),
@congress varchar(3),
@path varchar(500), 
@filetype varchar(10),
@printorexec varchar(5) = 'print'
as
set nocount on
declare @dircommand varchar(1500)
declare @insertquery varchar(2000)
declare @updatequery varchar(2000)
declare @count int
declare @maxcount int
declare @filename varchar(500)
set @count=1
set @dircommand = 'dir /b '+@path+@filetype
create table #dir (name varchar(1500))
insert #dir(name) exec master..xp_cmdshell @dircommand
delete from #dir where name is NULL
create table #dir2 (id int identity(1,1),name varchar(1500))
insert into #dir2 select name from #dir
--select * from #dir2
set @maxcount = ident_current('#dir2')

while @count <=@maxcount
begin
set @filename =(select name from #dir2 where id = @count)
set @insertquery = 'Insert into ['+@databasename+'].['+@schemaname+'].['+@tablename+'] ([' +@filenamecolumn +'], [' +@CongressColumn +']) values ("'+@filename+'", '+@congress+')'
set @updatequery = 'update ['+@databasename+'].['+@schemaname+'].['+@tablename+'] set ['+@blobcolumn+'] = (SELECT *    FROM OPENROWSET(BULK "'+@path+@filename+'", SINGLE_BLOB)AS x ) WHERE ['+@filenamecolumn +']="'+@filename+'"'
if @printorexec ='print'
begin
print @insertquery
print @updatequery
end

if @printorexec ='exec'
begin
exec (@insertquery)
exec (@updatequery)
end

set @count = @count +1
end
