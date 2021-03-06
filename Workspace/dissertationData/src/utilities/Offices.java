package utilities;

public enum Offices
{
	USP (new String[] {"PRESIDENT", "PRESIDENTIAL"}, new String[] {"@", "COMMISSION"}),
	USS (new String[] {"SENATE", "SENATOR"}, new String[] {"STATE ", "DISTRICT", "@"}),
	USH (new String[] {"CONGRESS", "HOUSE", "US REP", "U.S. REP", "UNITED STATES REP", "CONGRESSMAN"},
			new String[] {"@", "SENATE", "SENATOR", "RESOLUTION", "DELEGATE"}),
	GOV (new String[] {"GOVERNOR", "GUBERNATORIAL", "GOV"}, new String[] {"LIEUTENANT", "LT", "BOARD"}),
	LTG (new String[] {"LIEUTENANT", "LT. GOVERNOR"}, new String[] {"/"}),
	STS (new String[] {"STATE SENATE", "STATE SENATOR", "SENATE@", "STATE SEN."},
			new String[] {"US", "U.S", "UNITED STATES"}),
	STH (new String[] {"STATE HOUSE", "STATE REPRESENTATIVE", "REPRESENTATIVE", "ASSEMBLY",
			"REPRESENTATIVES@", "STATE REP.", "STATE REP", "HOUSE OF DELEGATES"}, 
			new String[] {"US ", "U.S.", "UNITED STATES", "RESOLUTION"}),
	ATG (new String[] {"ATTORNEY GENERAL", "ATTORNEY GEN", "ATTGEN"}, new String[] {}),
	SOS (new String[] {"SECRETARY OF STATE", "SECY OF STATE", "SEC. OF STATE", "SOS"},
			new String[] {"OFFICE OF THE SECRETARY"}),
	TRE (new String[] {"TREASURER"}, new String[] {}),
	CON (new String[] {"COMPTROLLER", "CONTROLLER"}, new String[] {}),
	AUD (new String[] {"AUDITOR"}, new String[] {}),
	CCJ (new String[] {"CIRCUIT"}, new String[] {"ATTORNEY"}),
	SCJ (new String[] {"SUPREME COURT", "SUPREME"}, new String[] {}),
	SBOE (new String[] {"STATE BOARD OF EDUCATION", "EDUCATION@"}, new String[] {}),
	ComAg (new String[] {"COMMISSIONER OF AGRICULTURE"}, new String[] {});
	
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
