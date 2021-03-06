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
import com.gargoylesoftware.htmlunit.html.HtmlTableHeader;
import com.gargoylesoftware.htmlunit.html.HtmlTableRow;

import utilities.CandidateData;
import utilities.ElectionData;
import utilities.OutFile;

public class ScraperNV
{
	public static void main(String args[])
	{
		Logger.getLogger("com.gargoylesoftware").setLevel(Level.OFF);
		final WebClient wc = new WebClient(BrowserVersion.FIREFOX_38);

		ArrayList<DomElement> offices = new ArrayList<DomElement>();
		HtmlPage page = null;

		String state = "NV";
		String[] locations = {"CarsonCity", "Churchill", "Clark", "Douglas",
				"Elko", "Esmeralda", "Eureka", "Humboldt", "Lander",
				"Lincoln", "Lyon", "Mineral", "Nye", "Pershing", "Storey",
				"Washoe", "WhitePine"};
		String type = "county";
		int[] years = {2014, 2012, 2010, 2008}; //, 2006, 2004, 2002, 2000};
		
		String outPath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
				+ "\\elections\\stateResults\\" + state +"\\" + state + "_"
				+ type + ".txt";
		
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
		
		for (int year : years)
		{
			String yearSpecific;
			if (year > 2004)
				yearSpecific = "STatewideGeneral";
			else
				yearSpecific = "General";
			
			System.out.println("Year: " + year);
			
			for (String location : locations)
			{
				System.out.println(location);
				offices.clear();
				
				try
				{
					String url = "http://www.nvsos.gov/soselectionpages/results/"
							+ year + yearSpecific + "/" + location + ".aspx";
					page = wc.getPage(url);

					List<DomElement> officesRaw = page.getElementsByIdAndOrName("Races");
					for (DomElement office : officesRaw)
					{
						if (office.hasChildNodes() && office.getChildElements().iterator().hasNext())
						{
							Iterable<DomElement> iterNext = office.getChildElements();
							DomElement next = iterNext.iterator().next();
							if (next.hasChildNodes() && next.getChildElements().iterator().hasNext())
								if (next.getChildElements().iterator().next().getId()
										.matches("_ctl[\\d]{1,2}_lblRaceTitle"))
									offices.add(next.getChildElements().iterator().next());
						}
					}
				}
				catch (FailingHttpStatusCodeException | IOException e)
				{
					e.printStackTrace();
				}

				@SuppressWarnings("unchecked")
				ArrayList<HtmlTable> tables = (ArrayList<HtmlTable>) page.getByXPath("//table[@class='tableData']");
				
				if (offices.isEmpty())
				{
					ArrayList<HtmlTable> tables2 = new ArrayList<HtmlTable>();
					for (HtmlTable table : tables)
					{
						if (!table.getHeader().asText().toUpperCase().contains("QUESTION"))
						{
							offices.add(table.getHeader());
							tables2.add(table);
						}
					}
					tables = tables2;
				}
				
				if (tables.isEmpty())
				{
					tables = (ArrayList<HtmlTable>) page.getByXPath("//table");
					ArrayList<HtmlTable> tables2 = new ArrayList<HtmlTable>();
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
				}

				ElectionData data;
				String office;
				
				for (int tableNum = 0; tableNum < offices.size(); tableNum++)
				{
					data = new ElectionData(state, type, location, year);
					
					office = offices.get(tableNum).asText();
					if (office.contains("\r\n"))
						office = office.substring(0, office.indexOf("\r\n")).trim();
					data.setOffice(office);
					
					List<HtmlTableCell> cells = new ArrayList<HtmlTableCell>();
					HashMap<String, Integer> columns = new HashMap<String, Integer>();
					
					HtmlTableHeader header = tables.get(tableNum).getHeader();
					try
					{
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
					{
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
					}
					
					for (HtmlTableRow row : tables.get(tableNum).getBodies().get(0).getRows())
					{
						cells = row.getCells();
						if (cells.size() == 4)
							data.addData(new CandidateData(cells.get(columns.get("Candidate")).asText(),
									cells.get(columns.get("")).asText(),
									Integer.parseInt(cells.get(columns.get("Total Votes")).asText().replaceAll(",", "")),
									Double.parseDouble(cells.get(columns.get("% of Vote")).asText().replace("%", ""))));
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
		}
		out.close();
	}
}
