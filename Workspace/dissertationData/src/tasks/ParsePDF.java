package tasks;

import java.io.File;
import java.io.FileInputStream;

import org.apache.pdfbox.cos.COSDocument;
import org.apache.pdfbox.pdfparser.PDFParser;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.util.PDFTextStripper;

//Adapted from code found at http://stackoverflow.com/questions/18098400/how-to-get-raw-text-from-pdf-file-using-java
public class ParsePDF
{
	public static String getText(String fileName)
	{
		PDFParser parser = null;
		PDDocument pdDoc = null;
		COSDocument cosDoc = null;
		PDFTextStripper pdfStripper;
		
		String parsedText = "";
		File file = new File(fileName);
		try
		{
			parser = new PDFParser(new FileInputStream(file));
			parser.parse();
			cosDoc = parser.getDocument();
			pdfStripper = new PDFTextStripper();
			pdDoc = new PDDocument(cosDoc);
			parsedText = pdfStripper.getText(pdDoc);
			parsedText = parsedText.replaceAll(pdfStripper.getLineSeparator(), "\r\n");
//			System.out.println(parsedText);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			try
			{
				if (cosDoc != null)
					cosDoc.close();
				if (pdDoc != null)
					pdDoc.close();
			}
			catch (Exception e1)
			{
				e1.printStackTrace();
			}
		}
		
		return parsedText;
	}
}
