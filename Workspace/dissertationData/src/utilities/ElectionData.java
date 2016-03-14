package utilities;

import java.util.ArrayList;
import java.util.HashMap;

public class ElectionData
{
	private String office, state, type, location, district;
	private int year;
	private ArrayList<CandidateData> data;
	static HashMap<String, String> offices = new HashMap<String, String>();
	static ArrayList<String> checkedOffices = new ArrayList<String>();
	private int votes;
	private double percent;
	
	public ElectionData() {}
	
	public ElectionData(String _state, String _type, String _location, int _year)
	{
		this.year = _year;
		this.state = _state;
		this.location = _location;
		this.type = _type;
		this.data = new ArrayList<CandidateData>();
	}
	
	public ElectionData(String _location, int _votes, double perc)
	{
		this.location = _location;
		this.votes = _votes;
		this.percent = perc;
		this.district = "";
	}
	
	public ElectionData(String _location, int _votes, double perc, String dist)
	{
		this.location = _location;
		this.votes = _votes;
		this.percent = perc;
		this.district = dist;
	}
	
	public void setOffice(String _office)
	{
		String off = _office.toUpperCase().trim();
		
		if (off.contains(" SEAT "))
		{
			this.district = off.substring(off.lastIndexOf("SEAT")).trim();
			off = off.substring(0, off.indexOf("SEAT")).trim().replaceAll(",", "");
		}
		else if (off.contains(" DISTRICT "))
		{
			String dist = off.substring(off.lastIndexOf("DISTRICT"));
			dist = dist.replace("DISTRICT ", "").trim();
			this.district = dist;
			off = off.substring(0, off.lastIndexOf("DISTRICT")).trim().replaceAll(",", "");
		}
		else if (off.contains(",") && off.contains("DISTRICT"))
		{
			this.district = off.substring(off.indexOf(",")+1).trim();
			off = off.substring(0, off.indexOf(",")).trim();
		}
		else
			this.district = "";
		
		//System.out.println("****New check: " + off);
		if (offices.keySet().contains(off))
		{
			//System.out.println("\toff = " + off + " matched to " + offices.get(off));
			this.office = offices.get(off);
		}
		else if (!checkedOffices.contains(off))
		{
			String checkResult = check(off);
			if (!checkResult.isEmpty())
			{
				//System.out.println("\tNew match: off = " + off + " matched to " + checkResult);
				offices.put(off, checkResult);
				this.office = checkResult;
			}
			else
			{
				//System.out.println("\t" + off + " not matched, added to checkedOffices.");
				checkedOffices.add(off);
				this.office = off;
			}
		}
		else
		{
			//System.out.println("\t" + off + " not checked, already in checkedOffices.");
			this.office = off;
		}
		//System.out.println("\tend check for " + off);
	}
	
	private String check(String toCheck)
	{
		String officeKey = "";
		Offices[] officeKeys = Offices.values();
		
		int keyIndex = 0;
		while (officeKey.isEmpty() && keyIndex < officeKeys.length)
		{
			//System.out.print("\t\tChecking office " + officeKeys[keyIndex].toString() + "...");
			int index = 0;
			String[] keys = officeKeys[keyIndex].getKeys();
			while (officeKey.isEmpty() && index < keys.length)
			{
				if (toCheck.toUpperCase().contains(keys[index]))
				{
					//System.out.print("MATCH...");
					officeKey = officeKeys[keyIndex].toString();
					
					int ind2 = 0;
					String [] exclusions = officeKeys[keyIndex].getExclusions();
					while (!officeKey.isEmpty() && ind2 < exclusions.length)
					{
						if (toCheck.toUpperCase().contains(exclusions[ind2]))
						{
							//System.out.print("EXCLUDED");
							officeKey = "";
							index = keys.length;
						}
						ind2++;
					}
				}
				index++;
			}
			keyIndex++;
		}
		//System.out.println("\r\n\t\treturning " + officeKey);
		return officeKey;
	}
	
	public static String checkStatic(String toCheck)
	{
		String officeKey = "";
		Offices[] officeKeys = Offices.values();
		toCheck = toCheck.toUpperCase();
		
		int keyIndex = 0;
		while (officeKey.isEmpty() && keyIndex < officeKeys.length)
		{
			//System.out.print("\tChecking office " + officeKeys[keyIndex].toString() + "...");
			int index = 0;
			String[] keys = officeKeys[keyIndex].getKeys();
			while (officeKey.isEmpty() && index < keys.length)
			{
				if (toCheck.toUpperCase().contains(keys[index]))
				{
					//System.out.print("MATCH...");
					officeKey = officeKeys[keyIndex].toString();
					
					int ind2 = 0;
					String [] exclusions = officeKeys[keyIndex].getExclusions();
					while (!officeKey.isEmpty() && ind2 < exclusions.length)
					{
						if (toCheck.toUpperCase().contains(exclusions[ind2]))
						{
							//System.out.print("EXCLUDED");
							officeKey = "";
							index = keys.length;
						}
						ind2++;
					}
				}
				index++;
			}
			keyIndex++;
		}
		//System.out.println("\r\n\treturning " + officeKey);
		if (toCheck.toUpperCase().contains("GOVERNOR") && (toCheck.toUpperCase().contains("/")
				|| toCheck.toUpperCase().contains("AND")))
			officeKey = "GOV";
		
		offices.put(toCheck, officeKey);
		return officeKey;
	}
	
	public static String getOfficeKey(String office)
	{
		if (offices.containsKey(office))
			return offices.get(office);
		else
			return office;
	}
	
	public String getOffice()
	{
		return this.office;
	}
	
	public String getDistrict()
	{
		return this.district;
	}
	
	public void setLocation(String _location)
	{
		this.location = _location;
	}
	
	public void setState(String _state)
	{
		this.state = _state;
	}
	
	public void setType(String _type)
	{
		this.type = _type;
	}
	
	public void setYear(int _year)
	{
		this.year = _year;
	}
	
	public void addData(CandidateData d)
	{
		this.data.add(d);
	}
	
	public String getState()
	{
		return this.state;
	}
	
	public String getType()
	{
		return this.type;
	}
	
	public String getLocation()
	{
		return this.location;
	}
	
	public int getYear()
	{
		return this.year;
	}
	
	public ArrayList<CandidateData> getCandData()
	{
		return this.data;
	}
	
	public String getRows()
	{
		String rows = "";
		String delim = "\t";
		
		for(CandidateData d : this.data)
		{
			rows += this.state + delim +
					this.year + delim +
					this.type + delim +
					this.location + delim +
					this.office + delim +
					d.getRowPiece(delim) + "\r\n";	
		}
		return rows;
	}
	
	public String getRows(String delim)
	{
		String rows = "";
		for(CandidateData d : this.data)
		{
			rows += this.state + delim +
					this.year + delim +
					this.type + delim +
					this.location + delim +
					this.office + delim +
					this.district + delim +
					d.getRowPiece(delim) + "\r\n";	
		}
		return rows;
	}
	
	public String getRowPiece()
	{
		String delim = "\t";
		return this.location + delim +
				this.votes + delim +
				this.percent;
	}
	
	public String getRowPiece(String delim)
	{
		return this.location + delim +
				this.votes + delim +
				this.percent;
	}
}
