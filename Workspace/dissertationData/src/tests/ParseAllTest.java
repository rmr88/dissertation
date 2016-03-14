package tests;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import utilities.CandidateData;
import utilities.ElectionData;
import utilities.InFile;
import utilities.OutFile;
import utilities.State;

public class ParseAllTest
{
	private State state;
	private OutFile out = null;
	private Pattern partyPattern = Pattern.compile("^(.*?(,\\s|[\\s]?-\\s|\\s?\\(){1}([a-zA-Z\\s]+)\\)?"
			+ "([\\s][w|W]inner)?)|(.*?\\s([D|d]emocrati?c?|[R|r]epublican|[I|i]ndependent|[A-Z]{3}))\"?$");
	
	public ParseAllTest(State st)
	{
		this.state = st;
		
		try
		{
			this.out = new OutFile(st.getPath() + "\\" + st.getState() + "_"
					+ st.getGeoType() + "_test.txt", false);
			this.out.writeLine("state\tyear\tgeographyType\tcandName\toffice\t"
					+ "district\tparty\tlocationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error in setting up output file.");
			e.printStackTrace();
		}
	}
	
	public void run(String year, File file)
	{
		String delimiter = "\t"; //TODO make sure this is determined correctly
		
		String office = "", fileName, location, district = "", county = "";
		String[] offices, candNames, parties, districts;

		fileName = file.getName();
		if (fileName.matches("^" + year + "[a-zA-Z]{3,}\\d*_.*$"))
		{
			office = fileName.substring(0, fileName.indexOf("_")).replace(year, "");
			if (office.matches("[\\D]{3,}\\d+"))
			{
				district = office.replaceAll("\\D", "");
				office = office.replaceAll("\\d", "");
			}
		}
		else if (file.getName().matches("^[a-zA-Z]+_" + year + "_.*"))
			county = file.getName().substring(0, file.getName().indexOf("_")+1);
		if (office.equals("stw")) office = "";
		
		ArrayList<CandidateData> data = new ArrayList<CandidateData>();
		
		HashMap<String, CandidateData> dictMap = this.processDictFile(year,
				new File(this.state.getPath() + "\\" + year + "_dict" + this.state.getFileType()));
		ArrayList<CandidateData> partyArr = this.getParties(new File(this.state.getPath()
				+ "\\parties.txt"));
		HashMap<String, Integer> districtCols = new HashMap<String, Integer>(); //for districts from dict-style parsing
		
		InFile in = null;
		try { in = new InFile(file); }
		catch (IOException e)
		{
			System.err.println("Error in opening " + file.getName());
			e.printStackTrace();
		}
		
		try
		{
			boolean lastOfficeRead = false;
			String[] line = in.readRowLite(delimiter);
			while (in.isReady() && !lastOfficeRead)
			{ //loop through offices, determining in the loop when all offices have been read
				if (!office.equals("") || !dictMap.isEmpty())
					lastOfficeRead = true;

				boolean haveData = false;
				ArrayList<String[]> topLines = new ArrayList<String[]>();
				
				while (in.isReady() && !haveData)
				{
					if (isHeader(line))
					{
						if (!(line.length == 1 && line[0].equals("")) //excludes blank lines
								&& !Arrays.toString(line).matches("^\\[, , PRECINCT, ([^a-z,]+,? ?)+\\]$")) //excludes AL's office key rows
							topLines.add(line);
						line = in.readRowLite(delimiter); //will have the first data line when the loop ends
					}
					else
						haveData = true;
				}

				int firstDataCol;
				if (dictMap.isEmpty())
				{ //if there is no separate dictionary file processed earlier:
					//Get candidate names, party from bottom line(s) of header
					while (Arrays.toString(topLines.get(topLines.size()-1)).matches("^\\[(, )+\\]$"))
						topLines.remove(topLines.size()-1);
					
					candNames = topLines.get(topLines.size()-1);
					topLines.remove(topLines.size()-1);
					
					if (Arrays.toString(candNames).toUpperCase().contains("TOTAL VOTES"))
					{
						String[] voteTypes = candNames;
						candNames = topLines.get(topLines.size()-1);
						candNames = fillEmptyForward(candNames);
						for (int col = 0; col < candNames.length; col++)
							if (!voteTypes[col].toUpperCase().contains("TOTAL VOTES"))
								candNames[col] = "";
					}
					
					parties = new String[candNames.length];
					if (!partyArr.isEmpty())
					{
						for (int col = 0; col < candNames.length; col++)
						{
							if (!candNames[col].equals(""))
							{
								int bestPtyMatchIndex = -1;
								int bestMatchScore = 0;
								int matchScore;
								for (int ptyIndex = 0; ptyIndex < partyArr.size(); ptyIndex++)
								{
									matchScore = partyArr.get(ptyIndex).
											partyCheckScore(candNames[col], Integer.parseInt(year),
											office.toUpperCase(), district);
									if (matchScore > bestMatchScore)
									{
										bestMatchScore = matchScore;
										bestPtyMatchIndex = ptyIndex;
									}
								}
								if (bestPtyMatchIndex < 0)
									parties[col] = "";
								else
									parties[col] = partyArr.get(bestPtyMatchIndex).getParty();
							}
							else
								parties[col] = "";
						}
					}
					
					if (isPartyRow(candNames) && numNotBlankInRow(parties) == 0)
					{
						parties = candNames;
						candNames = topLines.get(topLines.size()-1);
						topLines.remove(topLines.size()-1);
					}
					else if (containsParties(candNames) && numNotBlankInRow(parties) == 0)
					{
						for (int col = 0; col < candNames.length; col++)
						{
							if (candNames[col].matches("^.*\\(I\\)[A-Z]\"?$"))
								candNames[col] = candNames[col].replace("(I)", "(") + ")";
							
							Matcher m = this.partyPattern.matcher(candNames[col].replaceAll("\"", ""));
							if (m.matches())
							{
								if (m.group(3) != null)
									parties[col] = m.group(3); //party is in 3rd capturing group of Regex
								else
									parties[col] = m.group(6); //party is in 6th capturing group (if 3rd is null)
								
								if (m.group(2).equals("("))
									candNames[col] = candNames[col].replace("(" + parties[col] + ")", "");
								
								candNames[col] = candNames[col].replaceAll("[,\\(\\)\\-\"]", "").trim();
								if (candNames[col].endsWith(" " + parties[col]))
									candNames[col] = candNames[col].replace(" " + parties[col], "");
								
								if (candNames[col].toUpperCase().contains("WRITEIN"))
								{
									parties[col] = "WI";
									candNames[col] = candNames[col].replaceAll("Writein", "").trim();
								}
							}
							else
								parties[col] = "";
						}
					}
					else if (parties[0] == null)
						parties = fillArrayWithConstant("", parties.length, parties.length);

					//get office code from header rows, put in String[] offices
					if (containsOffices(candNames))
					{
						offices = candNames;
						candNames = new String[line.length];
						for (int col = 0; col < candNames.length; col++)
							candNames[col] = collectColToString(topLines, col);
						firstDataCol = firstNonBlankInRow(offices);
					} //not sure about this one in general...
					else if (office.equals(""))
					{
						offices = new String[line.length];
						for (int col = 0; col < offices.length; col++)
							offices[col] = collectColToString(topLines, col);
						if (offices[0].toUpperCase().contains("COUNTY"))
							offices[0] = "";
						firstDataCol = firstNonBlankInRow(offices);
					}
					else
					{
						offices = fillArrayWithConstant(office, line.length, 0);
						firstDataCol = firstNonBlankInRow(candNames);
						for (int col = 0; col < candNames.length; col++)
							candNames[col] += collectColToString(topLines, col);
					}
					
					districts = new String[line.length];
					if (!district.equals(""))
						districts = fillArrayWithConstant(district, districts.length, 0);
					else
					{
						for (int col = 0; col < districts.length; col++)
						{ //loop through columns to parse district and office information
							if ((offices[col].toUpperCase().contains("DIST")
									&& !offices[col].toUpperCase().contains("ATTORNEY"))
									|| offices[col].toUpperCase().contains("CIRCUIT"))
							{
								districts[col] = offices[col].replaceAll("\\D", "").trim();
								offices[col] = offices[col].toUpperCase()
										.replaceAll("DIST(RICT)?", "").replace("CIRCUIT", "")
										.replace(districts[col], "").trim();
							}
							else if (offices[col].toUpperCase().contains("PLACE")
									|| offices[col].toUpperCase().contains(" PL "))
							{
								districts[col] = offices[col].substring(offices[col]
										.toUpperCase().lastIndexOf("PL")).trim();
								offices[col] = offices[col].toUpperCase()
										.replace(districts[col], "").trim();
							}
							else if (offices[col].matches(".*\\d+.*"))
								districts[col] = offices[col].replaceAll("\\s", "_")
										.replaceAll("[\\D[^_]]", "").trim();
							else
								districts[col] = "";
							
							offices[col] = getOffice(offices[col]);
						} //end loop columns

						if (office.equals("STH") || office.equals("STS"))
						{
							lastOfficeRead = false;
							if (district.equals("") && this.state.getState().equals("ME"))
								districts[0] = line[0];
						}
					}
					
					fillEmptyForward(offices);
					fillEmptyForward(districts); //ends up filling ballot questions, bottom races, with last district used

					int tryFirstDataCol = 0;
					try { tryFirstDataCol = getFirstNumericCol(line); }
					catch (Exception e) { e.printStackTrace(); }
					if (tryFirstDataCol > firstDataCol) //TODO first data col not working in AL 1996
						firstDataCol = tryFirstDataCol;
					
					for (int col = firstDataCol; col < line.length; col++)
						data.add(new CandidateData(Integer.parseInt(year),
								this.state.getState(), this.state.getGeoType(), offices[col],
								candNames[col], parties[col].trim(), districts[col]));
				} //end no dict file
				else
				{ //if there was a dictionary file processed earlier:
					firstDataCol = 0;
					try { firstDataCol = getFirstNumericCol(line); }
					catch (Exception e) { e.printStackTrace(); }
					
					if (firstDataCol < 0)
					{
						haveData = false;
						continue;
					}
					
					candNames = topLines.get(topLines.size()-1);
					for (int col = firstDataCol; col < candNames.length; col++)
					{
						if (dictMap.containsKey(candNames[col]))
						{
							if (!dictMap.get(candNames[col]).getName().equals("")
									&& !dictMap.get(candNames[col]).getOffice().matches("^prop[0-9]+$"))
								data.add(dictMap.get(candNames[col]));
							else data.add(new CandidateData());
							
							if (dictMap.get(candNames[col]).getOffice().matches("[A-Z]{3,4}dist"))
							{
								districtCols.put(dictMap.get(candNames[col]).getOffice()
										.replace("dist", ""), Integer.parseInt(
												dictMap.get(candNames[col]).getParty()));
							}
						}
						else data.add(new CandidateData());
					}
				} //end dict file
				
				while (haveData)
				{ //process lines of data, adding to data array
					int col;
					location = county;
					
					for (col = 0; col < firstDataCol; col++)
						location += " " + line[col];
					location = location.trim();
					
					district = "";
					for (col = firstDataCol; col < line.length; col++)
					{
						if (districtCols.containsKey(data.get(col - firstDataCol).getOffice()))
							district = line[districtCols.get(data.get(col - firstDataCol).getOffice())];
						
						//save data
						if (!line[col].replaceAll("\\D", "").trim().equals("")
								&& !candNames[col].equals(""))
						{
							if (data.get(col - firstDataCol).getOffice() != null)
							{
								data.get(col - firstDataCol).addData(new ElectionData(location,
										Integer.parseInt(line[col].replaceAll("[\",\\s]", "")),
										-1.0, district));
							}
						}
					}
					
					if (in.isReady())
					{
						line = in.readRowLite(delimiter);
						if (isHeader(line)) // && numBlankInRow(line) < line.length - firstDataCol) //some states need both conditions (IA)
							haveData = false;
					}
					else
						haveData = false;
				} //end process lines
				try
				{
					for (CandidateData cand : data)
						if (cand.getName() != null && cand.getOffice() != null)
							this.out.write(cand.getRows());
				}
				catch (IOException e)
				{
					System.err.println("Error writing data to file for input file " + file.getName());
					e.printStackTrace();
				}
				data.clear();
			} //end loop through offices
		}
		catch (IOException e)
		{
			System.err.println("Unknown error in reading " + file.getName());
			e.printStackTrace();
		}
		in.close();
	} //end run method

