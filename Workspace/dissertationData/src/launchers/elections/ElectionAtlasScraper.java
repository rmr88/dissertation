package launchers.elections;

import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlPage;
import com.gargoylesoftware.htmlunit.html.HtmlTable;
import com.gargoylesoftware.htmlunit.html.HtmlTableRow;

import utilities.OutFile;

public class ElectionAtlasScraper
{
	public static void main(String args[])
	{
		Logger.getLogger("com.gargoylesoftware").setLevel(Level.OFF);
		HtmlPage page = null;
		
		String baseURL = "http://uselectionatlas.org/RESULTS/state.php?fips=%d&year=%d&f=0&off=3&elect=0&class=%d";
		
		OutFile out = null;
		try
		{
			out = new OutFile("C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections"
					+ "\\stateResults\\ussData.txt", true);
			//out.writeLine("stateFIPS\tyear\toffice\tclass\tcandName\tparty\tvotes\tvotePerc\turl");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file.");
			e.printStackTrace();
		}
		
		List<HtmlTable> table = null;
		List<HtmlTableRow> rows = null;
		
		for (int year = 2000; year < 2016; year += 2)
		{
			WebClient wc = new WebClient(BrowserVersion.FIREFOX_38);
			System.out.println(year);
			int senClass = (year % 6) / 2;
			if (senClass == 0) senClass = 3;
			
			for (int fips = 1; fips <= 56; fips++)
			{
				System.out.print(fips + ", ");
				try
				{
					page = wc.getPage(new URL(String.format(baseURL, fips, year, senClass)));
					table = (List<HtmlTable>) page.getByXPath("//table[@class='result']");
					
					if (table.size() > 0)
					{
						rows = table.get(0).getBodies().get(0).getRows();
						for (HtmlTableRow row : rows)
							out.writeLine(fips + "\t" + year + "\tUSS\t" + senClass + row.asText()
								+ "\t" + page.getBaseURL());
					}
				}
				catch (IOException e)
				{
					System.err.println("Error reading data for FIPS " + fips + ", year " + year + ".");
					e.printStackTrace();
				}
			}
			System.out.println("");
			wc.close();
		}
		
		out.close();
	}
}
