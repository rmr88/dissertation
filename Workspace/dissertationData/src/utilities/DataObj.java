package utilities;

import java.util.ArrayList;

public class DataObj
{
	private String colName;
	private ArrayList<String> data = new ArrayList<String>();
	
	public DataObj() {}
	
	public DataObj(String name)
	{
		this.colName = name;
	}
	
	public String getName()
	{
		return this.colName;
	}
	
	public ArrayList<String> getData()
	{
		return this.data;
	}
	
	public void addData(String cell)
	{
		this.data.add(cell);
	}
	
	public int getDataSize()
	{
		return this.data.size();
	}
	
	public String toString()
	{
		return this.colName + ": data array length = " + this.data.size();
	}
}
