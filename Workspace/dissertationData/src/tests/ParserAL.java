package tests;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import utilities.CandidateData;
import utilities.ElectionData;
import utilities.InFile;
import utilities.OutFile;

public class ParserAL
{
	public static void main(String args[]) throws IOException
	{
		String state = "AL";
		String type = "precinct";
		
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
				+ "\\elections\\stateResults\\" + state;
		String fileType = ".txt";
		
		InFile partyFile = new InFile(path + "\\parties.txt");
		ArrayList<CandidateData> parties = new ArrayList<CandidateData>();
		try //get parties
		{
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
			System.err.println("Error in reading party data.");
			e.printStackTrace();
		}
		finally
		{
			partyFile.close();
		} //end get parties (try)
		
		String[] folders = new File(path).list(new FilenameFilter()
		{
			public boolean accept(File current, String name)
			{
				return new File(current, name).isDirectory();
			}
		});
		
		for (String folder : folders)
		{
			int year = Integer.parseInt(folder);
			
			File[] inputFiles = new File(path + "\\" + folder).listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					if (!name.toUpperCase().contains("SUMMARY")
							&& !name.toUpperCase().contains("README"))
						return name.endsWith(fileType);
					else
						return false;
				}
			});
			
			OutFile out = null;
			try
			{
				out = new OutFile(path + "\\" + folder + ".txt", false);
			}
			catch (IOException e)
			{
				System.err.println("Error in setting up output file " + path + ".txt");
				e.printStackTrace();
			}
			
			for (File inputFile : inputFiles)
			{
				HashMap<Integer, CandidateData> data = new HashMap<Integer, CandidateData>();
				
				String county = inputFile.getName().toUpperCase()
						.replaceAll("_SHEET[\\d]?", "").replace(fileType.toUpperCase(), "")
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
							
							String party = "";
							if (name.equals(""))
							{
								int bestPtyMatchIndex = -1;
								int bestMatchScore = 0;
								int matchScore;
								for (int ptyIndex = 0; ptyIndex < parties.size(); ptyIndex++)
								{
									matchScore = parties.get(ptyIndex).
											partyCheckScore(name, year,
											office.toUpperCase(), district);
									if (matchScore > bestMatchScore)
									{
										bestMatchScore = matchScore;
										bestPtyMatchIndex = ptyIndex;
									}
								}
								if (bestPtyMatchIndex < 0)
									party = "";
								else
									party = parties.get(bestPtyMatchIndex).getParty();
							}
							
							if (!name.equals(""))
							{
								data.put(col, new CandidateData(state, type, name, party, year));
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
	} //end main
} //end class
