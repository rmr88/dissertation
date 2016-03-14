package tests;

import java.io.File;
import java.io.FilenameFilter;

import utilities.State;

public class TestParseLauncher
{
	public static void main(String args[])
	{
		for (State state : State.values())
		{ //loop through all states coded so far in State enum
			System.out.println(state.getState());
			if (state.getProcessType().equals("scrape")) {}
					//new ElectionScraper(state).run();
			else if (state.getProcessType().equals("parse"))
			{ //parse files if condition met
				ParseAllTest parser = new ParseAllTest(state);
				for (int year : state.getYears())
				{
					System.out.println("\t" + year);
					File file = new File(state.getPath() + "\\" + year + state.getFileType());
					if (file.exists())
						parser.run(Integer.toString(year), file); //System.out.println("\t\t" + file.getName());
					else if (new File(state.getPath() + "\\" + year + "_" + state.getGeoType()
							+ state.getFileType()).exists())
					{
						file = new File(state.getPath() + "\\" + year + "_" + state.getGeoType()
								+ state.getFileType());
						parser.run(Integer.toString(year), file);
					}
					else if (new File(state.getPath() + "\\" + year + "_" + state.getGeoType())
							.isDirectory())
					{
						File[] files = new File(state.getPath() + "\\" + year
								+ "_" + state.getGeoType()).listFiles(new FilenameFilter()
						{
							public boolean accept(File dir, String name)
							{
								if (!name.toUpperCase().contains("README"))
									return name.endsWith(state.getFileType());
								else
									return false;
							}
						});
						
						if (state.getState().equals("AL") && year == 2014) //Different formats within year for AL 2014
							for (File f : files)
								parser.run(Integer.toString(year), f, f.getName().startsWith("2014-"));
						else //all other formats are consistent in year
							for (File f : files)
								if (f.exists())
									parser.run(Integer.toString(year), f); //System.out.println("\t\t" + f.getName());
					}
					else if (state.getOffices().length > 0)
					{ //files are by office
						for (String office : state.getOffices())
						{
							File[] files = new File(state.getPath()).listFiles(new FilenameFilter()
							{
								public boolean accept(File dir, String name)
								{
									if (name.matches("^" + year + office + "((\\d)|(_[a-zA-Z]*))*_"
											+ state.getGeoType() + state.getFileType() + "$"))
										return name.endsWith(state.getFileType());
									else
										return false;
								}
							});
							
							for (File f : files)
								if (f.exists())
									parser.run(Integer.toString(year), f); //System.out.println("\t\t" + f.getName());
						}
					}
					else
					{ //files are location-transposed
						File [] files = new File(state.getPath()).listFiles(new FilenameFilter()
						{
							public boolean accept(File dir, String name)
							{
								if (name.matches("^" + year + "_" + state.getGeoType()
										+ "_[a-zA-Z]+" + state.getFileType() + "$"))
									return name.endsWith(state.getFileType());
								else
									return false;
							}
						});

						for (File f : files)
							if (f.exists())
								parser.run(Integer.toString(year), f, true);
					}
				}
				parser.close();
			} //end parse files if
			else
				System.err.println(state.getState() + ": No process defined for this process type: "
						+ state.getProcessType());
		} //end state loop
	}
}
