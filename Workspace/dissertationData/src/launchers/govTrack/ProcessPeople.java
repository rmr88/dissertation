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

import utilities.OutFile;

public class ProcessPeople
{
	public static void main(String args[])
	{
		String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\GovTrack";
		
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder = null;
		try { dBuilder = factory.newDocumentBuilder(); }
			catch (ParserConfigurationException e) { e.printStackTrace(); }
		
		OutFile out = null;
		try
		{
			out = new OutFile(basePath + "\\people.txt", false);
			//TODO write header line
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file");
			e.printStackTrace();
		}
		
		for (int cong = 80; cong < 114; cong++)
		{
			System.out.println(cong);
			File file = new File(basePath + "\\" + cong + "\\people.xml");
			
			try
			{
				Document doc = dBuilder.parse(file);
				doc.getDocumentElement().normalize();
				
//				Node topNode = doc.getElementsByTagName("roll").item(0);
//				String chamber = topNode.getAttributes().getNamedItem("where").getTextContent().substring(0, 1);
				
				NodeList nodes = doc.getElementsByTagName("person");
				Node node;
				String gender, religion, birthday, icpsrid;
				
				for (int n = 0; n < nodes.getLength(); n++)
				{
					node = nodes.item(n);
					
					try { gender = node.getAttributes().getNamedItem("gender").getTextContent(); }
						catch (NullPointerException e) {gender = ""; }
					try { religion = node.getAttributes().getNamedItem("religion").getTextContent(); }
						catch (NullPointerException e) {religion = ""; }
					try { birthday = node.getAttributes().getNamedItem("birthday").getTextContent(); }
						catch (NullPointerException e) {birthday = ""; }
					try { icpsrid = node.getAttributes().getNamedItem("icpsrid").getTextContent(); }
					catch (NullPointerException e)
					{
						System.err.println("    No ICPSR ID for legislator id = "
								+ node.getAttributes().getNamedItem("id").getTextContent());
						icpsrid = "";
					}
					
					out.writeLine(node.getAttributes().getNamedItem("id").getTextContent() + "\t"
							+ node.getAttributes().getNamedItem("name").getTextContent() + "\t"
							+ icpsrid + "\t" + birthday + "\t" + gender + "\t" + religion);
				}
			}
			catch (SAXException | IOException e)
			{
				System.err.println("Error in opening new Document, " + cong + ", " + file.getName());
				e.printStackTrace();
			}
		}
	}
}