	public void run(String year, File file, boolean transposed)
	{
		if (!transposed)
		{
			this.run(year, file);
			return;
		}
		
		String county;
		if (file.getName().contains("-"))
			county = file.getName().replaceAll(year + "|General|Precinct |Results.txt|-|_", "");
		else
			county = file.getName().substring(file.getName().lastIndexOf("_")+1)
					.replaceAll("\\.[a-zA-Z]+$", "");
		
		String[] line, locations;
		String office = "", district = "";
		int firstDataCol = 2; //TODO may need to make these ints dynamically determined
		int candCol = 0;
		int partyCol = 1;
		int officeCol = -1;
		
		InFile in = null;
		try { in = new InFile(file); }
		catch (IOException e)
		{
			System.err.println("Error in opening " + file.getName());
			e.printStackTrace();
		}
		
		try
		{ //try to read file
			line = in.readRowLite("\t");
			locations = new String[line.length];
			for (int col = 0; col < line.length; col++)
			{
				if (line[col].toUpperCase().contains("PARTY"))
					partyCol = col;
				else if (line[col].toUpperCase().contains("CONTEST")
						|| line[col].toUpperCase().contains("RACETITLE"))
					officeCol = col;
				else if (line[col].toUpperCase().contains("CANDIDATE"))
					candCol = col;
				else if (!line[col].toUpperCase().contains("COUNTY"))
					locations[col] = county + "_" + line[col].trim();
			}

			if (candCol >= firstDataCol || officeCol >= firstDataCol || partyCol >= firstDataCol)
				firstDataCol = Math.max(Math.max(candCol, officeCol), partyCol) + 1;
			
			//in.readLine(); //skip the second line of the file; no useful info; may need to make this dynamic
			while (in.isReady())
			{ //loop through lines of the file
				line = in.readRowLite("\t");
				
				int numNotBlank = numNotBlankInRow(line);
				if (numNotBlank == 1 && !line[0].toUpperCase().startsWith("CANDIDATE"))
				{ //process an office or district
					if (office.equals(""))
					{
						office = line[0];
						if (office.matches(".*\\d+.*") && (office.toUpperCase().contains("DISTRICT")
								|| office.toUpperCase().contains("DIST. ")))
							district = office.replaceAll("\\D", "");
						office = getOffice(office);
					}
					else if (district.equals(""))
					{
						district = line[0];
						if (district.toUpperCase().matches("^\\d+[A-Z]{1,2}\\s[A-Z]+$"))
							district = district.replaceAll("\\D", "");
					}
					else
					{
						office = "";
						district = "";
					}
				} //end office/ district
				else if (numNotBlank > 1)
				{ //process a data line
					if (officeCol >= 0)
					{
						office = line[officeCol];
						district = "";
						if (office.matches(".*\\d+.*") && (office.toUpperCase().contains("DISTRICT")
								|| office.toUpperCase().contains("DIST. "))
								&& !office.toUpperCase().contains("ATTORNEY"))
							district = office.replaceAll("\\D", "");
						else if (office.toUpperCase().contains("PLACE")
								&& !office.toUpperCase().contains("AMENDMENT")
								&& !office.toUpperCase().contains("QUESTION"))
							district = office;
						office = getOffice(office);
					}
					for (int col = firstDataCol; col < line.length; col++)
					{
						if (!line[col].equals(""))
							out.writeLine(this.state.getState() + "\t"
									+ year + "\t" + this.state.getGeoType() + "\t"
									+ line[candCol].trim() + "\t" + office + "\t"
									+ district + "\t" + line[partyCol].trim() + "\t"
									+ locations[col] + "\t" + line[col] + "\t-1.0");
					}
				} //end data line
				else
				{
					office = "";
					district = "";
				}
			} //end loop lines
		} //end try read
		catch (IOException e)
		{
			System.err.println("Unkown error reading line from " + file.getName());
			e.printStackTrace();
		}
	}
	
