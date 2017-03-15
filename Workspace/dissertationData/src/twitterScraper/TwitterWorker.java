package twitterScraper;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingQueue;

import twitter4j.Paging;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;

public class TwitterWorker extends Thread
{
	public static final String SHUTDOWN = "STOP";
	
	private static final TwitterWorker instance = new TwitterWorker();
	private static Twitter twitter = null;
	private static LinkedBlockingQueue<String> userQueue = new LinkedBlockingQueue<String>();
	
	private TwitterWorker()
	{
		start();
	}
	
	public static void addTask(String task)
	{
		userQueue.add(task);
	}
	
	public void run()
	{
		TwitterWorker.twitter = Credentials.getCredentials();
		
		String item;
		try
		{
			while ((item = userQueue.take()) != SHUTDOWN)
			{
				TwitterScraper.updateProgress(item);
				
				int pageNum = 1;
				int pageLim = 200;
				int arraySize = pageLim;
				
				while (arraySize == pageLim)
				{
					try
					{
						arraySize = process(item, pageNum, pageLim);
					}
					catch (TwitterException e)
					{
						if (e.getStatusCode() == 401)
						{
							System.err.println("Access tokens invalid; create new access tokens.");
							TwitterWorker.twitter = Credentials.newTokens();
							try
							{
								System.out.println(TwitterWorker.twitter.getOAuthAccessToken().getToken());
								arraySize = process(item, pageNum, pageLim);
							}
							catch (TwitterException e1)
							{
								System.err.println("Resetting access keys failed.");
								e1.printStackTrace();
							}
						}
						else
						{
							arraySize = 0;
							System.err.println("Unhandled error in retreiving query results for user "
									+ item + ".");
							e.printStackTrace();
						}
					}
					pageNum++;
					Thread.sleep(20100); //to prevent rate limit issues (can't have more than 180 tweet requests in 15 minutes)
				}
			}
		}
		catch (InterruptedException e)
		{
			e.printStackTrace();
		}
		
		RelevantTweetsWorker.addTask(SHUTDOWN);
	}

	public static TwitterWorker getInstance()
	{
		return instance;
	}
	
	private static int process(String item, int pageNum, int pageLim) throws TwitterException
	{
		List<Status> tweets = new ArrayList<Status>();
		
		Paging page = new Paging(pageNum, pageLim);
		tweets.addAll(TwitterWorker.twitter.getUserTimeline(item, page));
		for (Status tweet : tweets)
			RelevantTweetsWorker.addTask(tweet);
		
		return tweets.size();
	}
}
