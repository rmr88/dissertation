package launchers.govTrack;

import java.io.File;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import utilities.InFile;
import utilities.OutFile;

public class GunBillCosponsorships
{
	public static void main(String args[])
	{
		final int NUM = 0, TYPE = 1, CONG = 2;
		
		String gtPath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\GovTrack";
		String gunProjPath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\PolicyAgendasProject";
		
		InFile list = null;
		try
		{
			list = new InFile(gunProjPath + "\\healthBills.txt");
			list.readLine();
		}
		catch(IOException e)
		{
			System.err.println("Error in reading list.");
			e.printStackTrace();
		}
		
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder = null;
		try { dBuilder = factory.newDocumentBuilder(); }
			catch (ParserConfigurationException e) { e.printStackTrace(); }
		
		OutFile outCosp = null;
		try
		{
			outCosp = new OutFile(gunProjPath + "\\cosponsorships.txt", false);
			outCosp.writeLine("cong\tbilltype\tbillnum\tid\tsponsor");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file");
			e.printStackTrace();
		}
		
		try
		{
			while (list.isReady())
			{
				String[] bill = list.readRowLite("\t");
				File billFile = new File(gtPath + "\\" + bill[CONG] + "\\bills\\" + bill[TYPE] + bill[NUM] + ".xml");
				
				try
				{
					Document doc = dBuilder.parse(billFile);
					doc.getDocumentElement().normalize();
					
					NodeList nodes = doc.getElementsByTagName("sponsor");
					outCosp.writeLine(bill[CONG] + "\t" + bill[TYPE] + "\t" + bill[NUM] + "\t"
							+ nodes.item(0).getAttributes().getNamedItem("id").getNodeValue() + "\t1");
					
					nodes = doc.getElementsByTagName("cosponsor");
					Node node;
					for (int n = 0; n < nodes.getLength(); n++)
					{
						node = nodes.item(n);
						outCosp.writeLine(bill[CONG] + "\t" + bill[TYPE] + "\t" + bill[NUM] + "\t"
								+ node.getAttributes().getNamedItem("id").getNodeValue() + "\t0");
					}
				}
				catch (SAXException | IOException e)
				{
					System.err.println("Error in opening new Document for " + bill[TYPE] + "-" + bill[NUM] + ", "
							+ bill[CONG] + "th congress.");
					e.printStackTrace();
				}
			}
		}
		catch (IOException e)
		{
			System.err.println("Error determining readiness of InFile object.");
			e.printStackTrace();
		}
	}
}