	public void close()
	{
		this.out.close();
	}
	
	public int firstNonBlankInRow(String[] line)
	{
		for (int col = 0; col < line.length; col++)
			if (!line[col].trim().equals(""))
				return col;
		return line.length;
	} //end firstNonBlankInRow
	
	public static String[] fillEmptyForward(String[] toFill)
	{
		for (int col = 1; col < toFill.length; col++)
			if (toFill[col].equals(""))
				toFill[col] = toFill[col-1];
		return toFill;
	} //end fillEmptyForward method
	
	public static boolean isHeader(String line, String delim)
	{
		String[] lineArr = line.split(delim, -1);
		if (numNumericCols(lineArr) >= 2 && getOffice(lineArr[0]).equals(lineArr[0]))
			return false;
		else
			return true;
	} //end isHeader(String, String) method
	
	public static boolean isHeader(String[] line)
	{
		if (numNumericCols(line) >= 2 && getOffice(line[0]).equals(line[0]))
			return false;
		else
			return true;
	} //end isHeader(String[]) method
	
	public static int longestConsecutiveBlank(String[] line)
	{
		int blanksInARow = 0;
		for (int col = 0; col < line.length; col++)
		{
			if (line[col].trim().equals("") || line[col].trim().equals("*"))
				blanksInARow++;
			else
				blanksInARow = 0;
		}
		return blanksInARow;
	} //end longestConsecutiveBlank method
	
