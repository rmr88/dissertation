package launchers;

import java.io.IOException;

import tests.JSONReader;

public class JSONLauncher
{
	public static void main(String args[])
	{
		try //TODO set up a queue, split the downloading and parsing into two tasks, and have the downloader fill a queue and pause between downloads
		{
			JSONReader jr = new JSONReader("C:\\Users\\Robbie\\Documents\\dissertation\\Data\\GovTrack\\hr359test.txt");
			//jr.run("https://www.govtrack.us/data/congress/111/bills/hr/hr359/data.json");
			//jr.run("https://www.govtrack.us/data/congress/111/bills/hr/hr3590/data.json");
			jr.run("congress/111/bills/hr/hr3591/data.json");
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}
