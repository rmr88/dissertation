package launchers;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import utilities.DataObj;
import utilities.InFile;
import utilities.OutFile;

public class AppendData
{
	public static void main(String args[])
	{
	//****  Helper Objects  ****//
		String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections";
		String delim = "\t";
		String fileType = ".tab";
		
		File[] dataFiles = new File(basePath + "\\EDAD").listFiles(new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
				return name.endsWith(fileType);
			}
		});
			
		InFile hdrFile = null;
		InFile in = null;
		OutFile out = null;
		
		ArrayList<String> headers = new ArrayList<String>();
		HashMap<String, DataObj> data = new HashMap<String, DataObj>();
		
		String[] heads, row;
		int rows;
		String line = "";
	//end helper objects
		
		try //try global header processing
		{
			hdrFile = new InFile(System.getProperty("user.dir") + "\\resources\\columnNames.txt");
			while((line = hdrFile.readLine()) != null)
				headers.add(line);
		}
		catch (IOException e)
		{
			System.err.println("Error in reading header file.");
		}
		finally
		{
			hdrFile.close();
		} //end global header processing
		
		try //try creating out file, writing header line
		{
			out = new OutFile(basePath + "\\edadCombined.txt", false);
			out.writeRow(headers.toArray(), delim, "YYYY");
		}
		catch(IOException e)
		{
			System.err.println("Error in creating out file.");
		} //end creating out file
		
		for (File file : dataFiles) //loop through dataFiles array; DEBUGGING: for (int f = 0; f < 10; f++)
		{
			data.clear();
			rows = 0;
			//File file = dataFiles[f]; //DEBUGGING
			
			try //try to read next file
			{
				in = new InFile(file);
				heads = in.readRowLite("\t");
				for (int index = 0; index < heads.length; index++)
				{
					if (heads[index].matches("^g\\d{4}_.*"))
						heads[index] = "gYYYY" + heads[index].substring(5);
					if (heads[index].matches("^r\\d{4}_.*"))
						heads[index] = "rYYYY" + heads[index].substring(5);
					
					data.put(heads[index], new DataObj(heads[index]));
				}
				
				int rowIndex = 0;
				while ((row = in.readRowLite("\t")) != null)
				{
					for (int colIndex = 0; colIndex < row.length; colIndex++)
						data.get(heads[colIndex]).addData(row[colIndex]);
					rowIndex++;
				}
				
				if (rowIndex > rows)
						rows = rowIndex;
			}
			catch (IOException e)
			{
				System.err.println("Error in reading file " + file.getName() + ".");
			} //end try read file
			
			try //try writing
			{
				System.out.println(file.getName() + ": rows = " + rows);
				for (int index = 0; index < rows; index++)
				{
					for (int i = 0; i < headers.size()-1; i++)
					{
						if (data.containsKey(headers.get(i)))
							out.write(data.get(headers.get(i)).getData().get(index) + delim);
						else
							out.write(delim);
					}
					if (data.containsKey(headers.get(headers.size()-1)))
						out.writeLine(data.get(headers.get(headers.size()-1)).getData().get(index));
					else
						out.writeLine("");
				}
			}
			catch (IOException e)
			{
				System.err.println("Error in writing data for " + file.getName() + ".");
			}
			finally
			{
				out.flush();
			} //end try writing
		} //end for loop through dataFiles
		out.close();
	} //end main
} //end AppendData