	public static int numNumericCols(String[] line)
	{
		int numberCols = 0;
		for (String col : line)
			if (isNumeric(col))
				numberCols++;
		return numberCols;
	} //end numNumericCols method
	
	public static boolean isNumeric(String cell)
	{
		if (cell.matches("^\"?((\\d)|(,))+\"?$"))
			return true;
		else
			return false;	
	} //end isNumeric method
	
	public static int getFirstNumericCol(String[] line) throws Exception
	{
		int firstNumCol = -1;
		int col = 0;
		boolean textFound = true;
		while (col < line.length)
		{
			if (textFound)
			{
				if (isNumeric(line[col].trim()))
				{
					firstNumCol = col;
					textFound = false;
				}
			}
			else
			{
				if (!isNumeric(line[col].trim()) && !line[col].trim().equals(""))
					textFound = true;
			}
			col++;
		}
		
		if (firstNumCol < 0)
		{
			if (numBlankInRow(line) <= line.length-1)
			{
				System.err.println("No numeric cells found in row " + Arrays.toString(line));
				throw new Exception(); //TODO write a new exception for this error
			}
		}
		
		return firstNumCol;
	} //end getFirstNumericCol method
	
	public static int numBlankInRow(String[] line)
	{
		if (line[0] == null) return line.length;
		
		int numBlank = 0;
		for (String cell : line)
			if (cell.trim().equals(""))
				numBlank++;
		return numBlank;
	} //end numBlankInRow method
	
