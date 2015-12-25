package launchers;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;

import utilities.CandidateData;
import utilities.InFile;
import utilities.OutFile;
import utilities.State;

public class ElectionParser
{
	private State state;
	private OutFile out = null;
	private InFile in = null;
	
	public ElectionParser(State _state)
	{
		this.state = _state;
	}
	
	public void run() //TODO want to return anything for ScrapeAndParse to post-process?
	{
		System.out.println(this.state.getState() + ": parse");
		String fileType = ".txt";
		
		int[] years = this.state.getYears();
		if (years.length == 0)
		{
			String[] folders = new File(state.getPath()).list(new FilenameFilter()
			{
				public boolean accept(File current, String name)
				{
					return new File(current, name).isDirectory();
				}
			});
			
			years = new int[folders.length];
			for (int index = 0; index < years.length; index++)
				years[index] = Integer.parseInt(folders[index]);
		}

		for (int year : years)
		{
			System.out.print("\t" + year);
			
			if (state.getOffices().length != 0)
				this.offices(year);
			else if (state.getLocations().length != 0)
				this.locations(year);
			else
			{
				File[] inputFiles = new File(state.getPath() + "\\" + year)
						.listFiles(new FilenameFilter()
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
				//TODO determine what to do next; maybe a method that determines whether the files are offices or locations, using ElectionData.checkStatic()?
			}
		}
	} //end run method
	
	public void offices(int year)
	{
		System.out.println("Parsing by offices");
	} //end offices method
	
	public void locations(int year)
	{
		System.out.println("Parsing by location");
	} //end locations method
	
	public void getParties()
	{
		InFile partyFile = null;
		ArrayList<CandidateData> parties = new ArrayList<CandidateData>();
		try
		{
			partyFile = new InFile(state.getPath() + "\\parties.txt");
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
	} //end getParties method
}
