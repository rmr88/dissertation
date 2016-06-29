package utilities;

import java.io.IOException;

public class SampleFile
{
	public static void main(String args[])
	{
		String path = "C:\\Users\\Robbie\\Documents\\gunPolicy\\Data\\BonicaData";
		try
		{
			InFile in = new InFile(path + "\\contribDB_2002.txt");
			OutFile out = new OutFile(path + "\\contribDB_2002_samp2.txt", false);
			
			for (int row = 0; row < 2931520; row++)
				in.readLine();
			
			for (int row = 2931520; row < 2931540; row++)
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