	public static int numNotBlankInRow(String[] line)
	{
		if (line[0] == null) return 0;
		
		int numNotBlank = 0;
		for (String cell : line)
			if (!cell.trim().equals(""))
				numNotBlank++;
		return numNotBlank;
	} //end numNotBlankInRow method
	
	public static String collectRowToString(String[] line)
	{
		String row = "";
		for (String cell : line)
			row += " " + cell;
		return row.trim();
	} //end collecttoString method
	
	public static String collectColToString(ArrayList<String[]> lines, int colNum)
	{
		String col = "";
		for (String[] line : lines)
			if (colNum < line.length)
				col += " " + line[colNum];
		return col.trim();
	} //end collectColToString method
	
	public static String[] fillArrayWithConstant(String constant, int arraySize, int firstDataCol)
	{
		String[] toFill = new String[arraySize];
		
		int col;
		for (col = 0; col < firstDataCol; col++)
			toFill[col] = "";		
		for (col = firstDataCol; col < toFill.length; col++)
			toFill[col] = constant;
		
		return toFill;
	} //end fillArrayWithConstant method
	
	public static String getOffice(String officeRaw)
	{
		String offKey = ElectionData.checkStatic(officeRaw);
		if (offKey.equals(""))
			return officeRaw;
		else
			return offKey;
	} //end getOffice method
	
