package tasks;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import utilities.CandidateData;
import utilities.Columns;
import utilities.ElectionData;
import utilities.InFile;
import utilities.OutFile;
import utilities.State;

public class ElectionParser
{
	private State state;
	private OutFile out = null;
	
	private String[] pLoc = {"AL", "ID"};
	private String[] pOff = {"MA", "VA"};
	private String[] pCL = {"FL", "IL"};
	private String[] pDict = {"WA"};
	
	private List<String> parseByLocation = Arrays.asList(this.pLoc);
	private List<String> parseByOffice = Arrays.asList(this.pOff);
	private List<String> parseByCandLoc = Arrays.asList(this.pCL);
	private List<String> parseByDict = Arrays.asList(this.pDict);
	
	public ElectionParser(State _state)
	{
		this.state = _state;
	}
	
	public void run() //TODO want to return anything for ScrapeAndParse to post-process?
	{
		System.out.println(this.state.getState() + ": parse");
		this.initializeOut(this.state.getPath() + "\\" + this.state.getState()
				+ "_" + this.state.getGeoType() + ".txt");

		for (int year : this.state.getYears())
		{
			System.out.print("\t" + year);
			File file = new File(this.state.getPath() + "\\" + year + "_"
					+ this.state.getGeoType() + this.state.getFileType());

			if (file.exists())
			{ //if years are in single files:
				if (this.parseByCandLoc.contains(this.state.getState()))
				{
					System.out.println(": Parsing by candidate/ location");
					this.candLocation(year, file);
				}
				else if (this.parseByLocation.contains(this.state.getState()))
				{
					System.out.println(": Parsing by offices");
					this.location(year, file, new ArrayList<CandidateData>());
				}
				else if (this.parseByDict.contains(this.state.getState()))
				{
					File dictFile = new File(this.state.getPath() + "\\" + year
							+ "_dict" + this.state.getFileType());
					if (dictFile.exists())
					{
						System.out.println(": Parsing by dictionary");
						this.dictionary(year, file, dictFile);
					}
					else
						System.err.println("Error: dictionary not found for " + file.getName());
				}
				else
					System.err.println("uncoded case");
			} 
			else if (this.parseByOffice.contains(this.state.getState()))
			{ //if years are in multiple files (by office):
				System.out.println(": Parsing by office");
				for (String office : this.state.getOffices())
				{
					file = new File(this.state.getPath() + "\\" + year + office + "_"
							+ this.state.getGeoType() + this.state.getFileType());
					ArrayList<CandidateData> parties = this.getParties();
					
					if (file.exists())
						this.offices(year, office, file, parties);
				}
			}
			else
			{ //if years are in folders:
				file = new File(this.state.getPath() + "\\" + year + "_" + this.state.getGeoType());
				if (file.isDirectory())
				{
					if (state.getOffices().length != 0)
					{
						System.out.println(": Parsing by location");
						this.location(year, file, new ArrayList<CandidateData>());
					}
					else
					{
						File[] inputFiles = this.getFileList(this.state.getPath() + "\\"
								+ year + "_" + this.state.getGeoType());
						int officesFound = 0;
						for (File inputFile : inputFiles)
						{
							String name = inputFile.getName().toUpperCase();
							if (name.contains("USH_") || name.contains("USP_") ||
									name.contains("USS_") || name.contains("GOV_"))
								officesFound++;
						}
						
						if (officesFound < 2)
						{
							ArrayList<CandidateData> parties = this.getParties();
							System.out.println(": Parsing by location");

							for (File inputFile : inputFiles)
								this.location(year, inputFile, parties);
						}
						else
							System.err.println("uncoded case");
					}
				}
				else //warning if no valid file, directory found
					System.err.println("No data file found for year " + year + ".");
			}
		} //end years for loop
		out.close();
	} //end run method
	
