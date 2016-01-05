package tasks;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
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
	private final String FILETYPE = ".txt";
	private OutFile out = null;
	
	public ElectionParser(State _state)
	{
		this.state = _state;
	}
	
	public void run() //TODO want to return anything for ScrapeAndParse to post-process?
	{
		System.out.println(this.state.getState() + ": parse");
		this.initializeOut(this.state.getPath() + "\\" + this.state.getState() + this.FILETYPE);
		
		if (this.state.getYears().length == 0)
			this.multiFile();
		else
			this.singleFile();
		
		out.close();
	} //end run method
	
	public void multiFile()
	{
		String[] folders = new File(this.state.getPath()).list(new FilenameFilter()
		{
			public boolean accept(File current, String name)
			{
				return new File(current, name).isDirectory();
			}
		});
		
		ArrayList<CandidateData> parties = this.getParties(); //TODO need to determine which states need this; may need to change party code below, too, to generalize
		
		for (String folder : folders)
		{
			int year = Integer.parseInt(folder);
			File[] inputFiles = this.getFileList(this.state.getPath() + "\\" + year);
			
			for (File inputFile : inputFiles)
			{
				HashMap<Integer, CandidateData> data = new HashMap<Integer, CandidateData>();
				
				String county = inputFile.getName().toUpperCase()
						.replaceAll("_SHEET[\\d]?", "").replace(this.FILETYPE.toUpperCase(), "")
						.replace(".", "").replaceAll("1996_COMPILED_RESULTS_", "");
				if (county.contains("_"))
					county = county.substring(county.lastIndexOf("_")+1);

				InFile in = null;
				try
				{
					in = new InFile(inputFile);
				}
				catch (IOException e)
				{
					System.err.println("Error in opening " + inputFile.getAbsolutePath());
					e.printStackTrace();
				}
				
				String[] line = null;
				String[] offices, districts;
				ArrayList<String[]> topLines = new ArrayList<String[]>();
				
				try //try to process files
				{ 
					boolean lineIsHeader = true;
					while (lineIsHeader && in.isReady()) //collect all header data into a single object
					{
						line = in.readRowLite("\t"); //at the end of the loop, will have the first data line
						int numericCols = 0;
						for (String cell : line)
						{
							cell = cell.replaceAll(",", "")
									.replaceAll("\"", "")
									.replaceAll("unopposed", "1").trim();
							if (cell.matches("^[\\d\\.]+$"))
								numericCols++;
						}
						
						if (numericCols >= 5)
							lineIsHeader = false;
						else
							topLines.add(line);
					} //end header collection loop
					
					if (in.isReady()) //process a file with data
					{
						boolean haveNames = false;
						while (!haveNames && topLines.size() >= 2)
						{ //checking for office code row below names
							int officesFound = 0;
							int allCapsCells = 0;
							for (String col : topLines.get(topLines.size()-1))
							{
								if (!ElectionData.checkStatic(col).equals(""))
									officesFound++;
								if (col.matches("^[^a-z]+"))
									allCapsCells++;
							}

							if (officesFound >= 2 && allCapsCells >= 10)
								topLines.remove(topLines.size()-1);
							else
								haveNames = true;
						} //end check for office code row
						
						offices = topLines.get(0);
						districts = new String[offices.length];
						
						boolean matchMade = false;
						int firstOfficeCol = 0;
						for (int col = 0; col < offices.length; col++)
						{ //process header data
							for (int topLine = 1; topLine < topLines.size()-1; topLine ++)
								offices[col] += " " + topLines.get(topLine)[col].trim();
							
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
							String name = topLines.get(topLines.size()-1)[col];
							
							int ptyIndex = 0;
							boolean ptyMatched = false;
							String party = "";
							while (!ptyMatched && ptyIndex < parties.size())
							{
								party = parties.get(ptyIndex).partyCheck(name, year, office, district);
								if (!party.equals(""))
									ptyMatched = true;
								ptyIndex++;
							}
							
							if (!name.equals(""))
							{
								data.put(col, new CandidateData(this.state.getState(),
										this.state.getGeoType(), name, party, year));
								data.get(col).setOffice(office);
								data.get(col).setDistrict(district);
							}
						} //end create CandidateData objects
						
						while (in.isReady()) //loop through data lines, create ElectionData objects
						{
							String location = county;
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
							line = in.readRowLite("\t");
						} //end loop through data lines
						
						for (Integer key : data.keySet())
							out.write(data.get(key).getRows("\t"));
					} //end process file with data
					else
						out.write("<<Blank File>>");
				}
				catch(IOException e)
				{
					System.err.println("Error in reading rows of " + inputFile.getAbsolutePath());
					e.printStackTrace();
				} //end try to process files
			} //end loop through files
		} //end folders loop
	} //end multiFile method
	
	public void singleFile()
	{
		for (int year : this.state.getYears())
		{
			File file = new File(this.state.getPath() + "\\" + year + this.FILETYPE);
			
			if (file.exists()) //process file if it exists; otherwise, show warning.
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
				}

				int locationInd = -1,
						partyInd = -1,
						nameInd = -1,
						voteInd = -1,
						officeInd = -1;
				
				//Get unique column indices for the five fields.
				try { locationInd = this.getUniqueColNoCheck(locationInds); }
				catch (Exception e)
				{
					System.err.println("Error: unique location name column not identified for "
							+ this.state.getState() + ", " + year);
					e.printStackTrace();
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
				
				String[] line;
				Pattern distPattern = Pattern.compile("([\\D]*[\\d]+[\\D]*\\s).*");
				try
				{
					while (in.isReady())
					{
						line = in.readRowLite(delim);
						
						String office = line[officeInd].replaceAll("\"", "").toUpperCase();
						String dist = "";
						Matcher distMatcher = distPattern.matcher(office);
						
						if (distMatcher.matches())
						{
							dist = distMatcher.group(1).replaceAll("\\D", "").trim();
							office = office.replace(distMatcher.group(1), "").trim();
						}
						
						if (office.contains("CIRCUIT"))
							dist = office;
						
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
								+ line[locationInd].replaceAll("\"", "") + "\t"
								+ office + "\t" + dist + "\t"
								+ line[nameInd].replaceAll("\"", "") + "\t"
								+ line[partyInd].replaceAll("\"", "") + "\t"
								+ line[voteInd].replaceAll("\"", "") + "\t-1.0");
					}
				}
				catch (IOException e)
				{
					System.err.println("Error in reading data line for "
							+ this.state.getState() + ", " + year);
				}
			} //end process if
			else
				System.err.println("No data file found for year " + year + ".");
		} //end years for loop
	} //end singleFile method
	
