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

public class HealthVotesAndCosp
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
			outCosp = new OutFile(gunProjPath + "\\healthBillCosp.txt", false);
			outCosp.writeLine("cong\tbilltype\tbillnum\tid\tsponsor");
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file");
			e.printStackTrace();
		}
		
		OutFile outRoll = null;
		try
		{
			outRoll = new OutFile(gunProjPath + "\\healthBillVotes.txt", false);
			outRoll.writeLine("cong\tbilltype\tbillnum\tid\trollNum\tresult\tvote");
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
					
					nodes = doc.getElementsByTagName("vote");
					node = null;
					String num, when, where, result;
					for (int n = 0; n < nodes.getLength(); n++)
					{
						node = nodes.item(n);
						if (node.getAttributes().getNamedItem("how").getNodeValue().equals("roll"))
						{
							num = node.getAttributes().getNamedItem("roll").getNodeValue();
							when = node.getAttributes().getNamedItem("datetime").getNodeValue()
									.substring(0, 4);
							where = node.getAttributes().getNamedItem("where").getNodeValue();
							
							try { result = node.getAttributes().getNamedItem("state").getNodeValue(); }
							catch (NullPointerException e1) { result = ""; }
							
							System.out.println(where + when + "-" + num);
							File rollFile = new File(gtPath + "\\" + bill[CONG] + "\\rolls\\"
									+ where + when + "-" + num + ".xml");
							Document rollDoc = dBuilder.parse(rollFile);
							rollDoc.getDocumentElement().normalize();
							
							NodeList voters = rollDoc.getElementsByTagName("voter");
							Node voter;
							for (int i = 0; i < voters.getLength(); i++)
							{
								voter = voters.item(i);
								outRoll.writeLine(bill[CONG] + "\t" + bill[TYPE] + "\t" + bill[NUM] + "\t"
										+ voter.getAttributes().getNamedItem("id").getNodeValue() + "\t"
										+ num + "\t" + result + "\t"
										+ voter.getAttributes().getNamedItem("vote").getNodeValue());
							}
						}
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
		
		outRoll.close();
		outCosp.close();
	}
}
