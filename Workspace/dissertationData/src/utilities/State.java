package utilities;

public enum State
{
//	AL ("AL", "precinct", "parse", new String[] {}, new String[] {},
//			new int[] {1998, 1996, 1994, 1992}, ".txt"), //end AL
//	CO ("CO", "county", "scrape", new String[] {}, new String[]
//			{"president", "usSenate", "congress", "governor", "sos",
//			"treasurer", "attGen", "education@", "senate@", "representatives@"},
//			new int[] {2014, 2012}, ""), //end CO
//	FL ("FL", "county", "parse", new String[] {}, new String[] {},
//			new int[] {2014, 2012, 2010, 2008, 2006, 2004, 2002, 2000, 1998,
//			1996, 1994, 1992, 1990, 1988, 1986, 1984, 1982, 1980, 1978}, ".txt"), //end FL
//	ID ("ID", "precinct", "parse", new String[] {}, new String[] {},
//			new int[] {1998, 1996, 1994, 1992}, ".txt"), //end ID
//	ID2("ID", "county", "parse", new String[] {}, new String[] {}, new int[] {1990}, ".txt"), //end ID2
//	IL ("IL", "county", "parse", new String[] {}, new String[] {},
//			new int[] {2014, 2012, 2010, 2008, 2006, 2004, 2002, 2000, 1998}, ".txt"), //end IL
	MA ("MA", "precinct", "parse", new String[] {}, new String[] {"usp", "uss", "gov"},
			new int[] {2002}, ".csv"), //end MA
	MA2("MA", "muni", "parse", new String[] {}, new String[] {"usp", "uss", "gov"},
			new int[] {2000, 1998, 1996, 1994, 1992, 1990, 1988, 1986, 1984, 1982,
			1980, 1978, 1976, 1974, 1972, 1970}, ".csv"), //end MA2
//	NV ("NV", "county", "scrape", new String[] {"CarsonCity", "Churchill", "Clark",
//			"Douglas", "Elko", "Esmeralda", "Eureka", "Humboldt", "Lander", "Lincoln",
//			"Lyon", "Mineral", "Nye", "Pershing", "Storey", "Washoe", "WhitePine"},
//			new String[] {}, new int[] {2014, 2012, 2010, 2008, 2006, 2004, 2002, 2000}, ""), //end NV
	VA ("VA", "precinct", "parse", new String[] {}, new String[] {"usp", "uss", "gov"},
			new int[] {2012, 2009, 2004, 2002, 2000, 1997, 1996}, ".csv"), //end VA
	VA2("VA", "muni", "parse", new String[] {}, new String[] {"usp", "uss", "gov"},
			new int[] {1994, 1993, 1992, 1990, 1989, 1988, 1985, 1984, 1982, 1981, 1980,
			1978, 1977, 1976, 1973, 1972}, ".csv"); //end VA2
//	WA ("WA", "county", "parse", new String[] {}, new String[] {},
//			new int[] {2000, 1998, 1996, 1994, 1992, 1990, 1988, 1986, 1984, 1982, 1980, 1978,
//			1976, 1974, 1972, 1970, 1968, 1966, 1964, 1962, 1960, 1958, 1956}, ".txt"); //end WA
	
	private final String basePath = "C:\\Users\\Robbie\\Documents\\dissertation\\Data"
			+ "\\elections\\stateResults\\";
	private String state, geoType, processType, statePath, fileType;
	private String[] locations, offices;
	private int[] years;
	
	private State(String st, String geo, String proc, String[] loc, String[] off,
			int[] yrs, String fType)
	{
		this.state = st;
		this.geoType = geo;
		this.processType = proc;
		this.statePath = this.basePath + st;
		this.locations = loc;
		this.offices = off;
		this.years = yrs;
		this.fileType = fType;
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
	
	public String getFileType()
	{
		return this.fileType;
	}
}
