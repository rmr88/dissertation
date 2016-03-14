package launchers;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import tasks.RunShell;
import utilities.InFile;

public class PrepWI
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\"
					+ "elections\\stateResults\\KS";
		
		for (String excelStub : new String[] {"2014_precinct", "1998_precinct", "1996usp_precinct",
				"1996uss_precinct", "1996ush_precinct", "1996sts_precinct", "1996sth_precinct",
				"1994_county", "1992_county"})
		{
			File dictFile = new File(path + "\\" + excelStub + "_fileNames.txt");
			if (!dictFile.exists())
			{
				String dir = "C:\\Users\\Robbie\\Documents\\dissertation\\Code";
				String command = "XlsToCsv.vbs";
		
				RunShell shell = new RunShell(command + " " + path + "\\" + excelStub + ".xls .xls", dir);
				System.out.print(shell.run());
			} //now go format the first output file, run the program again.
			else
			{ //must use the manually-formatted dictionary file, based on a previous run of the program
				InFile dict = null;
				ArrayList<String> fileNames = new ArrayList<String>();
				try
				{ //process dictionary file
					dict = new InFile(dictFile);
					while (dict.isReady())
						fileNames.add(dict.readLine());
				}
				catch (IOException e)
				{
					System.err.println("Error reading dictionary file.");
					e.printStackTrace();
				}
				dict.close();
				
				for (int index = 1; index < fileNames.size(); index++)
				{ //loop through files, rename with correct names (skip the first one, which is for the dict itself
					File oldFile = new File(path + "\\" + excelStub + "_" + (index+1) + ".txt");
					File newFile = new File(path + "\\2014" + fileNames.get(index) + "_county.txt");
					if (oldFile.exists())
						oldFile.renameTo(newFile);
				} //end loop files
			}
		} //end loop through excel files
	} //end main
}
