package utilities;

public enum Offices
{
	USP (new String[] {"PRESIDENT", "PRESIDENTIAL"}, new String[] {"@", "COMMISSION"}),
	USS (new String[] {"SENATE", "SENATOR"}, new String[] {"STATE ", "DISTRICT", "@"}),
	USH (new String[] {"CONGRESS", "HOUSE", "REPRESENTATIVE", "US REP"}, new String[] {"@"}),
	GOV (new String[] {"GOVERNOR", "GUBERNATORIAL", "GOV"}, new String[] {"LIEUTENANT", "LT", "BOARD"}),
	LTG (new String[] {"LIEUTENANT", "LT. GOVERNOR"}, new String[] {}),
	STS (new String[] {"STATE SENATE", "STATE SENATOR", "SENATE@", "STATE SEN."},
			new String[] {"US", "U.S", "UNITED STATES"}),
	STH (new String[] {"STATE HOUSE", "STATE REPRESENTATIVE", "ASSEMBLY", "REPRESENTATIVES@",
			 "STATE REP."}, new String[] {"US", "U.S", "UNITED STATES"}),
	ATG (new String[] {"ATTORNEY GENERAL", "ATTORNEY GEN", "ATTGEN"}, new String[] {}),
	SOS (new String[] {"SECRETARY OF STATE", "SECY OF STATE", "SEC. OF STATE", "SOS"},
			new String[] {"OFFICE OF THE SECRETARY"}),
	TRE (new String[] {"TREASURER"}, new String[] {}),
	CCJ (new String[] {"CIRCUIT"}, new String[] {"ATTORNEY"}),
	SCJ (new String[] {"SUPREME COURT", "SUPREME"}, new String[] {}),
	SBOE (new String[] {"STATE BOARD OF EDUCATION", "EDUCATION"}, new String[] {}); //TODO make sure the "EDUCATION" token doesn't conflate other office names
	
	
	private String[] keys, exclusions;
	
	private Offices(String[] _keys, String[] _exclusions)
	{
		this.keys = _keys;
		this.exclusions = _exclusions;
	}
	
	public String[] getKeys()
	{
		return this.keys;
	}
	
	public String[] getExclusions()
	{
		return this.exclusions;
	}
}
