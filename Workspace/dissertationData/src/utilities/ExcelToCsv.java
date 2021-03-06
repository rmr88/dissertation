package utilities;

import java.io.File;

import tasks.RunShell;

public class ExcelToCsv
{
	private static String dir = "C:\\Users\\Robbie\\Documents\\dissertation\\Code";
	private static String command = "XlsToCsv.vbs";
	
	public static void run(File path, String fileType)
	{
		for (String filePath: path.list())
		{
			File file = new File(path + "\\" + filePath);
			if (file.isDirectory())
			{
				System.out.println("going into " + filePath);
				run(file.getAbsoluteFile(), fileType);
			}
			else if (file.getPath().endsWith(fileType))
			{
				RunShell shell = new RunShell(command + " " + path + "\\" + filePath
						+ " " + fileType, dir);
				System.out.println("attempting conversion for " + filePath + "...");
				System.out.print(shell.run());
			}
		}
	}
}
