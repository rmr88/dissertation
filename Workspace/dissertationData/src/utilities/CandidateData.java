package utilities;

import java.util.ArrayList;

public class CandidateData
{
	private String name, party, state, type, office, district;
	private int votes, year;
	private double percent;
	private ArrayList<ElectionData> data;
	
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
		
		for(ElectionData d : this.data)
		{
			rows += this.state + delim +
					this.year + delim +
					this.type + delim +
					this.name + delim +
					this.office + delim +
					this.district + delim +
					this.party + delim +
					d.getRowPiece(delim) + "\r\n";	
		}
		return rows;
	}
	
	public String getRows(String delim)
	{
		String rows = "";
		for(ElectionData d : this.data)
		{
			rows += this.state + delim +
					this.year + delim +
					this.type + delim +
					this.name + delim +
					this.office + delim +
					this.district + delim +
					this.party + delim +
					d.getRowPiece(delim) + "\r\n";	
		}
		return rows;
	}
}
