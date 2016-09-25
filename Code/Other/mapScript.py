import sys, os
import math
import arcpy

def roundDown(x):
	return int(math.floor(x / 10.0)) * 10

base = 'C:/Users/Robbie/Documents/dissertation/Data/cdShp'

for cong in range(97, 102, 1):
	year = roundDown(1788 + ((cong - 1) * 2))
	cdPath = base + '/cd%d/cd%d.shp' % (cong, cong)
	ctyPath = base + '/county%d/US_county_%d.shp' % (year, year)
	outPath = base + '/output%d' % cong

	if (os.path.exists(cdPath) and os.path.exists(ctyPath)):
		if not os.path.exists(outPath):
			os.makedirs(outPath)
		
		print "%d, %d" % (cong, year)
		out = outPath + "/%dcong_identified" % cong
		
		print "Geoprocessing..."
		arcpy.Identity_analysis(ctyPath, cdPath, out, "ALL", 500)
		
		arcpy.AddField_management(out+".dbf", "shapeArea", "DOUBLE")
		CursorFieldNames = ["SHAPE@AREA","shapeArea"]
		cursor = arcpy.da.UpdateCursor(out+".dbf",CursorFieldNames)
		
		print "Writing..."
		for row in cursor:
			row[1] = row[0] #Write area value to field
			cursor.updateRow(row)
			
		del row, cursor #Clean up cursor objects
	else:
		print "Not enough info to identify %d" % cong
