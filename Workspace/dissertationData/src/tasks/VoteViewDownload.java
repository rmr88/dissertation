package tasks;

import java.io.IOException;
import utilities.WebFile;

public class VoteViewDownload
{
	private String dataURL, dictURLstub, outFileFolder;
	private int congMin = 93;
	private int congMax = 113;
	
	public VoteViewDownload(String _url, String _outFileFolder)
	{
		this.dataURL = _url;
		this.dictURLstub = _url.substring(0, _url.lastIndexOf("/")+1);
		this.outFileFolder = _outFileFolder;
	}
	
	public VoteViewDownload(String _url, String _outFileFolder,
			int _congMin, int _congMax)
	{
		this.dataURL = _url;
		this.dictURLstub = _url.substring(0, _url.lastIndexOf("/")+1);
		this.outFileFolder = _outFileFolder;
		this.congMin = _congMin;
		this.congMax = _congMax;
	}
	
	public void run() throws IOException
	{
		for (int cong = this.congMin; cong <= this.congMax; cong++)
		{
			//Roll Call Data
			new WebFile(this.dataURL.replace("#", "hou" + cong),
					this.outFileFolder + "\\hou" + cong + ".txt").downloadToFile();
			new WebFile(this.dataURL.replace("#", "sen" + cong),
					this.outFileFolder + "\\sen" + cong + ".txt").downloadToFile();
			
			//House Dictionaries
			try
			{
				new WebFile(this.dictURLstub + "h" + cong + "desc_final.csv",
						this.outFileFolder + "\\hou" + cong + "desc_final.txt").downloadToFile();
			}
			catch (IOException e)
			{
				try
				{
					new WebFile(this.dictURLstub.replace("dtaord", "dtl") + cong + ".dtl",
							this.outFileFolder + "\\hou" + cong + "desc_dtl.txt").downloadToFile();
				}
				catch (IOException e1)
				{
					new WebFile("http://voteview.com/house" + cong + ".htm",
							this.outFileFolder + "\\hou" + cong + "desc_htm.txt").downloadToFile();
				}
			}
			
			//Senate Dictionaries
			try
			{
				new WebFile(this.dictURLstub + "s" + cong + "desc_final.csv",
						this.outFileFolder + "\\sen" + cong + "desc_final.txt").downloadToFile();
			}
			catch (IOException e)
			{
				try
				{
					new WebFile(this.dictURLstub.replace("dtaord", "dtl") + cong + "s.dtl",
							this.outFileFolder + "\\sen" + cong + "desc_dtl.txt").downloadToFile();
				}
				catch (IOException e1)
				{
					new WebFile("http://voteview.com/senate" + cong + ".htm",
							this.outFileFolder + "\\sen" + cong + "desc_htm.txt").downloadToFile();
				}
			}
			
			//end for loop
		}
	}
}
