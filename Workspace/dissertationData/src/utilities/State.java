package utilities;

public enum State
{
	AL ("AL", "precinct", "parse", new String[] {}, new String[] {}, new int[] {}), //end AL
	CO ("CO", "county", "scrape", new String[] {}, new String[]
			{"president", "usSenate", "congress", "governor", "sos",
			"treasurer", "attGen", "education@", "senate@", "representatives@"},
			new int[] {2014, 2012}), //end CO
	NV ("NV", "county", "scrape", new String[]
				{"CarsonCity", "Churchill", "Clark", "Douglas",
				"Elko", "Esmeralda", "Eureka", "Humboldt", "Lander",
				"Lincoln", "Lyon", "Mineral", "Nye", "Pershing", "Storey",
				"Washoe", "WhitePine"}, new String[] {},
				new int[] {2014, 2012, 2010, 2008, 2006, 2004, 2002, 2000}); //end NV
	
	private final String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
			+ "\\elections\\stateResults\\";
	private String state, geoType, processType, statePath;
	private String[] locations, offices;
	private int[] years;
	
	private State(String st, String geo, String proc, String[] loc, String[] off, int[] yrs)
	{
		this.state = st;
		this.geoType = geo;
		this.processType = proc;
		this.statePath = this.basePath + st;
		this.locations = loc;
		this.offices = off;
		this.years = yrs;
	}

	public String getState()
	{
		return this.state;
	}

	public String getGeoType()
	{
		return this.geoType;
	}
	
	public String getProcessType()
	{
		return this.processType;
	}
	
	public String getPath()
	{
		return this.statePath;
	}
	
	public String getBasePath()
	{
		return this.basePath;
	}
	
	public String[] getLocations()
	{
		return this.locations;
	}
	
	public String[] getOffices()
	{
		return this.offices;
	}
	
	public int[] getYears()
	{
		return this.years;
	}
}
