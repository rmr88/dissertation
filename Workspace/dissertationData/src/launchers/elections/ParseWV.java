package launchers.elections;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import tasks.ParsePDF;
import utilities.CandidateData;
import utilities.ElectionData;
import utilities.OutFile;
import utilities.State;

public class ParseWV
{
	public static void main(String args[])
	{
		State st = State.WV;
		
		OutFile out = null;
		try
		{
			out = new OutFile(st.getPath() + "\\WV_county2.txt", false);
			out.writeLine("state\tyear\tgeographyType\tcandName\toffice\tdistrict\tparty\t"
					+ "locationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		Pattern p = Pattern.compile("^\\s?([a-zA-Z\\.\\s]+)(\\s[\\d,]+)+\\s?$");
		
		for (Integer year : st.getYears())
		{
			System.out.println("Parsing " + year + "...");
			
			File[] files = new File(st.getPath()).listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					if (name.matches("^" + year + "[A-Z]*" + State.WV.getFileType() + "$")) return true;
					else return false;
				}
			});
			
			ArrayList<CandidateData> data = new ArrayList<CandidateData>();
			String office = "";
			
			String[] ptys = new String[] {"REPUBLICAN", "DEMOCRAT", "LIBERTARIAN", "MOUNTAIN",
					"CONSTITUTION", "WRITE-IN", "GREEN", "INDEPENDENT"};
			ArrayList<String> parties = new ArrayList<String>(Arrays.asList(ptys));
			
			
			for (File file : files)
			{
				if (file.getName().matches("^\\d{4}[A-Z]{3}" + st.getFileType()))
					office = file.getName().substring(4,7);
				
				String pdfText = ParsePDF.getText(file.getAbsolutePath());
				String[] pdfLines = pdfText.split("\r\n");
				for (int line = 0; line < pdfLines.length; line++)
				{
					Matcher m = p.matcher(pdfLines[line]);
					if (m.matches())
					{
						while (!pdfLines[line].contains("Totals") && m.matches())
						{
							pdfLines[line] = pdfLines[line].replace(m.group(1), "").trim();
							String[] votes = pdfLines[line].split("\\s");
							
							for (int cand = 0; cand < data.size(); cand++)
								data.get(cand).addData(new ElectionData(m.group(1),
										Integer.parseInt(votes[cand].trim().replaceAll("\\D", "")), -1.0));
							
							line++;
							m = p.matcher(pdfLines[line]);
							
						}
						
						line++;
						try
						{
							for (CandidateData cand : data)
								out.write(cand.getRows());
						}
						catch (IOException e)
						{
							System.err.println("Error writing results for " + year + ", " + office);
							e.printStackTrace();
						}
						data.clear();
					}
					else if (parties.contains(pdfLines[line].toUpperCase().trim()))
					{
						data.add(new CandidateData(year, st.getState(), st.getGeoType(),
								office, pdfLines[line-1].replace("County", "").trim(), pdfLines[line].trim(), ""));
					}
					else if (pdfLines[line].contains("("))
					{
						String party = "";
						if (pdfLines[line].toUpperCase().equals("(WRITE-IN) "))
						{
							party = "WI";
							line++;
						}
						else
							party = pdfLines[line].substring(pdfLines[line].lastIndexOf("(")+1,
									pdfLines[line].lastIndexOf(")"));
						
						data.add(new CandidateData(year, st.getState(), st.getGeoType(),
								office, pdfLines[line].substring(0, pdfLines[line].lastIndexOf("(")).trim(),
								party, ""));
					}
					else if (!ElectionData.checkStatic(pdfLines[line]).equals(""))
						office = ElectionData.checkStatic(pdfLines[line]);
				}
			}
		}
		
		out.close();
	}
}
