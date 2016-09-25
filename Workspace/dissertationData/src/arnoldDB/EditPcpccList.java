package arnoldDB;

import java.io.IOException;

import utilities.InFile;
import utilities.OutFile;

public class EditPcpccList
{
	public static void main(String args[]) throws IOException
	{
		String[] outcomes = {"Cost Savings", "Improved Health", 
				"Increased Prevention Services", "Improved Patient/Clinician Satisfaction",
				"Fewer ED / Hospital Visits", "Improved Access"};
		
		InFile in = new InFile("C:\\Users\\Robbie\\Documents\\ArnFound\\Data\\pcpccList_updated.txt");
		OutFile out = new OutFile("C:\\Users\\Robbie\\Documents\\ArnFound\\Data\\pcpccList_update2.txt", false);
		
		out.writeLine(in.readLine());
		
		while (in.isReady())
		{
			String[] line = in.readRowLite("\t");
			String results = line[3];
			String[] resultsArr = {"", "", "", "", "", ""};
			
			if (!results.equals("None"))
			{
				for (int i = 0; i < outcomes.length; i++)
					if (results.contains(outcomes[i]))
						resultsArr[i] = "Y";
			}
			
			for (int j = 0; j < line.length-1; j++)
			{
				if (j == 3)
					for (int i = 0; i < outcomes.length; i++)
						out.write(resultsArr[i] + "\t");
				else
					out.write(line[j] + "\t");
			}
			out.writeLine(line[line.length-1]);
		}
		in.close();
		out.close();
	}
}
