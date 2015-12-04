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
	
	public boolean isReady() throws IOException
	{
		return this.reader.ready();
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
}
