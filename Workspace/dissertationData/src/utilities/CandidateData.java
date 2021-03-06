package utilities;

import java.util.ArrayList;

public class CandidateData
{
	private String name, party, state, type, office, district;
	private int votes, year;
	private double percent;
	private ArrayList<ElectionData> data;
	private String[] namePieces;
	
	public CandidateData() {}
	
	public CandidateData(String _name, String _party, int _votes, double _perc)
	{
		this.name = _name;
		this.party = _party;
		this.votes = _votes;
		this.percent = _perc;
	}
	
	public CandidateData(String _state, String _type, String _name, String _party, int _year)
	{
		this.state = _state;
		this.type = _type;
		this.name = _name;
		this.party = _party;
		this.year = _year;
		this.data = new ArrayList<ElectionData>();
	}
	
	public CandidateData(int _year, String st, String _type, String off, String _name, String pty, String dist)
	{
		this.year = _year;
		this.state = st;
		this.type = _type;
		this.office = off;
		this.name = _name;
		this.party = pty;
		this.district = dist;
		this.data = new ArrayList<ElectionData>();
	}
	
	public CandidateData(int _year, String off, String[] name, String pty, String dist)
	{
		this.year = _year;
		this.office = off;
		this.namePieces = name;
		this.party = pty;
		this.district = dist;
	}
	
	public int partyCheckScore(String nameToCheck, int _year, String off, String dist)
	{
		int matches = 0;

		for (String piece : this.namePieces)
			if (nameToCheck.contains(piece) && _year == this.year
					&& off.equals(this.office) && dist.equals(this.district))
				matches++;
		
		return matches;
	}
	
	public void setOffice(String _office)
	{
		this.office = _office;
	}
	
	public void setDistrict(String dist)
	{
		this.district = dist;
	}
	
	public void addData(ElectionData d)
	{
		this.data.add(d);
	}
	
	public String getDistrict()
	{
		return this.district;
	}
	
	public String getOffice()
	{
		return this.office;
	}
	
	public int getVotes()
	{
		return this.votes;
	}
	
	public double getPercent()
	{
		return this.percent;
	}
	
	public String getName()
	{
		return this.name;
	}
	
	public String getParty()
	{
		return this.party;
	}
	
	public String[] getNames()
	{
		return this.namePieces;
	}
	
	public String getRowPiece()
	{
		String delim = "\t";
		return this.name + delim +
				this.party + delim +
				this.votes + delim +
				this.percent;
	}
	
	public String getRowPiece(String delim)
	{
		return this.name + delim +
				this.party + delim +
				this.votes + delim +
				this.percent;
	}
	
	public String getRows()
	{
		String rows = "";
		String delim = "\t";
		String dist = this.district;
		
		for(ElectionData d : this.data)
		{
			if (!d.getDistrict().equals("") && this.district.equals(""))
				dist = d.getDistrict();
			
			rows += this.state + delim +
					this.year + delim +
					this.type + delim +
					this.name + delim +
					this.office + delim +
					dist + delim +
					this.party + delim +
					d.getRowPiece(delim) + "\r\n";	
		}
		return rows;
	}
	
	public String getRows(String delim)
	{
		String rows = "";
		String dist = this.district;
		
		for(ElectionData d : this.data)
		{
			if (!d.getDistrict().equals("") && this.district.equals(""))
				dist = d.getDistrict();
			
			rows += this.state + delim +
					this.year + delim +
					this.type + delim +
					this.name + delim +
					this.office + delim +
					dist + delim +
					this.party + delim +
					d.getRowPiece(delim) + "\r\n";	
		}
		return rows;
	}
}
