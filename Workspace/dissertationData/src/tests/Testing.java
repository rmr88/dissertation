package tests;

import java.io.File;
import utilities.ExcelToCsv;

public class Testing
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\"
				+ "elections\\stateResults\\AL";
		//ExcelToCsv.run(new File(path), ".XLS");
		ExcelToCsv.run(new File(path), ".xls");
	}
}
