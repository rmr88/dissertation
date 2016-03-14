package launchers;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import tasks.ParsePDF;
import utilities.CandidateData;
import utilities.ElectionData;
import utilities.OutFile;
import utilities.State;

public class ParseNY
{
	public static void main(String args[]) throws IOException
	{
		State st = State.NY;
		
		OutFile out = null;
		try
		{
			out = new OutFile(st.getPath() + "\\NY_county.txt", false);
			out.writeLine("state\tyear\tgeographyType\tcandName\toffice\tdistrict\tparty\t"
					+ "locationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		Pattern p = Pattern.compile("^\\s?([a-zA-Z\\.\\s]+)(\\s[\\d,]+){3,}$");
		
		for (Integer year : st.getYears())
		{ //loop through years
			System.out.println("Parsing " + year + "...");
			File[] files = new File(st.getPath()).listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					if (name.matches("^" + year + "[a-z]*" + State.NY.getFileType() + "$")) return true;
					else return false;
				}
			});
			
			for (File file : files)
			{ //loop through offices in year
				String off = file.getName().replace(st.getFileType(), "").replaceAll("\\d", "").toUpperCase();
				String dist = "";
				
				String pdfText = ParsePDF.getText(st.getPath() + "\\" + year + off + ".pdf");
				String[] pdfLines = pdfText.split("\r\n");
				
				HashMap<Integer, CandidateData> candMap = new HashMap<Integer, CandidateData>();
				String[] lineArr;
				
				Matcher m;
				for (String line : pdfLines)
				{ //loop through lines of office file
					m = p.matcher(line);
					if (line.contains("CONGRESSIONAL DISTRICT"))
					{
						dist = line.replaceAll("\\D", "");
						for (Integer i : candMap.keySet())
							out.write(candMap.get(i).getRows());
						candMap.clear();
					}
					else if (line.matches("^\\s?([A-Z\\+]+\\s)+[A-Z\\+]+$"))
					{
						if (candMap.isEmpty())
						{
							line = line.replaceAll("\\s\\+\\s", "+").trim();
							lineArr = line.split("\\s");
							for (int i = 0; i < lineArr.length; i++)
							{
								candMap.put(i, new CandidateData(year, st.getState(), st.getGeoType(),
										off, lineArr[i] + " Candidate", lineArr[i], dist));
							}
						}
						else break;
					}
					else if (m.matches() && !line.contains("Total") && !line.contains("RECAP"))
					{
						String location = m.group(1);
						line = line.replace(m.group(1), "").trim();
						lineArr = line.trim().split("\\s", -1);
						
						for (Integer i : candMap.keySet())
						{
							candMap.get(i).addData(new ElectionData(location,
									Integer.parseInt(lineArr[i].replaceAll(",", "").trim()), -1.0));
						} 
					}
				} //end loop through lines
				
				for (Integer i : candMap.keySet())
					out.write(candMap.get(i).getRows());
			} //end loop through offices
		} //end loop through years
		
		out.close();
	}
}
