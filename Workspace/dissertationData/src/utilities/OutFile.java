package utilities;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

public class OutFile
{
	private String writeDir;
	private BufferedWriter writer;
	
	public OutFile(String _writeDir) throws IOException
	{
		File fout = new File(_writeDir);
		if (fout.exists()) throw new FileNotFoundException("File exists. Add append/overwrite boolean parameter to constructor to use existing file");
		if (fout.isDirectory())
		{
			this.writeDir = _writeDir + File.separatorChar + "output.txt";
			System.out.println("Output path is directory; output will be written to " + this.writeDir + ".");
		}
		else if (checkPath(fout))
			this.writeDir = _writeDir;
		else
			throw new FileNotFoundException("Cannot write to output file.");
		this.writer = new BufferedWriter(new FileWriter(fout, false));
	}
	
	public OutFile(String _writeDir, boolean append) throws IOException
	{
		File fout = new File(_writeDir);
		if (checkPath(fout))
			this.writeDir = _writeDir;
		else
			throw new FileNotFoundException("Cannot write to output file.");
		this.writer = new BufferedWriter(new FileWriter(fout, append));
	}
	
	public OutFile(File file, boolean append) throws IOException
	{
		if (checkPath(file))
			this.writeDir = file.getAbsolutePath();
		else
			throw new FileNotFoundException("Cannot write to output file.");
		this.writer = new BufferedWriter(new FileWriter(file, append));
	}

	public void writeLine(String line) throws IOException
	{
		this.writer.write(line);
		this.writer.newLine();
		this.writer.flush();
	}
	
	public void write(String str) throws IOException
	{
		this.writer.write(str);
		this.writer.flush();
	}
	
	public void writeRow(Object[] row, String delim) throws IOException
	{
		int limit = row.length-1;
		for (int i = 0; i < limit; i++)
			this.writer.write(row[i].toString() + delim);
		
		this.writer.write(row[limit].toString());
		this.writer.newLine();
		this.writer.flush();
	}
	
	public void writeRow(Object[] row, String delim, String remove) throws IOException
	{
		int limit = row.length-1;
		for (int i = 0; i < limit; i++)
			this.writer.write(row[i].toString().replace(remove, "") + delim);
		
		this.writer.write(row[limit].toString());
		this.writer.newLine();
		this.writer.flush();
	}
	
	@SuppressWarnings("rawtypes")
	public void writeRow(ArrayList row, String delim) throws IOException
	{
		int limit = row.size()-1;
		for (int i = 0; i < limit; i++)
			this.writer.write(row.get(i).toString() + delim);
		
		this.writer.write(row.get(limit).toString());
		this.writer.newLine();
		this.writer.flush();
	}
	
	public String getDir()
	{
		return this.writeDir;
	}
	
	public void flush()
	{
		try
		{
			this.writer.flush();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
	
	public void close()
	{
		try
		{
			this.writer.flush();
			this.writer.close();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
	
	private boolean checkPath(File path)
	{
		try
		{
			path.getCanonicalPath();
			return true;
		}
		catch (Exception e)
		{
			return false;
		}
	}
}
