package launchers;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import utilities.WebFile;

public class DownloadCDshpFiles
{
	public static void main(String args[])
	{
		String baseUrl = "http://cdmaps.polisci.ucla.edu/shp/districts";
		String baseDir = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\cdShp\\cd";
		
		String cong, url, dir;
		WebFile web = null;
		for (int c = 42; c < 114; c++)
		{ //loop through congresses
			cong = "" + c;
			if (cong.length() == 2)
				cong = "0" + cong;
			
			url = baseUrl + cong + ".zip";
			
			File folder = new File(baseDir + c);
			if (!folder.exists())
				folder.mkdirs();
			
			dir = baseDir + c + "\\cd" + c;
			try
			{
				web = new WebFile(url, dir + ".zip");
				web.downloadToFile();
				web.close();
			}
			catch (IOException e)
			{
				System.err.println("Error downloading file for " + c + " congress.");
				e.printStackTrace();
			}
			
			byte[] buffer = new byte[1024];
			try
			{
				ZipInputStream zis = new ZipInputStream(new FileInputStream(new File(dir + ".zip")));
				ZipEntry ze = zis.getNextEntry();

				while(ze!=null)
				{
					String fileExt = ze.getName().substring(ze.getName().lastIndexOf("."));
					File newFile = new File(dir + fileExt);
					FileOutputStream fos = new FileOutputStream(newFile);             

					int len;
					while ((len = zis.read(buffer)) > 0)
						fos.write(buffer, 0, len);

					fos.close();   
					ze = zis.getNextEntry();
				}

				zis.closeEntry();
				zis.close();
			}
			catch (IOException e)
			{
				System.err.println("Error unzipping file " + dir + ".zip.");
				e.printStackTrace();
			}
		} //end loop through congresses
	} //end main
}
