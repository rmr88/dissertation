package utilities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Iterator;

//import org.apache.poi.hssf.usermodel.HSSFSheet;
//import org.apache.poi.hssf.usermodel.HSSFWorkbook;
//import org.apache.poi.ss.usermodel.Cell;
//import org.apache.poi.ss.usermodel.Row;

//Citation: code copied from http://www.simplecodestuffs.com/converting-xls-to-csv-files-using-java/
/**
 * 
 * @author Mohaideen Jamil, modified by Robbie
 * {@link http://www.simplecodestuffs.com/converting-xls-to-csv-files-using-java/}
 *
 */
public class XlsToCsv 
{
//	static void xls(File inputFile, File outputFile) 
//	{
//		// For storing data into CSV files
//		StringBuffer data = new StringBuffer();
//		HSSFWorkbook workbook = null;
//		try 
//		{
//			FileOutputStream fos = new FileOutputStream(outputFile);
//
//			// Get the workbook object for XLS file
//			workbook = new HSSFWorkbook(new FileInputStream(inputFile));
//			// Get first sheet from the workbook
//			HSSFSheet sheet = workbook.getSheetAt(0);
//			Cell cell;
//			Row row;
//
//			// Iterate through each rows from first sheet
//			Iterator<Row> rowIterator = sheet.iterator();
//			while (rowIterator.hasNext()) 
//			{
//				row = rowIterator.next();
//				// For each row, iterate through each columns
//				Iterator<Cell> cellIterator = row.cellIterator();
//				while (cellIterator.hasNext()) 
//				{
//					cell = cellIterator.next();
//
//					switch (cell.getCellType()) 
//					{
//					case Cell.CELL_TYPE_BOOLEAN:
//						data.append(cell.getBooleanCellValue() + ",");
//						break;
//
//					case Cell.CELL_TYPE_NUMERIC:
//						data.append(cell.getNumericCellValue() + ",");
//						break;
//
//					case Cell.CELL_TYPE_STRING:
//						data.append(cell.getStringCellValue() + ",");
//						break;
//
//					case Cell.CELL_TYPE_BLANK:
//						data.append("" + ",");
//						break;
//
//					default:
//						data.append(cell + ",");
//					}
//				}
//				data.append("\r\n");
//			}
//
//			fos.write(data.toString().getBytes());
//			fos.close();
//		}
//		catch (FileNotFoundException e) 
//		{
//			e.printStackTrace();
//		}
//		catch (IOException e) 
//		{
//			e.printStackTrace();
//		}
//		finally
//		{
//			try
//			{
//				workbook.close();
//			}
//			catch (IOException e)
//			{
//				e.printStackTrace();
//			}
//		}
//	}
//
//	public static void main(String[] args) 
//	{
//		String inPath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\elections"
//				+ "\\stateResults\\AL\\1998";
//		File inputFile = new File(inPath + "\\AUTAUGA.xls");
//		File outputFile = new File(inPath + "\\autauga.csv");
//		xls(inputFile, outputFile);
//	}
}
