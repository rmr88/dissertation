package tests;

import java.io.IOException;

import utilities.*;

public class TestIO
{
	public static void main(String args[])
	{
		try
		{
			InFile in = new InFile("C:\\Users\\Robbie\\Documents\\testInput.txt");
			OutFile out = new OutFile("C:\\Users\\Robbie\\Documents\\testOutput.txt");
			out.writeLine(in.readLine());
			out.writeLine(in.readUntil("here", true));
			out.write(in.readLine());
			out.writeLine(in.readLine());
			out.writeLine("");

			out.writeRow(in.readRow("\t"), ";");
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}
