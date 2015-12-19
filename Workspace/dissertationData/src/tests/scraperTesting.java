package tests;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.gargoylesoftware.htmlunit.FailingHttpStatusCodeException;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.DomElement;
import com.gargoylesoftware.htmlunit.html.HtmlPage;
import com.gargoylesoftware.htmlunit.html.HtmlTable;
import com.gargoylesoftware.htmlunit.html.HtmlTableCell;
import com.gargoylesoftware.htmlunit.html.HtmlTableRow;

import utilities.CandidateData;
import utilities.ElectionData;
import utilities.OutFile;

public class scraperTesting
{
	public static void main(String args[])
	{
		Logger.getLogger("com.gargoylesoftware").setLevel(Level.OFF);
		final WebClient wc = new WebClient(BrowserVersion.FIREFOX_38);

		ArrayList<DomElement> offices = new ArrayList<DomElement>();
		HtmlPage page = null;
		
		//TODO get these dynamically (and probably incorporate into outPath as well)
		String state = "NV";
		String[] locations = {"CarsonCity", "Churchill", "Clark", "Douglas",
				"Elko", "Esmeralda", "Eureka", "Humboldt", "Lander",
				"Lincoln", "Lyon", "Mineral", "Nye", "Pershing", "Storey",
				"Washoe", "WhitePine"};
		String type = "county";
		int[] years = {2014, 2012, 2010, 2008, 2006, 2004, 2002, 2000};
		
		for (int year : years)
		{
			String outPath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
					+ "\\elections\\stateResults\\" + state +"\\" + year + ".txt";
			OutFile out = null;
			
			try
			{
				out = new OutFile(outPath, false);
			}
			catch (IOException e)
			{
				System.err.println("Error in setting up output file " + outPath);
				e.printStackTrace();
			}
			
			for (String location : locations)
			{
				try
				{
					String url = "http://www.nvsos.gov/soselectionpages/results/"
							+ year + "STatewideGeneral/" + location + ".aspx";
					page = wc.getPage(url);
					DomElement office = null;
					int numTables = 1;

					do
					{
						try
						{
							office = page.getElementById("_ctl" + numTables + "_lblRaceTitle");
							if (office != null)
								offices.add(office);
							numTables++;
						}
						catch (NullPointerException e) { }
					}
					while (office != null);
				}
				catch (FailingHttpStatusCodeException | IOException e)
				{
					e.printStackTrace();
				}
				
				@SuppressWarnings("unchecked")
				ArrayList<HtmlTable> tables = (ArrayList<HtmlTable>) page.getByXPath("//table[@class='tableData']");
				ElectionData data;
				for (int tableRow = 0; tableRow < offices.size(); tableRow++)
				{
					data = new ElectionData(state, type, location, year);
					data.setOffice(offices.get(tableRow).asText()); //TODO add a way to change the office names to universal codes (usp, uss, etc.)
					
					List<HtmlTableCell> cells = new ArrayList<HtmlTableCell>(); 
					for (HtmlTableRow row : tables.get(tableRow).getRows()) //TODO Fix ugly hard-coding in this for loop
					{
						cells = row.getCells();
						try
						{
							data.addData(new CandidateData(cells.get(0).asText(),
									cells.get(1).asText(),
									Integer.parseInt(cells.get(3).asText().replaceAll(",", "")),
									Double.parseDouble(cells.get(2).asText().replace("%", ""))));
						}
						catch (NumberFormatException e) {}
					}
					
					try
					{
						out.write(data.getRows("\t"));
					}
					catch (IOException e)
					{
						System.err.println("Error in writing to file; data: " + data.getRows());
						e.printStackTrace();
					}
				}
				wc.close();
			}
			out.close();
		}
	}
}
