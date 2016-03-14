package launchers;

import java.io.File;
import utilities.ExcelToCsv;

public class ExcelToTabMain
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\"
				+ "elections\\stateResults\\ME";
//		ExcelToCsv.run(new File(path), ".XLS");
		ExcelToCsv.run(new File(path), ".xlsx");
	}
}
