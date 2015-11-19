package tests;

import tasks.RunShell;

public class ShellLaunch
{
	public static void main(String args[])
	{
		String command = "rsyncBatch";
		String dir = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\GovTrack";
		String[] params = { "bills/", "rolls/", "people.xml", "bills.index.xml" };
		
		for (int cong = 93; cong <= 113; cong++)
		{
			for (String param : params)
			{
//				if (!(new File(dir + "\\" + Integer.toString(cong)).exists()))
//					new File(dir + "\\" + Integer.toString(cong)).mkdirs();
				
				RunShell shell = new RunShell(command + " " + Integer.toString(cong) + " " + param, dir);
				System.out.println(shell.run());
			}
			
			System.out.println(cong + " read to disk.");
		}
	}

}
