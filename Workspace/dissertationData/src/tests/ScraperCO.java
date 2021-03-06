package tests;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
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

public class ScraperCO
{
	public static void main(String args[])
	{
		Logger.getLogger("com.gargoylesoftware").setLevel(Level.OFF);
		final WebClient wc = new WebClient(BrowserVersion.FIREFOX_38);

		HtmlPage page = null;

		String state = "CO";
		String[] offices = {"president", "usSenate", "congress", "governor", "sos",
				"treasurer", "attGen", "education", "senate@", "representatives@"}; //TODO fix office/ year combinations
		String type = "county";
		int[] years = {2014, 2012}; //TODO could add 2010, but that requires a new scraper
		
		for (String office : offices)
			ElectionData.checkStatic(office);
			
		for (int year : years)
		{
			System.out.println("Year: " + year);
			
			for (String off : offices)
			{
				try
				{
					String url = "http://www.sos.state.co.us/pubs/elections/"
							+ "Results/Abstract/" + year + "/general/"
							+ off.replace("@", "") + ".html";
					page = wc.getPage(url);
				}
				catch (FailingHttpStatusCodeException e)
				{
					continue; //goes to next array element if URL doesn't work; need to be careful with this...
				}
				catch (IOException e)
				{
					e.printStackTrace();
				}
				
				String office = ElectionData.checkStatic(off);
				System.out.println(office);
				
				String outPath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
						+ "\\elections\\stateResults\\" + state + "\\" + year
						+ office.toLowerCase() + "_" + type + ".txt";
				
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
				
				@SuppressWarnings("unchecked")
				ArrayList<HtmlTable> tables = (ArrayList<HtmlTable>) page.getByXPath("//table");
				ArrayList<HtmlTable> tables2 = new ArrayList<HtmlTable>();
				for (HtmlTable table : tables)
					if (table.asText().contains("County"))
						tables2.add(table);
				
				if (office.equals("USP"))
				{
					tables.clear();
					tables.add(tables2.get(0));
				}
				else
					tables = tables2;
				
				ArrayList<String> districts = new ArrayList<String>();
				if (tables.size() == 1)
					districts.add("");
				else
				{
					@SuppressWarnings("unchecked")
					ArrayList<DomElement> dists = (ArrayList<DomElement>) page.getByXPath("//p[@class='pagehead5']");
					for (DomElement dist : dists)
						if (dist.asText().toUpperCase().contains("DISTRICT"))
							districts.add(dist.asText().replace("District", "")
									.replaceAll("\r\n", "").trim());
				}
				
				HashMap<Integer, CandidateData> candidates = new HashMap<Integer, CandidateData>();
				for (int tabIndex = 0; tabIndex < tables.size(); tabIndex++)
				{
					HtmlTable table = tables.get(tabIndex);
					candidates.clear();
					
					HtmlTableRow headers = table.getRow(0);
					List<HtmlTableCell> columns = (List<HtmlTableCell>) headers.getCells();
					int countyColIndex = 0;
					
					for (int index = 0; index < columns.size(); index++)
					{
						HtmlTableCell column = columns.get(index);
						String col = column.asText();

						if (col.contains("("))
						{
							String candName = column.asText().replaceAll("\r\n", " ").replaceAll("  ", " ");
							String candParty = candName.substring(candName.indexOf("(")+1,
									candName.lastIndexOf(")"));
							if (candParty.contains("Write-In"))
								candParty = "WRI";
							candName = candName.substring(0, candName.indexOf(" ("));
							candidates.put(index, 
									new CandidateData(state, type, candName, candParty, year));
							candidates.get(index).setOffice(office);
							candidates.get(index).setDistrict(districts.get(tabIndex));
						}
						else if (col.toLowerCase().equals("county"))
							countyColIndex = index;
					}
					
					ArrayList<HtmlTableCell> cells;
					for (int rowIndex = 1; rowIndex < table.getRowCount(); rowIndex++)
					{
						cells = new ArrayList<>(table.getRow(rowIndex).getCells());
						for (int candKey : candidates.keySet())
						{
							candidates.get(candKey).addData(new ElectionData(
									cells.get(countyColIndex).asText(),
									Integer.parseInt(cells.get(candKey).asText().replaceAll(",", "")),
									-1.0));
						}
					}
					
					for (CandidateData cand : candidates.values())
					{
						try
						{
							out.write(cand.getRows("\t"));
						}
						catch (IOException e)
						{
							System.err.println("Error in writing to file; data: " + cand.getRows());
							e.printStackTrace();
						}
					}
				}

				wc.close();
				out.close();
			}
		}
	}
}
