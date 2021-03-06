package tasks;

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
import com.gargoylesoftware.htmlunit.html.HtmlTableHeader;
import com.gargoylesoftware.htmlunit.html.HtmlTableRow;

import utilities.CandidateData;
import utilities.ElectionData;
import utilities.OutFile;
import utilities.State;

public class ElectionScraper
{
	private State state;
	private OutFile out = null;
	private final WebClient wc = new WebClient(BrowserVersion.FIREFOX_38);
	private HtmlPage page = null;
	
	public ElectionScraper(State _state)
	{
		this.state = _state;
	}
	
	public void run() //TODO want to return anything for ScrapeAndParse to post-process?
	{
		System.out.println(this.state.getState() + ": scraping");
		Logger.getLogger("com.gargoylesoftware").setLevel(Level.OFF);
		
		if (state.getYears().length != 0)
		{
			for (int year : this.state.getYears())
			{
				System.out.print("\t" + year);
				
				if (state.getOffices().length != 0)
					this.offices(year);
				else if (state.getLocations().length != 0)
					this.locations(year);
				else
					System.err.println("Not enough info to scrape this state/ year");
			}
		}
		else
			System.err.println("Not enough info to scrape this state.");
	}
	
	private void offices(int year)
	{
		System.out.println(": scraping by office");
		
		for (String off : state.getOffices())
		{
			try
			{ //try to get URLs for each office
				String url = "http://www.sos.state.co.us/pubs/elections/"
						+ "Results/Abstract/" + year + "/general/"
						+ off.replace("@", "") + ".html"; //TODO make this state-year specific
				page = wc.getPage(url);
			}
			catch (FailingHttpStatusCodeException e)
			{
				continue; //goes to next array element if URL doesn't work; need to be careful with this...
			}
			catch (IOException e)
			{
				e.printStackTrace();
			} //end try URLs
			
			String office = ElectionData.checkStatic(off);
			System.out.println("\t\t" + office);
			
			String outPath = state.getPath() + "\\" + year
					+ office.toLowerCase() + "_" + state.getGeoType() + ".txt";
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
			for (HtmlTable table : tables) //get data tables into an array
				if (table.asText().contains("County"))
					tables2.add(table);
			
			if (office.equals("USP") && state.getState().equals("CO"))
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
			{ //if there are multiple districts for an office code
				@SuppressWarnings("unchecked")
				ArrayList<DomElement> dists = (ArrayList<DomElement>) page.getByXPath("//p[@class='pagehead5']");
				for (DomElement dist : dists)
					if (dist.asText().toUpperCase().contains("DISTRICT"))
						districts.add(dist.asText().replace("District", "")
								.replaceAll("\r\n", "").trim());
			}
			
			HashMap<Integer, CandidateData> candidates = new HashMap<Integer, CandidateData>();
			for (int tabIndex = 0; tabIndex < tables.size(); tabIndex++)
			{ //get table data (looping through all tables on a page, tables.size() will be one for single-district offices)
				HtmlTable table = tables.get(tabIndex);
				candidates.clear();
				
				HtmlTableRow headers = table.getRow(0);
				List<HtmlTableCell> columns = (List<HtmlTableCell>) headers.getCells();
				ArrayList<HtmlTableCell> cells;
				int countyColIndex = 0;
				
				for (int index = 0; index < columns.size(); index++)
				{ //loop through top row of each column to get candidate data
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
								new CandidateData(state.getState(), state.getGeoType(),
										candName, candParty, year));
						candidates.get(index).setOffice(office);
						candidates.get(index)
							.setDistrict(districts
									.get(tabIndex));
					}
					else if (col.toLowerCase().equals("county"))
						countyColIndex = index; //saves column number for the county name
				} //end column header loop
				
				for (int rowIndex = 1; rowIndex < table.getRowCount(); rowIndex++)
				{ //loop through table rows to get ElectionData
					cells = new ArrayList<>(table.getRow(rowIndex).getCells());
					for (int candKey : candidates.keySet())
					{
						candidates.get(candKey).addData(new ElectionData(
								cells.get(countyColIndex).asText(),
								Integer.parseInt(cells.get(candKey).asText().replaceAll(",", "")),
								-1.0));
					}
				}  //end for
				
				for (CandidateData cand : candidates.values())
				{ //write data for each candidate to out
					try
					{
						out.write(cand.getRows("\t"));
					}
					catch (IOException e)
					{
						System.err.println("Error in writing to file; data: " + cand.getRows());
						e.printStackTrace();
					}
				} //end for
			} //end get table data