	public void location(int year, File file, ArrayList<CandidateData> parties)
	{
		HashMap<Integer, CandidateData> data = new HashMap<Integer, CandidateData>();
		
		//to determine AL county names:
		String county = file.getName().toUpperCase()
				.replaceAll("_SHEET[\\d]?", "").replace(this.state.getFileType().toUpperCase(), "")
				.replace(".", "").replaceAll("1996_COMPILED_RESULTS_", "");
		if (county.contains("_"))
			county = county.substring(county.lastIndexOf("_")+1);
		String location = county.replace("COUNTY", "");
		
		InFile in = null;
		in = this.initializeIn(file);
		
		String[] line = null;
		String[] offices, districts, names;
		String[] partyArr = null;
		ArrayList<String[]> topLines = new ArrayList<String[]>();
		
		try //try to process files
		{
			String delim = "\t";
			if (this.state.getFileType().equals(".csv"))
				delim = ",";
			
			boolean lineIsHeader = true;
			while (lineIsHeader && in.isReady()) //collect all header data into a single object
			{
				line = in.readRowLite(delim); //at the end of the loop, will have the first data line
				int numericCols = 0;
				int partiesFound = 0;
				for (String cell : line)
				{
					cell = cell.replaceAll(",", "")
							.replaceAll("\"", "")
							.replaceAll("unopposed", "1").trim();
					if (cell.matches("^[\\d\\.]+$"))
						numericCols++;
					else if (cell.toUpperCase().equals("DEM") || cell.toUpperCase().equals("DEM.")
							|| cell.toUpperCase().equals("REP") || cell.toUpperCase().equals("REP.")
							|| cell.toUpperCase().equals("IND") || cell.toUpperCase().equals("IND."))
						partiesFound++;
				}

				if (numericCols >= 5)
					lineIsHeader = false;
				else if (partiesFound >= 9)
					partyArr = line;
				else
					topLines.add(line);
			} //end header collection loop
			
			if (in.isReady()) //process a file with data
			{
				boolean haveNames = false;
				while (!haveNames && topLines.size() >= 2)
				{ //checking for office code row below names (AL)
					int officesFound = 0;
					int allCapsCells = 0;
					int emptyCells = 0;
					for (String col : topLines.get(topLines.size()-1))
					{
						if (!ElectionData.checkStatic(col).equals(""))
							officesFound++;
						if (col.matches("^[^a-z]+"))
							allCapsCells++;
						if (col.equals(""))
							emptyCells++;
					}

					if (emptyCells >= topLines.get(topLines.size()-1).length-1
							&& !topLines.get(topLines.size()-1)[0].trim().equals(""))
						location = topLines.get(topLines.size()-1)[0];
					if ((officesFound >= 2 && allCapsCells >= 10)
							|| emptyCells >= topLines.get(topLines.size()-1).length-1)
						topLines.remove(topLines.size()-1);
					else
						haveNames = true;
				} //end check for office code row

				offices = topLines.get(0);
				districts = new String[offices.length];
				names = topLines.get(topLines.size()-1);
				
				boolean matchMade = false;
				int firstOfficeCol = 0;
				for (int col = 0; col < offices.length; col++)
				{ //process header data
					for (int row = 1; row < topLines.size()-1; row ++)
						offices[col] += " " + topLines.get(row)[col].trim();
					
					districts[col] = "";
					String officeCheck = offices[col].toUpperCase().trim();
					if ((officeCheck.contains("DISTRICT") && !officeCheck.contains("ATTORNEY"))
							|| officeCheck.contains("CIRCUIT"))
						districts[col] = officeCheck.replaceAll("\\D", "").trim();
					else if (officeCheck.toUpperCase().contains("PLACE"))
						districts[col] = officeCheck
								.substring(officeCheck.lastIndexOf("PLACE")).trim();
					
					if (offices[col].toUpperCase().trim().equals(districts[col]))
						offices[col] = "";
					
					officeCheck = ElectionData.checkStatic(officeCheck);
					if (!officeCheck.equals(""))
					{
						offices[col] = officeCheck;
						if (!matchMade)
						{
							firstOfficeCol = col;
							matchMade = true;
						}
					}
					else if (!matchMade)
						offices[col] = "";
				} //end process header data
				
				String office = "";
				String district = "";
				for (int col = firstOfficeCol; col < offices.length; col++)
				{ //create CandidateData objects, put in data map
					if (!offices[col].equals(""))
					{
						office = offices[col].trim();
						district = "";
					}
					if (!districts[col].equals(""))
						district = districts[col].trim();
					
					int ptyIndex = 0;
					boolean ptyMatched = false;
					String party = "";

					if (parties.size() == 0 && partyArr != null)
						party = partyArr[col].replace(".", "");
					else if (parties.size() > 0)
					{
						while (!ptyMatched && ptyIndex < parties.size())
						{
							party = parties.get(ptyIndex).partyCheck(names[col], year, office, district);
							if (!party.equals(""))
								ptyMatched = true;
							ptyIndex++;
						}
					}
					else
						System.err.println("No party data identified in " + file.getPath());
					
					if (!names[col].equals(""))
					{
						data.put(col, new CandidateData(this.state.getState(),
								this.state.getGeoType(), names[col], party, year));
						data.get(col).setOffice(office);
						data.get(col).setDistrict(district);
					}
				} //end create CandidateData objects
				
				while (in.isReady()) //loop through data lines, create ElectionData objects
				{
					int blankCols = 0;
					for (String col : line)
						if (col.equals(""))
							blankCols++;
					
					if (blankCols == line.length-1 && !line[0].trim().equals(""))
						location = line[0];
					else if (blankCols < line.length)
					{
						if (location.contains("_"))
							location = location.substring(0, location.indexOf("_"));
						
						for (int col = 0; col < firstOfficeCol; col++)
							location += "_" + line[col];
						
						for (int col = firstOfficeCol; col < offices.length; col++)
						{
							if (line[col].toUpperCase().trim().equals("UNOPPOSED"))
								data.get(col).addData(new ElectionData(location, 0, 100.0));
							else if (!line[col].trim().replaceAll("\\D", "").equals("")
									&& data.containsKey(col))
							{
								data.get(col).addData(new ElectionData(location,
										Integer.parseInt(line[col]
												.replaceAll("\\D", "")
												.trim()), -1.0));
							}
						}
					}
					line = in.readRowLite(delim);
				} //end loop through data lines
				
				for (Integer key : data.keySet())
					out.write(data.get(key).getRows("\t"));
			} //end process file with data
			else
				out.write("<<Blank File>>\r\n");
		}
		catch(IOException e)
		{
			System.err.println("Error in reading rows of " + file.getAbsolutePath());
			e.printStackTrace();
		} //end try to process files
	} //end location method
	