	public static int getMaxArraySize(ArrayList<String[]> rows)
	{
		int max = 0;
		for (String[] row : rows)
			if (row.length > max)
				max = row.length;
		return max;
	}
	
	public static int getIndex(ArrayList<String> array, String toFind) throws Exception
	{
		for (int index = 0; index < array.size(); index++)
			if (array.get(index).toUpperCase().equals(toFind))
				return index;
		
		throw new Exception(toFind + " not found in array.");
	} //end getIndex
	
	public static boolean isPartyRow(String[] row)
	{
		int partiesFound = 0;
		for (String cell : row)
		{
			cell = cell.toUpperCase().trim();
			if (cell.equals("REPUBLICAN") || cell.contains("INDEPENDENT")
					|| cell.equals("DEMOCRATIC") || cell.equals("DEMOCRAT")
					|| cell.matches("[[A-Z]{1,3}[^(YES|NO)]]"))
				partiesFound++;
		}
		
		if (partiesFound >= 2) return true;
		else return false;
	} //end isPartyRow(String) method
	
	public static boolean isPartyRow(String[] row, int threshold)
	{
		int partiesFound = 0;
		for (String cell : row)
		{
			cell = cell.toUpperCase().trim();
			if (cell.equals("REPUBLICAN") || cell.equals("INDEPENDENT")
					|| cell.equals("DEMOCRATIC") || cell.equals("DEMOCRAT")
					|| cell.matches("[[A-Z]{1,3}[^(YES|NO)]]"))
				partiesFound++;
		}
		
		if (partiesFound >= threshold) return true;
		else return false;
	} //end isPartyRow(String) method
	
	public static boolean containsParties(String[] row)
	{
		int partiesFound = 0;
		for (String cell : row)
		{
			cell = cell.toUpperCase().trim();
			if (cell.contains("DEM") || cell.contains("REP") || cell.contains("IND")
					|| cell.contains("REPUBLICAN") || cell.contains("DEMOCRAT")
					|| cell.contains("DEMOCRATIC") || cell.contains("INDEPENDENT")
					|| cell.matches(".*\\([A-Z]\\s?\\).*"))
				partiesFound++;
		}
		
		return partiesFound >= 1;
	} //end containsParties method
	
	public static boolean containsOffices(String[] row)
	{
		int officesFound = 0;
		for (String cell : row)
		{
			cell = cell.toUpperCase().trim();
			if (!getOffice(cell).equals(cell))
				officesFound++;
		}
		
		return officesFound >= 2;
	} //end containsOffices method
	
	public String getDistrictInDict(String[] offArr, String dictLineCell)
	{
		String district;
		if (offArr.length >= 3)
			district = offArr[1].replaceAll("[\\D]", "").trim();
		else if (offArr.length == 2 && offArr[1].toLowerCase().contains("dist"))
		{
			if (offArr[1].contains("-"))
				offArr[1] = offArr[1].substring(0, offArr[1].lastIndexOf("-"));
			
			if (offArr[1].toLowerCase().contains("candidate"))
				district = offArr[1].substring(0,
						offArr[1].toLowerCase().lastIndexOf("candidate"));
			else
				district = offArr[1].replaceAll("[\\D]", "").trim();
		}
		else if (dictLineCell.toLowerCase().contains("div"))
			district = dictLineCell.substring(dictLineCell
					.indexOf(",")+1).trim();
		else if (offArr[0].toUpperCase().contains("AT-LARGE"))
			district = "STW";
		else
			district = "";

		if (offArr.length > 3 && offArr[2].toLowerCase().contains("pos"))
			district += "_" + offArr[2].replaceAll("[\\D]", "").trim();
		else if (dictLineCell.toLowerCase().contains("pos")
				&& !district.contains(","))
			district += "_" + dictLineCell
					.substring(dictLineCell.toLowerCase().lastIndexOf("pos"))
					.replaceAll("[\\D]", "");
		
		return district;
	} //end getDistrictInDict method
	
