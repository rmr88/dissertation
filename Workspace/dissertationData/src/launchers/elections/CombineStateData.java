package launchers.elections;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

import tasks.RunShell;
import utilities.InFile;
import utilities.OutFile;

public class CombineStateData
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections\\stateResults";
		String cmdDir = "C:\\Users\\Robbie\\Documents\\dissertation\\Code";
		File[] folders = new File(path).listFiles(new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
				if (name.matches("^[A-Z][A-Z]$")) return dir.isDirectory();
				else return false;
			}
		});
		
		OutFile out = null;
		String[] h = new String[] {"state", "year", "geographyType",
				"candName", "office", "district", "party", "locationName",
				"votes", "votePerc"};
		ArrayList<String> header = new ArrayList<String>(Arrays.asList(h));
		
		try
		{
			out = new OutFile(path + "\\stateResults.txt", false);
			out.writeRow(header, "\t");
		}
		catch (IOException e)
		{
			System.err.println("Error in opening output file.");
			e.printStackTrace();
		}
		
		for (File folder : folders)
		{
			String state = folder.getName();
			System.out.println(state);
			
			File[] xlsFiles = folder.listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					if (name.matches("^" + state + "_[a-zA-Z]+\\.[a-z]{3,4}$")) return true;
					else return false;
				}
			});
			
			for (File xlsFile : xlsFiles)
			{
				File textFile = new File(xlsFile.getAbsolutePath()
						.substring(0, xlsFile.getAbsolutePath().lastIndexOf(".")) + ".txt");
				if (!textFile.exists())
				{
					System.out.println("\tNo text file found for " + xlsFile.getName() + "; writing file...");
					
					RunShell shell = new RunShell("xlstotxt.vbs " + xlsFile.getAbsolutePath() + " " + 
							xlsFile.getName().substring(xlsFile.getName().lastIndexOf(".")+1), cmdDir);
					System.out.print(shell.run());
					
					if (!textFile.exists())
						System.err.println("Error in creating text file for " + xlsFile.getName() + ".");
				}
			}
			
			File[] textFiles = folder.listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					if (name.matches("^" + state + "_[a-zA-Z]+\\.txt$")
							|| (name.contains("county.txt") && name.contains(state))) return true;
					else return false;
				}
			});
			
			if (textFiles.length == 0)
				System.err.println("No text files found for " + state + ".");
			
			for (File file : textFiles)
			{
				try
				{
					InFile in = new InFile(file.getAbsolutePath());
					String[] firstRow = in.readRowLite("\t");
					int[] indexes = new int[header.size()];
					
					for (int index = 0; index < firstRow.length; index++)
						indexes[index] = header.indexOf(firstRow[index]);
					
					String[] line;
					while (in.isReady())
					{
						line = in.readRowLite("\t");
					
						for (int index = 0; index < line.length-1; index++)
							out.write(line[header.indexOf(firstRow[indexes[index]])]
									.replaceAll("[\",%]", "").trim() + "\t");
						out.writeLine(line[indexes[line.length-1]].replaceAll("[\",%]", "").trim());
					}
					in.close();
				}
				catch (IOException e)
				{
					System.err.println("Error reading " + file.getName());
					e.printStackTrace();
				}
			}
		}
		out.close();
	}
}
