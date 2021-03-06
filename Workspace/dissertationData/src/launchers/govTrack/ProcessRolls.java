package launchers.govTrack;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import utilities.OutFile;

public class ProcessRolls
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
			out = new OutFile(basePath + "\\rolls.txt", false);
		}
		catch (IOException e)
		{
			System.err.println("Error opening output file");
			e.printStackTrace();
		}
		
		for (int cong = 80; cong < 114; cong++)
		{
			System.out.println(cong);
			File[] files = new File(basePath + "\\" + cong + "\\rolls").listFiles(new FilenameFilter()
			{
				public boolean accept(File dir, String name)
				{
					return true;
				}
			});
			
			for (File file : files) //for (int f = 0; f < 1; f++)
			{
				try
				{
					Document doc = dBuilder.parse(file);
					doc.getDocumentElement().normalize();
					
					Node topNode = doc.getElementsByTagName("roll").item(0);
					String chamber = topNode.getAttributes().getNamedItem("where").getTextContent().substring(0, 1);
					
					NodeList nodes = doc.getElementsByTagName("voter");
					for (int n = 0; n < nodes.getLength(); n++)
					{
						Node node = nodes.item(n);
						out.writeLine(chamber + "-"
								+ topNode.getAttributes().getNamedItem("session").getTextContent() + "-"
								+ topNode.getAttributes().getNamedItem("roll").getTextContent() + "-"
								+ topNode.getAttributes().getNamedItem("year").getTextContent() + "\t" 
								+ node.getAttributes().getNamedItem("id").getTextContent() + "\t"
								+ node.getAttributes().getNamedItem("vote").getTextContent());
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
}
