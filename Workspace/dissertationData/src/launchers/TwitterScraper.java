package launchers;

import java.awt.Container;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;

import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JRadioButton;
import javax.swing.JTextField;
import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import twitter4j.Query;
import twitter4j.QueryResult;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;
import utilities.InFile;
import utilities.OutFile;

public class TwitterScraper
{
	private static Twitter twitter = null;
	private static HashMap<String, String> credentials;
	private static boolean append = true;
	
	public static void main(String[] args)
	{
		SwingUtilities.invokeLater(new Runnable()
		{
			public void run()
			{
				try
				{
					createAndShowGUI();
				}
				catch (ClassNotFoundException | InstantiationException | IllegalAccessException
						| UnsupportedLookAndFeelException e)
				{
					e.printStackTrace();
				}
			}
		});
	}
	
	private static void createAndShowGUI() throws ClassNotFoundException, InstantiationException, 
	IllegalAccessException, UnsupportedLookAndFeelException
	{
		JFrame frame = new JFrame("GridBagLayoutDemo");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		addComponentsToPane(frame.getContentPane());
		frame.pack();
		frame.setVisible(true);
	}
	
	public static void addComponentsToPane(Container pane)
	{
		JButton downloadButton, fileButton, closeButton;
		JTextPane progress = new JTextPane();
		JLabel searchLabel = new JLabel("Search Terms:");
		
		JTextField searchTerms = new JTextField("PCMH");
		JTextField filePath = new JTextField("");
		filePath.setEnabled(false);
		
		final JFileChooser fc = new JFileChooser();
		fc.setCurrentDirectory(new File("C:\\Users\\Robbie\\Documents\\ArnFound\\Data"));
		
		downloadButton = new JButton("Run Search");
		downloadButton.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				downloadButton.setText("Running...");
				downloadButton.setEnabled(false);
				pane.revalidate();
				pane.repaint();
				
				new TwitterScraper().run(new File(filePath.getText()), searchTerms.getText(), append);
				
				downloadButton.setText("Run Search");
				downloadButton.setEnabled(true);
				pane.revalidate();
				pane.repaint();
			}
		});
		
		fileButton = new JButton("Output File");
		fileButton.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				int returnVal = fc.showOpenDialog(pane);
				if (returnVal == JFileChooser.APPROVE_OPTION)
					filePath.setText(fc.getSelectedFile().getAbsolutePath());
			}
		});
		
		closeButton = new JButton("Close");
		closeButton.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{ 
				System.exit(0);
			}
		});
		
		JRadioButton apndTrue = new JRadioButton("Append");
		apndTrue.addActionListener(new ActionListener()
	   	{
			public void actionPerformed(ActionEvent e)
			{
				TwitterScraper.append = true;
			}
 		});
		
		JRadioButton apndFalse = new JRadioButton("Replace");
		apndFalse.addActionListener(new ActionListener()
	   	{
			public void actionPerformed(ActionEvent e)
			{
				TwitterScraper.append = false;
			}
 		});
		
		ButtonGroup group = new ButtonGroup();
		group.add(apndFalse);
		group.add(apndTrue);
		
		pane.setLayout(new GridBagLayout());
		GridBagConstraints c = new GridBagConstraints();
		
		filePath.setPreferredSize(new Dimension(300, 10));
		filePath.setSize(filePath.getPreferredSize());
		
		searchTerms.setPreferredSize(new Dimension(200, 10));
		searchTerms.setSize(searchTerms.getPreferredSize());
		
		progress.setPreferredSize(new Dimension(400, 400));
		progress.setSize(progress.getPreferredSize());
		
		c.insets = new Insets(2,4,2,4);
		c.fill = GridBagConstraints.BOTH;
		c.gridx = 0;
		c.gridy = 0;
		pane.add(fileButton, c);

		c.gridx = 1;
		c.gridwidth = 2;
		pane.add(filePath, c);
		
		c.gridwidth = 1;
		c.gridx = 0;
		c.gridy = 1;
		pane.add(apndTrue, c);
		
		c.gridx = 1;
		pane.add(apndFalse, c);
		
		c.gridx = 0;
		c.gridy = 2;
		pane.add(downloadButton, c);

		c.gridx = 1;
		pane.add(searchLabel, c);
		
		c.gridx = 2;
		pane.add(searchTerms, c);
		
		c.gridx = 2;
		c.gridy = 3;
		c.fill = GridBagConstraints.NONE;
		c.anchor = GridBagConstraints.EAST;
		pane.add(closeButton, c);
	}
	
	public void run(File outputFile, String terms, boolean append)
	{
		TwitterScraper.credentials = this.getCredentials();
		ConfigurationBuilder builder = new ConfigurationBuilder();
		
		builder.setOAuthConsumerKey(credentials.get("consumer_key"));
		builder.setOAuthConsumerSecret(credentials.get("consumer_secret"));
		builder.setOAuthAccessToken(credentials.get("access_key"));
		builder.setOAuthAccessTokenSecret(credentials.get("access_secret"));
		
		Configuration configuration = builder.build();
		TwitterFactory factory = new TwitterFactory(configuration);
		TwitterScraper.twitter = factory.getInstance();
		
		ArrayList<Status> tweets = null;
		
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
		
		try
		{
			tweets = this.runQuery(new Query(terms));
		}
		catch (TwitterException e)
		{
			if (e.getStatusCode() == 401)
			{
				System.err.println("Access tokens invalid; create new access tokens.");
				TwitterScraper.twitter = this.newTokens(credentials);
				try
				{
					this.runQuery(new Query(terms));
				}
				catch (TwitterException e1)
				{
					System.err.println("Resetting access keys failed.");
					e1.printStackTrace();
				}
			}
			else
			{
				System.err.println("Unhandled error in retreiving query results.");
				e.printStackTrace();
			}
		}
		
		for (int i = 0; i < tweets.size(); i++)
		{
			try
			{
				out.write(tweets.get(i).getUser().getName() + "\t@"
						+ tweets.get(i).getUser().getScreenName() + "\t"
						+ tweets.get(i).getText().replaceAll("[\r\n]", " ") + "\t"
						+ tweets.get(i).getCreatedAt() + "\t"
						+ tweets.get(i).getId() + "\t");
				
				if (tweets.get(i).getURLEntities().length > 0)
					out.writeLine(tweets.get(i).getURLEntities()[0].getURL());
				else out.writeLine("");
			} 
			catch (IOException e)
			{
				System.err.println("Error writing to file.");
				e.printStackTrace();
			}
		}
		out.close();
		System.out.println(tweets.size() + " tweets retreived.");
	}
	
	private ArrayList<Status> runQuery(Query q) throws TwitterException
	{
		ArrayList<Status> tweets = new ArrayList<Status>();
		QueryResult result = null;
		
		//TODO figure out how to get around rate limit
		int numberOfTweets = 500;
		long lastID = Long.MAX_VALUE;
		q.setCount(100);
		
		int change = 101;
		int lastSize = 0;
		
		while (tweets.size () < numberOfTweets && change > 0)
		{
			try
			{
				lastSize = tweets.size();
				result = TwitterScraper.twitter.search(q);
			}
			catch (TwitterException e)
			{
				if (e.getStatusCode() == 429)
				{
					long remaining = e.getRateLimitStatus().getSecondsUntilReset();
					System.out.println("Rate limit exceeded; waiting " + (remaining) + " seconds for next window.");
					
					try { Thread.sleep(remaining * 1000); }
					catch (InterruptedException e1) { e1.printStackTrace(); }
					
					System.out.println("Resuming...");
					continue;
				}
				else
					throw new TwitterException(e);
			}
			finally
			{
				if (result != null)
				{
					tweets.addAll(result.getTweets());
					change = tweets.size() - lastSize;
					
					for (Status t: tweets) 
						if(t.getId() < lastID)
							lastID = t.getId();
					
					q.setMaxId(lastID-1);
				}
			}
		}
		
		return tweets;
	}
	
	
	private HashMap<String, String> getCredentials()
	{
		HashMap<String, String> creds = new HashMap<String, String>();
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
		
		return creds;
	}
	
	
	private Twitter newTokens(HashMap<String, String> creds)
	{
		ConfigurationBuilder newBuild = new ConfigurationBuilder();
		
		newBuild.setOAuthConsumerKey(creds.get("consumer_key"));
		newBuild.setOAuthConsumerSecret(creds.get("consumer_secret"));
		newBuild.setOAuthAccessToken(null);
		newBuild.setOAuthAccessTokenSecret(null);
		
		Configuration config = newBuild.build();
		TwitterFactory factory = new TwitterFactory(config);
		Twitter tw = factory.getInstance();
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
