package launchers;

import java.util.ArrayList;
import java.util.HashMap;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import utilities.OutFile;

public class CPRscraper
{
	public static void main(String args[]) throws Exception
	{
		String listURL = "http://compendium.catalyzepaymentreform.org/results-reports/all-programs-list?pg=";
//		String webPath = "C:\\Users\\Robbie\\Documents\\ArnFound\\Data";
		
		ArrayList<String> headers = new ArrayList<String>();
		headers.add("url");
		ArrayList<HashMap<String, String>> listItems = new ArrayList<HashMap<String, String>>();
		
		for (int p = 0; p < 20; p++)
		{
			System.out.println("Page " + p + "...");
			
			Document doc = Jsoup.connect(listURL + p).get();
			Element el = doc.getElementById("alternatecolor");
			Elements table = el.children();
			Elements rows = table.get(0).children();

			for (int r = 1; r < rows.size(); r++)
			{
				Elements links = rows.get(r).select("a[href]");
				for (Element link : links)
				{
					HashMap<String, String> data = new HashMap<String, String>();
					
					Document subDoc = Jsoup.connect(link.attr("href")).get();
					System.out.println(link.attr("href"));
					Element e = subDoc.getElementById("Content");
					Elements dataRows = e.children().get(0).children().select("tr");
					
					data.put("url", link.attr("href"));
					
					for (int dr = 0; dr < dataRows.size()-1; dr+=3)
					{
						data.put(dataRows.get(dr).child(0).text(), dataRows.get(dr+1).child(0).text());
						if (!headers.contains(dataRows.get(dr).child(0).text()))
							headers.add(dataRows.get(dr).child(0).text());
					}
					
					listItems.add(data);
				}
			}
		} //end loop through pages
		
		OutFile out = new OutFile("C:\\Users\\Robbie\\Documents\\ArnFound\\Data\\cprData.txt", false);
		out.writeRow(headers, "\t");
		for (HashMap<String, String> item : listItems)
		{
			for (int h = 0; h < headers.size()-1; h++)
				out.write(item.get(headers.get(h)) + "\t");
			
			out.writeLine(item.get(headers.get(headers.size()-1)) + "");
		}
		
		System.out.println("Done.");
	}
}
