package launchers.govTrack;

import java.io.File;
import tasks.RunShell;

/**
 * Reads bill and roll call vote data from GovTrack.us (via their rsync tool) to local directory.
 * The directory and the limits on Congresses (80-113) are hard-coded.
 *  
 * @author Robbie
 *
 */
public class DownloadData
{
	public static void main(String args[])
	{
		String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\GovTrack";
		RunShell shell = null;
		for (int cong = 80; cong < 114; cong++)
		{
			File dir = new File(basePath + "\\" + cong);
			if (!dir.exists())
				dir.mkdirs();
			
			shell = new RunShell("rsyncBatch " + cong + " bills", basePath);
			System.out.print(shell.run());
			
			shell = new RunShell("rsyncBatch " + cong + " rolls", basePath);
			System.out.print(shell.run());
			
			shell = new RunShell("rsync -az --delete --timeout=120 govtrack.us::govtrackdata/us/" 
					+ cong + "/people.xml " + cong + "/people.xml", basePath);
			System.out.print(shell.run());
		}
	}
}
