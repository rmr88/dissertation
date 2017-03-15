package twitterScraper;

import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.concurrent.LinkedBlockingQueue;

import twitter4j.Status;
import utilities.OutFile;

public class RelevantTweetsWorker extends Thread
{
	private static final RelevantTweetsWorker instance = new RelevantTweetsWorker();
	private static final String[] searchTerms = { "#VBP", "#VALUEBASEDPAYMENT", "#BUNDLEDPAYMENT",
			"#BUNDLEPAYMENT", "#ACO", "#ACOS", "#P4P", "#PAYFORPERFORMANCE", "#PAYMENTREFORM",
			"#APM", "VALUE-BASED PAYMENT", "PAYMENT REFORM", "ACCOUNTABLE CARE ORGANIZATION",
			" ACO ", " ACOS ", "BUNDLED PAYMENT" };
	
	private static LinkedBlockingQueue<Object> tweetQueue = new LinkedBlockingQueue<Object>();
	private static String outputFile;
	private static boolean append;
	
	private RelevantTweetsWorker()
	{
		start();
	}
	
	public static void addTask(Object task)
	{
		tweetQueue.add(task);
	}
	
	public static void setUserParams(String path, boolean _append)
	{
		outputFile = path;
		append = _append;
	}
	
	public void run()
	{
		OutFile out = null;
		try
		{
			out = new OutFile(outputFile, append);
			out.writeLine("userName\thandle\ttweet\tdatePosted\ttweetID\turl");
		}
		catch (IOException e2)
		{
			System.err.println("Error setting up output file.");
			e2.printStackTrace();
		}
		
		Object item;
		int numTweets = 0;
		
		try
		{
			while ((item = tweetQueue.take()) instanceof Status)
			{
				Status tweet = (Status) item;
				LocalDate date = tweet.getCreatedAt().toInstant()
						.atZone(ZoneId.systemDefault()).toLocalDate();
				
				boolean keep = false;
				if (date.getYear() == 2016) //TODO add ability to change timeframe
				{
					for (String term : searchTerms)
					{
						if (tweet.getText().toUpperCase().contains(term))
						{
							keep = true;
							break;
						}
					}
				}
				
				try
				{
					if (keep)
					{
						out.write(tweet.getUser().getName() + "\t"
								+ tweet.getUser().getScreenName() + "\t"
								+ tweet.getText().replaceAll("[\r\n]", " ") + "\t"
								+ tweet.getCreatedAt() + "\t"
								+ tweet.getId() + "\t");
						
						if (tweet.getURLEntities().length > 0)
							out.writeLine(tweet.getURLEntities()[0].getURL());
						else out.writeLine("");
						numTweets++;
					}
				} 
				catch (IOException e)
				{
					System.err.println("Error writing to file.");
					e.printStackTrace();
				}
			}
		}
		catch (InterruptedException e)
		{
			e.printStackTrace();
		}
		
		out.close();
		TwitterScraper.updateProgress(numTweets + " relevant tweets retreived.");
		TwitterScraper.setButtonsEnabled(true);
	}

	public static RelevantTweetsWorker getInstance()
	{
		return instance;
	}
}
