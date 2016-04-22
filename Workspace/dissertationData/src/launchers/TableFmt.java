package launchers;

import java.io.IOException;
import java.util.ArrayList;

import utilities.InFile;
import utilities.OutFile;

public class TableFmt
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Analysis\\Tables";
		InFile in = null;
		ArrayList<String[]> rows = new ArrayList<String[]>();
		ArrayList<Integer> hBorders = new ArrayList<Integer>();
		
		OutFile out = null;
		
		try
		{
			in = new InFile(path + "\\table1.txt");
			while (in.isReady())
			{
				String line = in.readLine();
				if (!line.matches("^-+$"))
				{
					System.out.println(line);
					rows.add(line.split("|"));
				}
				else
					hBorders.add(rows.size());
			}
			in.close();
		}
		catch (IOException e)
		{
			System.err.println("Error in reading file.");
			e.printStackTrace();
		}
		
		try
		{
			out = new OutFile(path + "\\table1_fmt.txt");
			
		}
		catch (IOException e)
		{
			System.err.println("Error in writing file.");
			e.printStackTrace();
		}
	}
}
