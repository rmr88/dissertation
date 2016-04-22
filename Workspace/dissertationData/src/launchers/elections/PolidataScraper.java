package launchers.elections;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import tasks.ParsePDF;
import utilities.InFile;
import utilities.OutFile;
import utilities.WebFile;

public class PolidataScraper
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections\\polidata";
		InFile in = null;
		ArrayList<String[]> links = new ArrayList<String[]>();
		
		//Compile Link/ file list
		try
		{
			in = new InFile(path + "\\_pdfList.txt");
			while (in.isReady())
				links.add(in.readRowLite("\t"));
			in.close();
		}
		catch (IOException e)
		{
			System.err.println("Error in reading PDF list.");
			e.printStackTrace();
		}
		
		//Download files to hard drive if necessary
		WebFile web = null;
		for (String[] link : links)
		{
			if (!(new File(path + "\\" + link[0] + ".pdf").exists()))
			try
			{
				web = new WebFile(link[1], path + "\\" + link[0] + ".pdf");
				web.downloadToFile();
				web.close();
			}
			catch (IOException e)
			{
				System.err.println("Error in downloading " + link[0] + " PDF from " + link[1]);
				e.printStackTrace();
			}
		}
		
		OutFile out = null;
		try
		{
			out = new OutFile(path + "\\_polidataResults.txt", false);
			out.writeLine("state\tdistrict\tyear\tOffice\tDemVote\tRepVote\tOthVote\tTotVote\t"
					+ "DemPerc\tRepPerc\tOthPerc\tMargin\tmargPerc\tWinner");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		for (String[] link : links)
		{
			String pdfText = ParsePDF.getText(path + "\\" + link[0] + ".pdf");
			String[] pdfLines = pdfText.split("\r\n");
			
			String state = link[0].substring(0, 2);
			String district = "";
			
			Pattern distP = Pattern.compile("^(" + state + ")+\\s+(\\d+)\\s+.*$");
			
			String presLine = "";
			String congLine = "";
			
			for (int l = 0; l < pdfLines.length; l++)
			{
				Matcher m = distP.matcher(pdfLines[l]);
				if (m.matches())
					district = m.group(2);
				if (pdfLines[l].matches("^\\d{4}\\s+Pres\\.\\s+([\\d\\.,]+\\s+)+[a-zA-z]+$"))
				{
					presLine = pdfLines[l].replaceAll("\\s+", "\t").trim();
					while (!pdfLines[l].matches("^\\d{4}\\s+Cong\\.\\s+([\\d\\.,]+\\s+)+[a-zA-z]+$"))
						l++;
					congLine = pdfLines[l].replaceAll("\\s+", "\t").trim();
					
					if (!presLine.substring(0, 4).equals(congLine.substring(0, 4)))
						presLine = presLine.replace(presLine.substring(0, 4), congLine.substring(0, 4));
					
					try
					{
						out.writeLine(state + "\t" + district + "\t" + presLine);
						out.writeLine(state + "\t" + district + "\t" + congLine);
					}
					catch (IOException e)
					{
						System.err.println("Error writing line to file: " + pdfLines[l]);
						e.printStackTrace();
					}
				}
			}
		}
		
		out.close();
	}
}
