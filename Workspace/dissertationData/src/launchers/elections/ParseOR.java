package launchers.elections;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import tasks.ParsePDF;
import utilities.ElectionData;
import utilities.OutFile;
import utilities.State;

public class ParseOR
{
	public static void main(String args[]) throws IOException
	{
		State st = State.OR;
		
		OutFile out = null;
		try
		{
			out = new OutFile(st.getPath() + "\\OR_county.txt", false);
			out.writeLine("state\tyear\tgeographyType\tcandName\toffice\tdistrict\tparty\t"
					+ "locationName\tvotes\tvotePerc");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		Pattern p = Pattern.compile("^\\s?([a-zA-Z\\.\\s]+)(\\s[\\d,]+){3,}\\s?$");
		
		for (Integer year : st.getYears())
		{ //loop through years
			System.out.println(year);
			String pdfText = ParsePDF.getText(st.getPath() + "\\" + year + ".pdf");
			String[] pdfLines = pdfText.split("\r\n");
			
//			System.out.println(pdfText.substring(0, 1000));
			String off = "";
			String dist = "";
			for (int line = 0; line < pdfLines.length; line++)
			{ //loop through lines of file
				while (!off.equals("") && !pdfLines[line].toUpperCase().contains("TOTAL")
						&& line < pdfLines.length && !pdfLines[line].toUpperCase().contains("DISTRICT"))
				{
					line++;
					Matcher m = p.matcher(pdfLines[line]);
					
					ArrayList<String> names = new ArrayList<String>();
					System.out.println(off + " " + dist);
					while (!m.matches() && !pdfLines[line].contains("|") &&
							ElectionData.checkStatic(pdfLines[line]).equals("") &&
							!pdfLines[line].toUpperCase().contains("DISTRICT"))
					{
						String[] n;
						if (pdfLines[line].contains(")"))
						{
							pdfLines[line] = pdfLines[line].replace("County ", "");
							n = pdfLines[line].split("\\)\\s");
							for (int i = 0; i < n.length; i++)
								names.set(i, names.get(i) + " " + n[i]);
						}
						else
						{
							n = pdfLines[line].split("\\s");
							for (int i = 0; i < n.length; i++)
								names.add(n[i].replaceAll("\\*", ""));
						}

						line++;
						m = p.matcher(pdfLines[line]);
					}
					
					System.out.println(Arrays.toString(names.toArray()));
					
					while(m.matches() && ElectionData.checkStatic(pdfLines[line]).equals(""))
					{
						line++;
						m = p.matcher(pdfLines[line]);
					}
					
					names.clear();
//						if (pdfLines[line].toUpperCase().contains("DISTRICT"))
//							dist = pdfLines[line].replaceAll("\\D", "");
					
					line++;
				}
				off = ElectionData.checkStatic(pdfLines[line]);
			} //end loop through lines
		} //end loop through years
	}
}
