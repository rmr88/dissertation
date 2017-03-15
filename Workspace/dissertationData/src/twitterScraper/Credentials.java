package twitterScraper;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;

import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;
import utilities.InFile;
import utilities.OutFile;

public class Credentials
{
	private static HashMap<String, String> creds = new HashMap<String, String>();
	
	public static Twitter getCredentials()
	{
		try
		{
			InFile in = new InFile(System.getProperty("user.dir") + "\\resources\\twitterOAuthCredentials.txt");
			String[] line = null;
			
			while (in.isReady())
			{
				line = in.readRowLite("\t");
				creds.put(line[0], line[1]);
			}
			
			in.close();
		}
		catch (IOException e)
		{
			System.err.println("Error getting OAuth credentials from file.");
			e.printStackTrace();
		}
		
		ConfigurationBuilder builder = new ConfigurationBuilder();
		
		builder.setOAuthConsumerKey(creds.get("consumer_key"));
		builder.setOAuthConsumerSecret(creds.get("consumer_secret"));
		builder.setOAuthAccessToken(creds.get("access_key"));
		builder.setOAuthAccessTokenSecret(creds.get("access_secret"));
		
		Configuration configuration = builder.build();
		TwitterFactory factory = new TwitterFactory(configuration);
		return factory.getInstance();
	}
	
	public static Twitter newTokens()
	{
		Twitter tw = getCredentials();
		tw.setOAuthAccessToken(null);
		AccessToken accessToken = null;
		
		try
		{
			RequestToken request = tw.getOAuthRequestToken();
			
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Copy/ paste the URL below into a web browser, authorize new access keys, "
					+ "and enter the PIN below.\r\nAuthorization URL:\r\n" + request.getAuthorizationURL());
			
			while (null == accessToken)
			{
				System.out.print("Enter access pin: ");
				String pin = br.readLine();
				accessToken = tw.getOAuthAccessToken(request, pin);
			}
		}
		catch (TwitterException e1)
		{
			System.err.println("Error getting access tokens");
			e1.printStackTrace();
		}
		catch (IOException e)
		{
			System.err.println("Invalid input.");
			e.printStackTrace();
		}
		
		creds.replace("access_key", accessToken.getToken());
		creds.replace("access_secret", accessToken.getTokenSecret());
		
		try
		{
			OutFile out = new OutFile(System.getProperty("user.dir")
					+ "\\resources\\twitterOAuthCredentials.txt", false);
			for (String key : creds.keySet())
				out.writeLine(key + "\t" + creds.get(key));
			out.close();
		}
		catch (IOException e1)
		{
			System.err.println("Error storing access tokens in file.");
			e1.printStackTrace();
		}

		return tw;
	}
}