			wc.close();
			out.close();
		} //end offices for loop
	} //end offices method
	
	@SuppressWarnings("unchecked")
	private void locations(int year)
	{
		System.out.println(": scraping by location");
		
		ArrayList<DomElement> offices = new ArrayList<DomElement>();
		String outPath = state.getPath() + "\\" + year + "_" + state.getGeoType() + "test.txt";
		try
		{
			out = new OutFile(outPath, false);
		}
		catch (IOException e)
		{
			System.err.println("Error in setting up output file " + outPath);
			e.printStackTrace();
		}
		
		//***** Hard-codes for specific state-year URLs *****//
		String yearSpecific = "";
		if (year > 2004 && state.getState().equals("NV"))
			yearSpecific = "STatewideGeneral";
		else if (state.getState().equals("NV"))
			yearSpecific = "General";
		//end hard-codes
		
		for (String location : state.getLocations())
		{
			System.out.println("\t\t" + location);
			offices.clear();
			
			ElectionData data;
			String office;
			ArrayList<HtmlTable> tables2 = new ArrayList<HtmlTable>();
			
			try
			{ //try to get location pages
				String url = "http://www.nvsos.gov/soselectionpages/results/"
						+ year + yearSpecific + "/" + location + ".aspx"; //TODO may need to make these URLs state-dependent
				page = wc.getPage(url);
				
				List<DomElement> officesRaw = page.getElementsByIdAndOrName("Races");
				for (DomElement off : officesRaw)
				{ //get offices from individual elements
					if (off.hasChildNodes() && off.getChildElements().iterator().hasNext())
					{
						Iterable<DomElement> iterNext = off.getChildElements();
						DomElement next = iterNext.iterator().next();
						if (next.hasChildNodes() && next.getChildElements().iterator().hasNext())
							if (next.getChildElements().iterator().next().getId()
									.matches("_ctl[\\d]{1,2}_lblRaceTitle")) //TODO may need to make this ID check state-dependent
								offices.add(next.getChildElements().iterator().next());
					}
				} //end get offices
			}
			catch (FailingHttpStatusCodeException | IOException e)
			{
				e.printStackTrace();
			} //end try locations
			
			ArrayList<HtmlTable> tables = (ArrayList<HtmlTable>) page.getByXPath("//table[@class='tableData']"); //TODO make sure this generalizes; could dump for loop in try block below
			
			if (offices.isEmpty())
			{ //get offices into array, if they are part of the HTML tables (in some cases, the array is filled above)
				for (HtmlTable table : tables)
				{
					if (!table.getHeader().asText().toUpperCase().contains("QUESTION"))
					{
						offices.add(table.getHeader());
						tables2.add(table);
					}
				}
				tables = tables2;
			} //end get offices (2nd attempt)
			
			if (tables.isEmpty())
			{ //get HTML tables containing election data, if not already identified
				tables = (ArrayList<HtmlTable>) page.getByXPath("//table");
				for (HtmlTable table : tables)
				{
					HtmlTableRow row1 = table.getRow(0);
					if (!row1.asText().toUpperCase().contains("QUESTION")
							&& row1.getId() != null && table.getRowCount() >= 1)
					{
						offices.add(table.getRow(0));
						tables2.add(table);
					}
				}
				tables = tables2;
			} //end get tables (2nd attempt)
			
			for (int tableNum = 0; tableNum < offices.size(); tableNum++)
			{ //get data from tables, fill array of ElectionData objects
				data = new ElectionData(state.getState(), state.getGeoType(), location, year);
				
				office = offices.get(tableNum).asText();
				if (office.contains("\r\n"))
					office = office.substring(0, office.indexOf("\r\n")).trim();
				data.setOffice(office);
				
				List<HtmlTableCell> cells = new ArrayList<HtmlTableCell>();
				HashMap<String, Integer> columns = new HashMap<String, Integer>();
				
				HtmlTableHeader header = tables
						.get(tableNum)
						.getHeader();
				try
				{ //try to get header data
					List<HtmlTableRow> colHeads = header.getRows();
					cells = colHeads.get(0).getCells();
					
					for (int col = 0; col < cells.size(); col++)
					{
						if (cells.get(col).asText().contains("\r\n"))
							columns.put("Candidate", 0);
						else
							columns.put(cells.get(col).asText().trim(), col);
					}
				}
				catch (NullPointerException e)
				{ //if no defined header, get headers from first row of table
					HtmlTableRow colHeads = tables.get(tableNum).getRow(0);
					cells = new ArrayList<>(colHeads.getCells());
					if (cells.size() == 3)
						cells.add(1, null);

					for (int col = 0; col < cells.size(); col++)
					{
						if (cells.get(col) == null)
							columns.put("", col);
						else if (cells.get(col).getId().equals("CandidatesRight"))
							columns.put(cells.get(col).asText().trim().replaceAll("\r\n", " "), col);
						else if (cells.get(col).asText().contains("\r\n"))
							columns.put("Candidate", 0);
					}
				} //end try to get headers
				
				for (HtmlTableRow row : tables.get(tableNum).getBodies().get(0).getRows())
				{ //get data rows, create CandidateData objects for ElectionData arrays
					cells = row.getCells();
					if (cells.size() == 4)
						data.addData(new CandidateData(cells.get(columns.get("Candidate")).asText(),
								cells.get(columns.get("")).asText(),
								Integer.parseInt(cells.get(columns.get("Total Votes")).asText().replaceAll(",", "")),
								Double.parseDouble(cells.get(columns.get("% of Vote")).asText().replace("%", ""))));
				} //end for
				
				try
				{ //try to write the data to out
					out.write(data.getRows("\t"));
				}
				catch (IOException e)
				{
					System.err.println("Error in writing to file; data: " + data.getRows());
					e.printStackTrace();
				} //end try
			} //end get table data loop
			wc.close();
		} //end location loop
		out.close();
	} //end locations method
}
