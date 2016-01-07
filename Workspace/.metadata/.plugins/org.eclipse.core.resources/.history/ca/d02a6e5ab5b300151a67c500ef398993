package utilities;

public enum Columns
{
	LOCATION (new String[] {"county", "precinct"}, new String[] {}),
	OFFICE (new String[] {"office"}, new String[] {"name"}),
	PARTY (new String[] {"party"}, new String[] {"abbrev"}),
	VOTE (new String[] {"votes", "vote", "total"}, new String[] {"votes"}),
	CANDNAME (new String[] {"candidate", "cand", "can"}, new String[] {"last"});
	
	private String[] conditions, conditions2;
	private Columns(String[] cond, String[] cond2)
	{
		this.conditions = cond;
		this.conditions2 = cond2;
	}
	
	public boolean check(String toCheck)
	{
		for (String checkAgainst : this.conditions)
			if (toCheck.contains(checkAgainst))
				return true;	
		return false; //if no match found
	}
	
	public boolean check2(String toCheck)
	{
		for (String checkAgainst : this.conditions2)
			if (toCheck.contains(checkAgainst))
				return true;	
		return false; //if no match found
	}
}
