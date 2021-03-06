package launchers.elections;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.HashMap;

import utilities.CandidateData;
import utilities.ElectionData;
import utilities.InFile;
import utilities.OutFile;
import utilities.State;

public class ParseNE
{
	public static void main(String args[])
	{
		State st = State.NE;
		InFile in = null;
		
		OutFile out = null;
		try
		{
			out = new OutFile(st.getPath() + "\\NE_county.txt", false);
			out.writeLine("state\tyear\tgeographyType\tcandName\toffice\tdistrict\tparty\t"
					+ "locationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		for (Integer year : st.getYears())
		{
			System.out.println("Parsing " + year + "...");
			try
			{
				in = new InFile(st.getPath() + "\\" + year + st.getFileType());
				String[] line = new String[] {"null"};
				String off = "";
				
				while (in.isReady())
				{
					off = ElectionData.checkStatic(line[0]);
					while (off.equals("") && !line[0].contains("District") && in.isReady())
					{
						line = in.readRowLite("\t");
						off = ElectionData.checkStatic(line[0]);
					}

					if (line[0].contains("District"))
						off = "USH";
					
					String dist = "";
					if (off.equals("USH"))
					{
						while(!line[0].contains("District"))
							line = in.readRowLite("\t");
						
						dist = line[0].substring(line[0].indexOf("District ")+9).trim();
						dist = dist.substring(0, dist.indexOf(" ")).trim();
					}
						
					int nonBlank = 0;
					while (nonBlank == 0 && in.isReady())
					{
						line = in.readRowLite("\t");
						nonBlank = 0;
						for (int ind = 1; ind < line.length; ind++)
							if (!line[ind].equals(""))
								nonBlank++;
					}
					
					HashMap<Integer, CandidateData> candMap = new HashMap<Integer, CandidateData>();
					if (!line[0].equals("Total"))
					{
						String[] ptys = in.readRowLite("\t");
						for (int ind = 1; ind < line.length; ind++)
							if (!line[ind].equals(""))
								candMap.put(ind, new CandidateData(year, st.getState(),
										st.getGeoType(), off, line[ind], ptys[ind], dist));
					}
					
					while (!line[0].toUpperCase().equals("TOTAL") && ElectionData.checkStatic(line[0]).equals("") && in.isReady())
					{
						line = in.readRowLite("\t");
						
						if (!line[0].toUpperCase().equals("TOTAL") && ElectionData.checkStatic(line[0]).equals(""))
							for (Integer col : candMap.keySet())
								candMap.get(col).addData(new ElectionData(line[0],
										Integer.parseInt(line[col].replaceAll("[\",]", "").trim()), -1.0));
					}
					
					for (CandidateData cand : candMap.values())
						if (cand.getName() != null && cand.getOffice() != null)
							out.write(cand.getRows());
				}
			}
			catch(IOException e)
			{
				System.err.println("Error reading " + st.getPath() + "\\" + year + st.getFileType());
				e.printStackTrace();
			}
			
			in.close();
		}
		
		st = State.NE2;
		for (Integer year : st.getYears())
		{
			System.out.println("Parsing " + year + "...");
			File[] files = new File(st.getPath()).listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					if (name.matches("^" + year + "[A-Z]*" + State.NE2.getFileType() + "$")) return true;
					else return false;
				}
			});
			
			for (File file : files)
			{
				String off = file.getName().replace(st.getFileType(), "").replaceAll("\\d", "");
				
				try
				{
					in = new InFile(file);
					String[] header = in.readRowLite("\",\"");
					int countyInd = -1,
							nameInd = -1,
							partyInd = -1,
							votesInd = -1,
							districtInd = -1;
					try
					{
						countyInd = getIndex("County", header);
						nameInd = getIndex("Name", header);
						partyInd = getIndex("Party", header);
						votesInd = getIndex("Votes", header);
						districtInd = getIndex("District#", header);
					}
					catch (Exception e)
					{
						e.printStackTrace();
					}
					
					String[] line;
					while (in.isReady())
					{
						line = in.readRowLite("\",\"");
						out.writeLine("NE\t" + year + "\tcounty\t" + line[nameInd]
							+ "\t" + off + "\t" + line[districtInd] + "\t"
							+ line[partyInd] + "\t" + line[countyInd] + "\t"
							+ line[votesInd] + "\t-1.0");
					}
					
				}
				catch (IOException e)
				{
					System.err.println("Error opening " + file.getPath());
					e.printStackTrace();
				}
				
				in.close();
			}
		}
		
		out.close();
	}
	
	public static int getIndex(String toFind, String[] toSearch) throws Exception
	{
		int index = -1;
		int col = 0;
		
		while (index < 0 && col < toSearch.length)
		{
			if (toSearch[col].equals(toFind))
				index = col;
			col++;
		}
		
		if (index < 0)
			throw new Exception("No column found for search entry " + toFind);
		
		return index;
	}
}
