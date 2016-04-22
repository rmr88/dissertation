package utilities;

import java.io.IOException;

public class SampleFile
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections";
		try
		{
			InFile in = new InFile(path + "\\edadCombined2.txt");
			OutFile out = new OutFile(path + "\\edadCombined_samp.txt", false);
			
			for (int row = 0; row < 5; row++)
				out.writeLine(in.readLine());
			
			in.close();
			out.close();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
		
	}
}
