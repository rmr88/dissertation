package utilities;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public class InFile
{
	private String readDir;
	private BufferedReader reader;
	
	public InFile(String _readDir) throws FileNotFoundException
	{
		File fin = new File(_readDir);
		if (!fin.exists()) throw new FileNotFoundException("Path given for input does not exist.");
		if (!fin.isFile()) throw new FileNotFoundException("Path given for input is not a file.");
		this.readDir = _readDir;
		this.reader = new BufferedReader(new FileReader(fin));
	}
	
	public InFile(File _inFile) throws FileNotFoundException
	{
		if (!_inFile.exists()) throw new FileNotFoundException("Path given for input does not exist.");
		if (!_inFile.isFile()) throw new FileNotFoundException("Path given for input is not a file.");
		this.readDir = _inFile.getAbsolutePath();
		this.reader = new BufferedReader(new FileReader(_inFile));
	}
	
	public String readLine() throws IOException
	{
		return this.reader.readLine();
	}
	
	public String readUntil(String stop, boolean includeStop) throws IOException
	{
		String data = "";
		char[] dataArray = new char[1];
		int charRead = 0;
		while (!data.endsWith(stop) & charRead != -1)
		{
			charRead = reader.read(dataArray, 0, 1);
			data += dataArray[dataArray.length-1];
		}
		
		if (!includeStop)
			data = data.substring(0, data.indexOf(stop));
		
		return data;
	}
	
	public ArrayList<String> readRow(String delim) throws IOException
	{
		ArrayList<String> row = new ArrayList<String>();
		
		String[] line = this.reader.readLine().split(delim);
		for (String cell : line)
			row.add(cell);
		
		return row;
	}
	
	public String[] readRowLite(String delim) throws IOException
	{
		String[] row = null;
		try
		{
			row = this.reader.readLine().split(delim, -1);
		}
		catch (NullPointerException e) {}
		
		return row;
	}
	
	public boolean isReady()
	{
		boolean state = false;
		try
		{
			state = this.reader.ready();
		}
		catch (IOException e)
		{
			System.err.println("Error checking ready state of InFile object.");
			e.printStackTrace();
		}
		return state;
	}
	
	public String getDir()
	{
		return this.readDir;
	}
	
	public void close()
	{
		try
		{
			this.reader.close();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
	
	public static String determineDelimiter(String text)
	{
		if (text.matches("^([^\t]*\t{1})+[^\t]*$"))
			return "\t";
		else if (text.matches("^([^\\|]*\\|{1})+[^\\|]*$"))
			return "\\|"; //backslashes included because delimiters are primarily used by String#split, which takes regex 
		else if (text.matches("^([^,]*(\"?,\"?){1})+[^,]*$"))
			return ",";
		else
			return null;
	}
}
