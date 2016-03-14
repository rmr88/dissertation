package launchers;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import utilities.InFile;
import utilities.OutFile;

public class SpssToDo
{
	public static void main (String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
				+ "\\elections\\ICPSRfedResults\\ICPSR_00001";
		Pattern pInfix = Pattern.compile("(V\\d+\\s\\d+\\-\\d+)(\\sV)");
		Pattern pLabels = Pattern.compile("(V\\d+\\s\"[\\w\\(\\)\\s]+\")(\\sV)");
		Pattern pMiss = Pattern.compile("(V\\d+\\s)\\((\\d+)\\)\\s?");
		
		File[] folders = new File(path).listFiles(new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
					return name.startsWith("DS") && !name.contains(".");
			}
		});
		
		for (File folder : folders)
		{
			String studyNum = folder.getName().replace("DS", "");
			File spss = new File(folder.getAbsolutePath() + "\\00001-" + studyNum + "-Setup.sps");
			
			if (spss.exists())
			{
				File doFile = new File(folder.getAbsolutePath() + "\\setup" + studyNum + ".do");
				InFile in = null;
				OutFile out = null;
				try
				{
					out = new OutFile(doFile, false);
					out.write("//Auto-generated code, parsed from " + spss.getAbsolutePath()
							+ "\r\n\r\ncd \"" + folder.getAbsolutePath() + "\"\r\n\r\n");
				}
				catch (IOException e)
				{
					System.err.println("Error creating DO file in DS" + studyNum);
				}

				try
				{
					in = new InFile(spss);
					
					//Infix statement:
					in.readUntil(" /", true);
					in.readLine();
					in.readLine();
					String line = "infix ///\r\n\t"
							+ in.readUntil(".", false).trim()
								.replaceAll("[\r\n]", "").replace("(A)", "")
								.replaceAll("\\s+", " ")
							+ " ///\r\n\tusing \"00001-" + studyNum + "-Data.txt\", clear";
					Matcher m = pInfix.matcher(line);
					while (m.find())
					{
						line = m.replaceAll("$1 ///\r\n\tV");
						m.reset(line);
					}
					out.writeLine(line + "\r\n\r\n");
					
					//Label statements:
					in.readUntil("VARIABLE LABELS", false);
					in.readUntil("VARIABLE LABELS", false);
					in.readLine();
					line = "//Variable labels\r\nlabel variable "
							+ in.readUntil(".", false).trim()
								.replaceAll("[\r\n]", "")
								.replaceAll("\\s+", " ");
					
					m = pLabels.matcher(line);
					while (m.find())
					{
						line = m.replaceAll("$1 \r\nlabel variable V");
						m.reset(line);
					}
					out.writeLine(line + "\r\n\r\n");
					
					//Missing value statements:
					in.readUntil("MISSING VALUES", false);
					in.readLine();
					line = "//Missing values\r\n"
							+ in.readUntil(".", false).trim()
								.replaceAll("[\r\n]", "")
								.replaceAll("\\s+", " ");
					m = pMiss.matcher(line);
					while (m.find())
					{
						line = m.replaceAll("replace $1= . if $1== $2\r\n");
						m.reset(line);
					}
					out.writeLine(line);
				}
				catch (IOException e)
				{
					System.err.println("Error reading spss file " + spss.getName());
					e.printStackTrace();
				}
				in.close();
				out.close();
			}
		}
	}
}