//	public void multiFile() //TODO why even bother with multifile? could change all to single output file...
//	{
//		String[] folders = new File(state.getPath()).list(new FilenameFilter()
//		{
//			public boolean accept(File current, String name)
//			{
//				return new File(current, name).isDirectory();
//			}
//		});
//		
//		int[] years = new int[folders.length];
//		for (int index = 0; index < years.length; index++)
//			years[index] = Integer.parseInt(folders[index]);
//		
//		for (int year : years)
//		{
//			System.out.print("\t" + year);
//			this.initializeOut(state.getPath() + "\\" +
//					this.state.getState() + "_" + year + FILETYPE);
//			
//			if (state.getOffices().length != 0)
//				this.offices(year);
//			else if (state.getLocations().length != 0)
//				this.locations(year);
//			else
//			{
//				File[] inputFiles = this.getFileList(this.state.getPath() + "\\" + year);
//				int officesFound = 0;
//				for (File file : inputFiles)
//					if (file.getName().toUpperCase().contains("USH_") ||
//							file.getName().toUpperCase().contains("USP_") ||
//							file.getName().toUpperCase().contains("USS_") ||
//							file.getName().toUpperCase().contains("GOV_"))
//						officesFound++;
//
//				if (officesFound < 2)
//					this.offices(year);
//				else
//					this.locations(year); //TODO still not sure how this ends up...
//			}
//			
//			if (this.out != null)
//				this.out.close();
//		} //end loop through years
//	} //end multiFile method
//	
	public void offices(int year)
	{
		System.out.println(": Parsing by offices");
		
		ArrayList<CandidateData> parties = this.getParties(); //TODO need to determine for each state whether this is needed.
		File[] files = this.getFileList(state.getPath() + "\\" + year);
		
		for (File inputFile : files)
		{
			HashMap<Integer, CandidateData> data = new HashMap<Integer, CandidateData>();
			
			String county = inputFile.getName().toUpperCase()
					.replaceAll("_SHEET[\\d]?", "").replace(FILETYPE.toUpperCase(), "")
					.replace(".", "").replaceAll("1996_COMPILED_RESULTS_", "");
			if (county.contains("_"))
				county = county.substring(county.lastIndexOf("_")+1);

			InFile in = null;
			in = this.initializeIn(inputFile);
			
			String[] line = null;
			String[] offices, districts;
			ArrayList<String[]> topLines = new ArrayList<String[]>();
			
			try //try to process files
			{ 
				boolean lineIsHeader = true;
				while (lineIsHeader && in.isReady()) //collect all header data into a single object
				{
					line = in.readRowLite("\t"); //at the end of the loop, will have the first data line
					int numericCols = 0;
					for (String cell : line)
					{
						cell = cell.replaceAll(",", "")
								.replaceAll("\"", "")
								.replaceAll("unopposed", "1").trim();
						if (cell.matches("^[\\d\\.]+$"))
							numericCols++;
					}
					
					if (numericCols >= 5)
						lineIsHeader = false;
					else
						topLines.add(line);
				} //end header collection loop
				
				if (in.isReady()) //process a file with data
				{
					boolean haveNames = false;
					while (!haveNames && topLines.size() >= 2)
					{ //checking for office code row below names
						int officesFound = 0;
						int allCapsCells = 0;
						for (String col : topLines.get(topLines.size()-1))
						{
							if (!ElectionData.checkStatic(col).equals(""))
								officesFound++;
							if (col.matches("^[^a-z]+"))
								allCapsCells++;
						}

						if (officesFound >= 2 && allCapsCells >= 10)
							topLines.remove(topLines.size()-1);
						else
							haveNames = true;
					} //end check for office code row
					
					offices = topLines.get(0);
					districts = new String[offices.length];
					
					boolean matchMade = false;
					int firstOfficeCol = 0;
					for (int col = 0; col < offices.length; col++)
					{ //process header data
						for (int topLine = 1; topLine < topLines.size()-1; topLine ++)
							offices[col] += " " + topLines.get(topLine)[col].trim();
						
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
						String name = topLines.get(topLines.size()-1)[col];
						
						int ptyIndex = 0;
						boolean ptyMatched = false;
						String party = "";
						while (!ptyMatched && ptyIndex < parties.size())
						{
							party = parties.get(ptyIndex).partyCheck(name, year, office, district);
							if (!party.equals(""))
								ptyMatched = true;
							ptyIndex++;
						}
						
						if (!name.equals(""))
						{
							data.put(col, new CandidateData(this.state.getState(),
									this.state.getGeoType(), name, party, year));
							data.get(col).setOffice(office);
							data.get(col).setDistrict(district);
						}
					} //end create CandidateData objects
					
					while (in.isReady()) //loop through data lines, create ElectionData objects
					{
						String location = county;
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
						line = in.readRowLite("\t");
					} //end loop through data lines
					
					for (Integer key : data.keySet())
						out.write(data.get(key).getRows("\t"));
				} //end process file with data
				else
					out.write("<<Blank File>>");
			}
			catch(IOException e)
			{
				System.err.println("Error in reading rows of " + inputFile.getAbsolutePath());
				e.printStackTrace();
			} //end try to process files
		} //end loop through files
	} //end offices method
	
	public void locations(int year)
	{
		System.out.println(": Parsing by location");
	} //end locations method
	
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
		}
		catch (IOException e)
		{
			System.err.println("Error in reaidng party data.");
			e.printStackTrace();
		}
		finally
		{
			partyFile.close();
		}
		return parties;
	} //end getParties method
	
	public File[] getFileList(String path)
	{
		File[] inputFiles = new File(path).listFiles(new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
				if (!name.toUpperCase().contains("SUMMARY")
						&& !name.toUpperCase().contains("README"))
					return name.endsWith(FILETYPE);
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
