package launchers;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import tasks.ParsePDF;
import utilities.OutFile;

public class IAscraper
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections\\stateResults\\IA";
		String pdfText = ParsePDF.getText(path + "\\IA2004_precinct.pdf");
		String[] pdfLines = pdfText.split("\r\n");
		
		OutFile out = null;
		try
		{
			out = new OutFile(path + "\\IA2004_precinct.txt", false);
			out.writeLine("county\tcountyNum\tprecinct\tuspDem\tuspRep\tuspOth\tuspSc\tussDem\tussRep\tussOth"
					+ "\tussSc\tushDem\tushRep\tushOth\tushSc\tstsDem\tstsRep\tstsOth\tstsSc\tsthDem\tsthRep"
					+ "\tsthOth\tsthSc\tld\tsd\tcd");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		Pattern p = Pattern.compile("^([a-zA-z\\s]+)\\s(\\d\\d)\\s(.+)\\s(([\\d,xX]+\\s){22}[\\d,xX]+)$");
		
		for (int l = 0; l < pdfLines.length; l++)
		{
			Matcher m = p.matcher(pdfLines[l]);
			if (m.matches())
			{
				try
				{
					out.writeLine(m.group(1) + "\t" + m.group(2) + "\t" + m.group(3) + "\t"
							+ m.group(4).replaceAll(" ", "\t"));
				}
				catch (IOException e)
				{
					System.err.println("Error in writing line " + pdfLines[l]);
					e.printStackTrace();
				}
			}
		}
	}
}
