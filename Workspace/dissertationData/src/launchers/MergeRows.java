package launchers;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;

import utilities.InFile;
import utilities.OutFile;

public class MergeRows
{
	public static void main(String args[])
	{
		String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections\\stateResults\\WA";
		int[] years = {2000, 1998, 1996, 1994, 1992, 1990, 1988, 1986, 1984, 1982, 1980, 1978,
				1976, 1974, 1972, 1970, 1968, 1966, 1964, 1962, 1960, 1958, 1956};
		OutFile out = null;
		InFile master = null;
		ArrayList<InFile> using = new ArrayList<InFile>();
		
		for (int year : years)
		{ //loop through years
			System.out.println(year);
			File masterFile = new File(basePath + "\\" + year + "_General.txt");
			if (masterFile.exists())
			{
				try
				{ //initialize master reader and writer objects
					master = new InFile(masterFile);
					out = new OutFile(basePath + "\\" + year + "_county.txt", false);
				}
				catch (IOException e)
				{
					System.err.println("Error opening master file or output file for " + year);
					e.printStackTrace();
				}
				
				File[] usingFiles = new File(basePath).listFiles(new FilenameFilter()
				{ //determine which using files correspond to the current year
					public boolean accept(File dir, String name)
					{
						if (name.endsWith(".txt") && name.contains(year + "_General")
								&& !name.equals(year + "_General.txt")
								&& !name.toLowerCase().contains("index"))
							return true;
						else
							return false;
					}
				});
				
				for (File usingFile : usingFiles)
				{ //fill array with all using file input objects
					try
					{
						using.add(new InFile(usingFile));
					}
					catch (IOException e)
					{
						System.err.println("Error opening using file " + usingFile.getName());
						e.printStackTrace();
					}
				}
				
				String masterLine = "";
				String[] usingLines = new String[using.size()];
				String county = "";
				
				try
				{
					while (master.isReady())
					{ //loop through master lines
						masterLine = master.readLine();
						county = masterLine.substring(0, masterLine.indexOf("\t"));
						
						if (!county.equals(""))
						{ //skip lines with no county (usually either total lines or blank)
							for (int index = 0; index < usingLines.length; index++)
							{ //loop through using files, reading next line for each
								usingLines[index] = using.get(index).readLine();
								if (!usingLines[index].startsWith(county))
								{
									System.err.println("Error in merging " + using.get(index).getDir()
											+ ": county " + county + " not matched. Check sort order in files.");
									masterLine = county + " ERROR";
									break;
								}
								else
								{ //append using line to master line, if counties match
									masterLine += usingLines[index].replace(county, "");
								}
							} //end loop through using files
							
							try
							{
								out.writeLine(masterLine);
							}
							catch (IOException e)
							{
								System.err.println("Error writing merged line for " + year
										+ ": " + masterLine);
								e.printStackTrace();
							}
						} //end skip if empty county
					} //end master line loop

					out.close();
					master.close();
					
					for (InFile in : using)
						in.close();
					using.clear();
				}
				catch (IOException e)
				{
					System.err.println("Unknown error processing " + masterFile.getName());
					e.printStackTrace();
				}
			} //end if master file exists
			else
				System.err.println("Master file for " + year + " not found.");
		} //end year loop
	} //end main
}
