package launchers.elections;

import tasks.ElectionParser;
import utilities.State;

public class ParseAndScrape
{
	public static void main(String args[])
	{
		for (State state : State.values())
		{ //loop through all states coded so far in State enum
			if (state.getProcessType().equals("scrape")) {}
				//new ElectionScraper(state).run();
			else if (state.getProcessType().equals("parse"))
				new ElectionParser(state).run();
			else
				System.err.println(state.getState() + ": No process defined for this process type: "
						+ state.getProcessType());
		} //end state loop
	} //end main
}