	public HashMap<String, CandidateData> processDictFile(String year, File dictFile)
	{
		HashMap<String, CandidateData> dictMap = new HashMap<String, CandidateData>();
		if (dictFile.exists())
		{ //read dictionary if it exists
			String columnKey; //will temporarily hold the keys to be added to dictMap
			int candCol = -1, officeCol = -1, partyCol = -1; //will hold column indices for dictionary columns indicated
			final int KEYCOL = 0; //the column code is always in column 0 of the dictionary file
			String candName, party, office, district; //will be used to form the CandidateData entries for dictMap
			String[] offArr; //intermediate object for parsing offices below
			String[] dictLine; //will hold the dictionary rows as String[]
			
			try
			{ //try to read dictionary file, process
				InFile dict = new InFile(dictFile);
				ArrayList<String> dictHeaders = dict.readRow("\t");
				
				try
				{
					candCol = getIndex(dictHeaders, "CANDIDATE NAME");
					officeCol = getIndex(dictHeaders, "CONTEST NAME");
				}
				catch (Exception e) //TODO make a specific checked exception for this situation
				{
					System.err.println("Index not found error in " + year);
					e.printStackTrace();
				}
				
				if (dictHeaders.contains("Party"))
				{ //if party in separate column...
					try { partyCol = getIndex(dictHeaders, "PARTY"); }
					catch (Exception e)
					{
						System.err.println("Index not found error in " + year);
						e.printStackTrace();
					}
					while (dict.isReady())
					{ //loop through all lines of dictionary file
						dictLine = dict.readRowLite("\t");
						columnKey = dictLine[KEYCOL];
						
						if (dictLine[partyCol].equals(""))
						{
							if (dictLine[candCol].contains("-"))
								candName = dictLine[candCol].substring(0, dictLine[candCol].lastIndexOf("-"));
							else
								candName = dictLine[candCol].replace("*", "");
							
							party = dictLine[candCol].substring(dictLine[candCol].indexOf("-")+1).replace("*", "");
						}
						else
						{
							candName = dictLine[candCol].replace("*", "");
							party = dictLine[partyCol];
						}
						
						offArr = dictLine[officeCol].split(",");
						office = getOffice(offArr[0].trim());
						
						district = this.getDistrictInDict(offArr, dictLine[officeCol]);
						
						dictMap.put(columnKey, new CandidateData(Integer.parseInt(year),
								this.state.getState(), this.state.getGeoType(), office,
								candName, party, district));
					} //end loop through dict
				} //end party in column
				else
				{ //if party in name column...
					while (dict.isReady())
					{ //loop through all lines of dictionary file
						dictLine = dict.readRowLite("\t");
						columnKey = dictLine[KEYCOL];
						
						if (!dictLine[candCol].contains("-"))
						{
							candName = "";
							party = "";
						}
						else
						{
							candName = dictLine[candCol].substring(0, dictLine[candCol].lastIndexOf("-"));
							party = dictLine[candCol].substring(dictLine[candCol].indexOf("-")+1).replace("*", "");
						}
						
						offArr = dictLine[officeCol].replaceAll("\"", "").split(",");
						office = getOffice(offArr[0].trim());
						
						district = this.getDistrictInDict(offArr, dictLine[officeCol]);
						dictMap.put(columnKey, new CandidateData(0, year,
								this.state.getGeoType(), office, candName, party, district));
					} //end loop through dict
				} //end if party in name
				dict.close();
			} //end try dict
			catch (IOException e)
			{
				System.err.println("Unknown error in reading " + dictFile.getName());
				e.printStackTrace();
			}
		} //end read dict if
		return dictMap;
	} //end processDictFile method
	
	public ArrayList<CandidateData> getParties(File file)
	{
		InFile partyFile = null;
		ArrayList<CandidateData> parties = new ArrayList<CandidateData>();
		try
		{
			partyFile = new InFile(file);
			partyFile.readLine();
			while (partyFile.isReady())
			{
				String[] ptyLine = partyFile.readRowLite("\t");
				parties.add(new CandidateData(Integer.parseInt(ptyLine[0]),
						ptyLine[1], ptyLine[2].split(" ", -1), ptyLine[3], ptyLine[4]));
			}
			partyFile.close();
		}
		catch (FileNotFoundException e) {}
		catch (IOException e)
		{
			System.err.println("Error in reading party data.");
			e.printStackTrace();
		}

		return parties;
	} //end getParties method
}