	public void candLocation(int year, File file)
	{
		InFile in = null;
		in = this.initializeIn(file);
		
		String headerStr = null;
		try
		{
			headerStr = in.readLine();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
		String delim = InFile.determineDelimiter(headerStr);
		String[] header = headerStr.split(delim);
		
		ArrayList<Integer> locationInds  = new ArrayList<Integer>(),
				officeInds = new ArrayList<Integer>(),
				distInds = new ArrayList<Integer>(),
				partyInds = new ArrayList<Integer>(),
				nameInds = new ArrayList<Integer>(),
				voteInds = new ArrayList<Integer>();
		
		//Get lists of possible columns for the five fields
		for (int index = 0; index < header.length; index++)
		{
			String check = header[index].toLowerCase();
			if (Columns.LOCATION.check(check))
				locationInds.add(index);
			else if (Columns.OFFICE.check(check))
				officeInds.add(index);
			else if (Columns.PARTY.check(check))
				partyInds.add(index);
			else if (Columns.VOTE.check(check))
				voteInds.add(index);
			else if (Columns.CANDNAME.check(check))
				nameInds.add(index);
			else if (Columns.DIST.check(check))
				distInds.add(index);
		}

		int locationInd = -1,
				partyInd = -1,
				nameInd = -1,
				voteInd = -1,
				officeInd = -1,
				distInd = -1;
		
		//Get unique column indices for the five fields.
		if (locationInds.size() == 1 && header[locationInds.get(0)].toLowerCase().equals(this.state.getGeoType()))
			locationInd = locationInds.get(0);
		else
		{
			try { locationInd = this.getUniqueCol(locationInds, header, Columns.LOCATION); }
			catch (Exception e)
			{
				System.err.println("Error: unique location name column not identified for "
						+ this.state.getState() + ", " + year);
				e.printStackTrace();
			}
		}
		
		try { voteInd = this.getUniqueCol(voteInds, header, Columns.VOTE); }
		catch (Exception e)
		{
			System.err.println("Error: unique vote column not identified for "
					+ this.state.getState() + ", " + year);
			e.printStackTrace();
		}
		
		try { partyInd = this.getUniqueCol(partyInds, header, Columns.PARTY); }
		catch (Exception e)
		{
			System.err.println("Error: unique party abbreviaton column not identified for "
					+ this.state.getState() + ", " + year);
			e.printStackTrace();
		}
		
		try { nameInd = this.getUniqueCol(nameInds, header, Columns.CANDNAME); }
		catch (Exception e)
		{
			System.err.println("Error: unique candidate name column not identified for "
					+ this.state.getState() + ", " + year);
			e.printStackTrace();
		}
		
		try { officeInd = this.getUniqueCol(officeInds, header, Columns.OFFICE); }
		catch (Exception e)
		{
			System.err.println("Error: unique candidate name column not identified for "
					+ this.state.getState() + ", " + year);
			e.printStackTrace();
		}
		
		try { distInd = this.getUniqueCol(distInds, header, Columns.DIST); }
		catch (Exception e) {} //could log the fact that district is embedded in office column
		
		String[] line;
		Pattern distPattern = Pattern.compile("([\\D]*[\\d]+[\\D]*\\s).*");
		try
		{
			while (in.isReady())
			{
				line = in.readRowLite(delim);
				
				String office = line[officeInd].replaceAll("\"", "").toUpperCase();
				String dist = "";
				if (distInd >= 0)
				{
					dist = line[distInd];
				}
				else
				{
					Matcher distMatcher = distPattern.matcher(office);
					
					if (distMatcher.matches())
					{
						dist = distMatcher.group(1).replaceAll("\\D", "").trim();
						office = office.replace(distMatcher.group(1), "").trim();
					}
					
					if (office.contains("CIRCUIT"))
						dist = office;
				}
				
				if (office.toUpperCase().equals("GOVERNOR AND LIEUTENANT GOVERNOR"))
					office = "GOV";
				else
				{
					String key = ElectionData.checkStatic(office);
					if (!key.equals(""))
						office = key;
					
					if (key.equals("USS") && !dist.equals(""))
						office = "STS"; //accounting for IL state senate designations
				}
				
				out.writeLine(this.state.getState() + "\t" + year + "\t"
						+ this.state.getGeoType() + "\t"
						+ line[nameInd].replaceAll("\"", "") + "\t"
						+ office + "\t" + dist + "\t"
						+ line[partyInd].replaceAll("\"", "") + "\t"
						+ line[locationInd].replaceAll("\"", "") + "\t"
						+ line[voteInd].replaceAll("\"", "") + "\t-1.0");
			}
		}
		catch (IOException e)
		{
			System.err.println("Error in reading data line for "
					+ this.state.getState() + ", " + year);
		}
	} //end candLocation method
	
	public void dictionary(int year, File file, File dictFile)
	{
		InFile dict = null;
		dict = this.initializeIn(dictFile); //the reader object for the dictionary file
		HashMap<String, CandidateData> dictMap = new HashMap<String, CandidateData>(); //will be used later to write data out
		String columnKey; //will temporarily hold the keys to be added to dictMap
		int candCol = -1, officeCol = -1, partyCol = -1; //will hold column indices for dictionary columns indicated
		final int KEYCOL = 0; //the column code is always in column 0 of the dictionary file
		String candName, party, office, officeCheck, district; //will be used to form the CandidateData entries for dictMap
		String[] offArr; //intermediate object for parsing offices below
		String[] dictLine; //will hold the dictionary rows as String[]
		
		try
		{
			ArrayList<String> dictHeaders = dict.readRow("\t");
			try
			{
				candCol = this.getIndex(dictHeaders, "CANDIDATE NAME");
				officeCol = this.getIndex(dictHeaders, "CONTEST NAME");
			}
			catch (Exception e)
			{
				System.err.println("Index not found error in " + this.state.getState() + ", " + year);
				e.printStackTrace();
			}
			
			if (dictHeaders.contains("Party"))
			{ //if party in separate column...
				try { partyCol = this.getIndex(dictHeaders, "PARTY"); }
				catch (Exception e)
				{
					System.err.println("Index not found error in " + this.state.getState() + ", " + year);
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
					officeCheck = ElectionData.checkStatic(offArr[0]);
					if (officeCheck.equals(""))
						office = offArr[0].trim();
					else
						office = officeCheck;
					
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
					else if (dictLine[officeCol].toLowerCase().contains("div"))
						district = dictLine[officeCol].substring(dictLine[officeCol].indexOf(",")+1).trim();
					else if (offArr[0].toUpperCase().contains("AT-LARGE"))
						district = "STW";
					else
						district = "";
					
					if (offArr.length > 3 && offArr[2].toLowerCase().contains("pos"))
						district += "_" + offArr[2].replaceAll("[\\D]", "").trim();
					else if (dictLine[officeCol].toLowerCase().contains("pos")
							&& !district.contains(","))
						district += "_" + dictLine[officeCol]
								.substring(dictLine[officeCol].toLowerCase().lastIndexOf("pos"))
								.replaceAll("[\\D]", "");
					
					dictMap.put(columnKey, new CandidateData(year, this.state.getState(),
							this.state.getGeoType(), office, candName, party, district));
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
					officeCheck = ElectionData.checkStatic(offArr[0]);
					if (officeCheck.equals(""))
						office = offArr[0].trim();
					else
						office = officeCheck;
					
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
					else if (dictLine[officeCol].toLowerCase().contains("div"))
						district = dictLine[officeCol].substring(dictLine[officeCol].indexOf(",")+1).trim();
					else if (offArr[0].toUpperCase().contains("AT-LARGE"))
						district = "STW";
					else
						district = "";
					
					if (offArr.length > 3 && offArr[2].toLowerCase().contains("pos"))
						district += "_" + offArr[2].replaceAll("[\\D]", "").trim();
					else if (dictLine[officeCol].toLowerCase().contains("pos")
							&& !district.contains(","))
						district += "_" + dictLine[officeCol]
								.substring(dictLine[officeCol].toLowerCase().lastIndexOf("pos"))
								.replaceAll("[\\D]", "");
					
					dictMap.put(columnKey, new CandidateData(year, this.state.getState(),
							this.state.getGeoType(), office, candName, party, district));
				} //end loop through dict
			} //end if party in name
			dict.close();
		}
		catch (IOException e)
		{
			System.err.println("Unknown error in reading " + dictFile.getName());
			e.printStackTrace();
		}
		
		//Read data from main file, write to output file
		InFile in = null;
		in = this.initializeIn(file);
		int locationCol = -1;
		String locationName;
		String[] line; //will hold election result data
		try
		{
			String[] header = in.readRowLite("\t");
			int currentColumn = 0;
			while (locationCol < 0 && currentColumn < header.length)
			{
				if (header[currentColumn].toLowerCase().equals("county"))
					locationCol = currentColumn;
				currentColumn++;
			}
			if (locationCol < 0)
				locationCol = 0;

			while (in.isReady())
			{ //read rows of data file
				line = in.readRowLite("\t");
				locationName = line[locationCol];
				
				for (int col = locationCol+1; col < line.length; col++)
					if (!header[col].equals("") && !line[col].equals("")
							&& !(line[col].equals(".") || line[col].equals("-")))
						dictMap.get(header[col]).addData(new ElectionData(locationName,
								Integer.parseInt(line[col].replaceAll("[\",]", "")), -1.0));
			} //end read rows
		}
		catch (IOException e)
		{
			System.err.println("Error in reading data from " + file.getName());
			e.printStackTrace();
		}
		in.close();
		
		//Write data from completed dictMap
		try
		{
			for (String key : dictMap.keySet())
				out.write(dictMap.get(key).getRows("\t"));
		}
		catch (IOException e)
		{
			System.err.println("Error in writing output for " + this.state.getState()
					+ ", " + year);
			e.printStackTrace();
		}
	} //end dictionary method
	
	public void offices(int year, String office, File file, ArrayList<CandidateData> parties)
	{
		InFile in = null;
		in = this.initializeIn(file);
		
		String district = ""; //will be blank for all data I have for this method; could generalize to accomodate districts
		String[] candNames = null, partyArr = null, lineArr = null; //will hold column data
		String party = "";
		String locationName = ""; //will hold location names (from rows)
		String line = "";
		ArrayList<CandidateData> data = new ArrayList<CandidateData>(); //will hold data for output
		
		final int FIRSTDATACOL = 3; //may need to generalize beyond MA and VA.
		String delim = "\t";
		if (this.state.getFileType().equals(".csv"))
			delim = ",";getClass();
			
		Pattern p = Pattern.compile("(\"\\d{1,3}(,[\\d]{3})*)((,)(\\d{3,}\")){1}");
		
		try
		{ //try to process header line(s)
			line = in.readLine().replaceAll(",\\s", " ");
			candNames = line.split(delim);
			
			if (parties.isEmpty())
			{
				line = in.readLine().replaceAll(",\\s", " ");
				partyArr = line.split(delim);
				for (int col = FIRSTDATACOL; col < partyArr.length; col++)
				{
					data.add(new CandidateData(year, this.state.getState(), this.state.getGeoType(),
						office.toUpperCase(), candNames[col], partyArr[col], district));
				}
			}
			else
			{
				for (int col = FIRSTDATACOL; col < candNames.length; col++)
				{
					int ptyIndex = 0;
					boolean ptyMatched = false;
					while (!ptyMatched && ptyIndex < parties.size())
					{
						party = parties.get(ptyIndex).partyCheck(candNames[col], year,
								office.toUpperCase(), district);
						if (!party.equals(""))
							ptyMatched = true;
						ptyIndex++;
					}
					data.add(new CandidateData(year, this.state.getState(), this.state.getGeoType(),
							office.toUpperCase(), candNames[col], party, district));
				}
			}
		} //end header try
		catch (IOException e)
		{
			System.err.println("Error in reading header data for " + file.getName());
			e.printStackTrace();
		}
		
		try
		{
			while (in.isReady())
			{ //loop through data rows
				line = in.readLine().replaceAll(",\\s", " ");
				Matcher m = p.matcher(line);
				while (m.find())
				{
					line = m.replaceAll("$1$5");
					m.reset(line);
				}
				lineArr = line.split(delim);

				locationName = "";
				int col = 0;
				int lastCol;
				if (partyArr != null)
					lastCol = partyArr.length;
				else
					lastCol = lineArr.length;
				
				while (col < FIRSTDATACOL)
				{
					locationName += lineArr[col];
					col++;
				}
				while (col < lastCol)
				{
					data.get(col - FIRSTDATACOL).addData(new ElectionData(locationName,
							Integer.parseInt(lineArr[col].replaceAll("\"", "")), -1.0));
					col++;
				}
			} //end loop through data rows
		}
		catch (IOException e)
		{
			System.err.println("Unknown error while reading data rows of " + file.getName());
			e.printStackTrace();
		}
		in.close();
		
		try
		{
			for (CandidateData cand : data)
				out.write(cand.getRows("\t"));
		}
		catch (IOException e)
		{
			System.err.println("Error while writing output for " + file.getName());
			e.printStackTrace();
		}
	} //end offices method
	
	public ArrayList<CandidateData> getParties()
	{
		InFile partyFile = null;
		ArrayList<CandidateData> parties = new ArrayList<CandidateData>();
		try
		{
			partyFile = new InFile(this.state.getPath() + "\\parties.txt");
			partyFile.readLine();
			while (partyFile.isReady())
			{
				String[] ptyLine = partyFile.readRowLite("\t");
				parties.add(new CandidateData(Integer.parseInt(ptyLine[0]),
						ptyLine[1], ptyLine[2].split(" "), ptyLine[3], ptyLine[4]));
			}
			partyFile.close();
		}
		catch (FileNotFoundException e) {}
		catch (IOException e)
		{
			System.err.println("Error in reaidng party data.");
			e.printStackTrace();
		}

		return parties;
	} //end getParties method
	
	public int getIndex(ArrayList<String> array, String toFind) throws Exception
	{
		for (int index = 0; index < array.size(); index++)
		{
			if (array.get(index).toUpperCase().equals(toFind))
				return index;
		}
		throw new Exception(toFind + " not found in array.");
	}
	
	public File[] getFileList(String path)
	{
		File[] inputFiles = new File(path).listFiles(new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
				if (!name.toUpperCase().contains("SUMMARY")
						&& !name.toUpperCase().contains("README"))
					return name.endsWith(state.getFileType());
				else
					return false;
			}
		});
		return inputFiles;
	} //end getFileList method
	
	public void initializeOut(String path)
	{
		try
		{
			this.out = new OutFile(path, false);
			this.out.writeLine("state\tyear\tgeographyType\tcandName\toffice\t"
					+ "district\tparty\tlocationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error in setting up output file " + path);
			e.printStackTrace();
		}
	}
	
	public InFile initializeIn(String path)
	{
		try
		{
			return new InFile(path);
		}
		catch (IOException e)
		{
			System.err.println("Error in opening " + path);
			e.printStackTrace();
			return null;
		}
	}
	
	public InFile initializeIn(File file)
	{
		try
		{
			return new InFile(file);
		}
		catch (IOException e)
		{
			System.err.println("Error in opening " + file.getAbsolutePath());
			e.printStackTrace();
			return null;
		}
	}

	public int getUniqueColNoCheck(ArrayList<Integer> cols) throws Exception
	{
		int col = 0;
		
		if (cols.size() > 1)
			throw new Exception(); //TODO could write a specific exception for this
		else if (cols.size() == 1)
			col = cols.get(0);
		else
			throw new Exception();
		
		return col;
	}
	
	public int getUniqueCol (ArrayList<Integer> cols, String[] colText, Columns colElement)
			throws Exception
	{
		int col = 0;
		
		if (cols.size() > 1)
		{
			for (int index = 0; index < cols.size(); index++)
			{
				if (colElement.check2(colText[cols.get(index)].toLowerCase()))
					col += cols.get(index);
			}
		}
		else
			col = cols.get(0);
					
		if (col >= 0 && col < colText.length)
			return col;
		else
			throw new Exception();
	}
}
