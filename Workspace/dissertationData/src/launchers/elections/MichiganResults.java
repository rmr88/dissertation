package launchers.elections;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;

import utilities.ElectionData;
import utilities.InFile;
import utilities.OutFile;

public class MichiganResults 
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections\\stateResults\\MI";
		
		int[] years = {2014, 2012, 1998};
		String[] stubs = {"offc", "name", "vote"};
		
		OutFile out = null;
		try
		{
			out = new OutFile(path + "\\MI_precinct.txt", false);
			out.writeLine("state\tyear\tgeographyType\tcandName\toffice\t"
					+ "district\tparty\tlocationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error in opening output file.");
			e.printStackTrace();
		}
		
//		HashMap<String, String> counties = readIn(path + "\\county.txt");
//		for (String key : counties.keySet())
//			System.out.println(key + ": " + counties.get(key));
		
		for (Integer year : years)
		{
			HashMap<String, String> offices = readIn(path + "\\" + year + "offc.txt");
			HashMap<String, String> names = readIn(path + "\\" + year + "name.txt");
			HashMap<String, String> votes = readIn(path + "\\" + year + "vote.txt");
			
			String offKey = "";
			String nameKey = "";
			String row = "";
			for (String key : votes.keySet())
			{
				offKey = key.split("\t")[0];
				nameKey = key.split("\t")[1];
				
				row = "MI\t" + year + "\tprecinct\t" + names.get(nameKey).split("\t", -1)[0].replaceAll("  ", " ").trim()
						+ "\t" + offices.get(offKey) + "\t" + offKey.split("_")[1].substring(0, 3) + "\t"
						+ names.get(nameKey).split("\t", -1)[1] + "\t" + votes.get(key) + "\t-1.0";
				row = row.replaceAll("\t000\t", "\t\t");
				
				try { out.writeLine(row); } 
				catch (IOException e) { e.printStackTrace(); }
			}
		}
		
		out.close();
	}
	
	public static HashMap<String, String> readIn(String filePath)
	{
		InFile in = null;
		String[] line;
		HashMap<String , String> result = new HashMap<String, String>();
		try
		{
			in = new InFile(filePath);
			while (in.isReady())
			{
				line = in.readRowLite("\t");
				if (in.getDir().endsWith("county.txt"))
					result.put(line[0], line[1]);
				else if (in.getDir().endsWith("offc.txt"))
				{
					String office = ElectionData.checkStatic(line[5]);
					if (!office.equals(""))
						result.put(line[2] + "_" + line[3], office);
					else
						result.put(line[2] + "_" + line[3], line[5]);
				}
				else if (in.getDir().endsWith("name.txt"))
					result.put(line[5], line[7] + " " + line[8] + " " + line[6] + "\t" + line[9]);
				else if (in.getDir().endsWith("vote.txt"))
					result.put(line[2] + "_" + line[3] + "\t" + line[5],
							line[6] + "_" + line[7] + "_" + line[8] + "_" + line[9] + "_" + line[10] + "\t" + line[11]);
			}
			in.close();
		}
		catch (IOException e)
		{
			System.err.println("Error reading " + filePath);
			e.printStackTrace();
		}
		
		return result;
	}
}
