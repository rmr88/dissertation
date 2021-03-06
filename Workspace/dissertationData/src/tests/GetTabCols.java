package tests;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import utilities.InFile;
import utilities.OutFile;

public class GetTabCols
{
	public static void main(String args[])
	{
		File headerFile = new File("resources\\columnNames.txt");
		
		String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections";
		File[] tabFiles = new File(basePath + "\\EDAD").listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					return name.endsWith(".tab");
				}
			});
		
		InFile in = null;
		ArrayList<String> cols = new ArrayList<String>();
		HashMap<String, String> outMap;
		String line;
		String[] headerArr, lineArr;
		ArrayList<HashMap<String, String>> outputArray = new ArrayList<HashMap<String, String>>();
		HashMap<String, ArrayList<String>> inputMap = new HashMap<String, ArrayList<String>>();
		int offset = 0;
		
		try
		{
			OutFile out = new OutFile(basePath + "\\edadCombined.txt", false);
			in = new InFile(headerFile);
			while ((line = in.readLine()) != null)
				cols.add(line);
			out.writeRow(cols.toArray(), "\t", "YYYY");
			//System.out.println(cols.size());
			
			//For getting initial columnNames.txt file.
//			for (String piece : line)
//			{
//				if (piece.matches("^g\\d{4}_.*"))
//					piece = "gYYYY" + piece.substring(5);
//				if (piece.matches("^r\\d{4}_.*"))
//					piece = "rYYYY" + piece.substring(5);
//				
//				if (!cols.contains(piece))
//					cols.add(piece);
//			}
			
			for (int file = 0; file < 10; file++) //File f : tabFiles)
			{
				System.out.print(tabFiles[file].getName() + "... ");
				in = new InFile(tabFiles[file]);
				headerArr = in.readRowLite("\t");
				
				System.out.print("Headers... ");
				for (int i = 0; i < headerArr.length; i++)
				{
					if (headerArr[i].matches("^g\\d{4}_.*"))
						headerArr[i] = "gYYYY" + headerArr[i].substring(5);
					if (headerArr[i].matches("^r\\d{4}_.*"))
						headerArr[i] = "rYYYY" + headerArr[i].substring(5);
					
//					if (cols.contains(headerArr[i]))
						inputMap.put(headerArr[i], new ArrayList<String>());
//					else
//						inputMap.put(headerArr[i], -1);
				}
				
				System.out.print("Data... ");
				while ((lineArr = in.readRowLite("\t")) != null)
				{
					offset = 0;
					
//					outMap = new HashMap<String, String>();
					
					for (int i = 0; i < lineArr.length; i++)
					{
						//System.out.println("piece = " + lineArr[i] + "(header is " + headerArr[i] + ")");
						inputMap.get(headerArr[i]).add(lineArr[i]);
					}
//					while (i < lineArr.length || i + offset < cols.size())
//					{
//						System.out.println("i = " + i + "; offset = " + offset);
//						if (inputMap.containsKey(cols.get(i + offset)))
//						{
//							if (inputMap.get(cols.get(i + offset)) != -1)
//							{
//								System.out.println(headerArr[i] + ": " + lineArr[i] + "; " + cols.get(i+offset));
//								outMap.put(cols.get(i + offset), lineArr[i]);
//							}
//							i++;
//						}
//						else
//						{
//							outMap.add("");
//							offset++;
//						}
//					}
//					out.writeRow(outArray.toArray(), "\t");
//					outArray.clear();
				}
				System.out.print("Write... ");
				while (inputMap.get(headerArr[0]).size() > 0)
				{
					for (String col : cols)
					{
						if (inputMap.containsKey(col))
							out.write(inputMap.get(col).remove(0) + "\t"); //TODO throws out of bounds exception here; figure out why
						else
							out.write("\t");
					}
					out.write("\r\n");
				}
				inputMap.clear();
				System.out.println("Done.");
			}
			
			
			out.close();
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
		
//		for (String col : cols)
//			System.out.println(col);
	}
}
