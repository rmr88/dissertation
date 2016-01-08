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
				+ "elections\\stateResults\\WI";
		File dictFile = new File(path + "\\2012_ward_fileNames.txt");
		if (!dictFile.exists())
		{
			System.out.println("doesn't exist");
//			String dir = "C:\\Users\\Robbie\\Documents\\dissertation\\Code";
//			String command = "XlsToCsv.vbs";
//	
//			RunShell shell = new RunShell(command + " " + path + "\\2012_ward.xlsx .xlsx", dir);
//			System.out.print(shell.run());
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
				File oldFile = new File(path + "\\2012_ward_Sheet" + (index+1) + ".txt");
				File newFile = new File(path + "\\2012" + fileNames.get(index) + "_ward.txt");
				if (oldFile.exists())
					oldFile.renameTo(newFile);
			} //end loop files
		}
	} //end main
}
