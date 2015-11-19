SELECT TOP 100
	rolls.fileName,
	rolls.query('/roll/result') AS result
FROM govTrack..rolls