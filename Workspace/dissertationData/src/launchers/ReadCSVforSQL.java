package launchers;

import java.io.IOException;

import utilities.InFile;
import utilities.OutFile;

public class ReadCSVforSQL
{
	public static void main(String args[])
	{
		String filePath = "C:\\Users\\Robbie\\Documents\\gunPolicy\\Data\\BonicaData\\contribDB_2010";
		
		InFile in = null;
		try
		{
			in = new InFile(filePath + ".csv");
		}
		catch (IOException e)
		{
			System.err.println("Error opening CSV.");
			e.printStackTrace();
		}
		
		OutFile out = null;
		try
		{
			out = new OutFile(filePath + ".txt", false);
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		long row = 0;
		while (in.isReady()) //loop through lines of InFile
		{
			row++;
			
			String line = "";
			try //Read line into char array
			{
				while (line.split(",").length < 47)
					line += in.readLine().replaceAll("\t", " ");
			}
			catch (IOException e)
			{
				System.err.println("Error reading row " + row + " of InFile.");
				e.printStackTrace();
			}
			
			char[] chars = line.toCharArray();
			
			boolean quoted = false; //Change commas to tabs, unless inside double quotes.
			for (int i = 0; i < chars.length; i++)
			{
				if (quoted && chars[i] == '"')
					quoted = false;
				else if (!quoted && chars[i] == '"')
					quoted = true;
				else if (!quoted && chars[i] == ',')
					chars[i] = '\t';
			}
			
			try //Write line to OutFile
			{
				out.writeLine(new String(chars).replaceAll("\"", ""));
			}
			catch (IOException e)
			{
				System.err.println("Error in writing row " + row + " to output file.");
				e.printStackTrace();
			}
			
			if (row % 10000 == 0) //Progress marker
				System.out.print(".");
			if (row % 500000 == 0)
				System.out.println();
		}
		in.close();
		out.close();
	}
}
