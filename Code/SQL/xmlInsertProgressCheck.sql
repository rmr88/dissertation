--Use these to check the progress of the loop in govTrackXMLtables.sql:
SELECT billsXML.congress, COUNT(billsXML.congress) AS bills FROM govTrack..billsXML GROUP BY billsXML.congress ORDER BY billsXML.congress
SELECT rollsXML.congress, COUNT(rollsXML.congress) AS rolls FROM govTrack..rollsXML GROUP BY rollsXML.congress ORDER BY rollsXML.congress

/*
--If the table creation program stops early, delete the last (incomplete) congress and start the loop over with that one.
DELETE FROM govTrack..billsXML WHERE billsXML.congress = 99
DELETE FROM govTrack..rollsXML WHERE rollsXML.congress = 99
*/