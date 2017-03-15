package twitterScraper;

import java.awt.Container;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import utilities.InFile;

public class TwitterScraper
{
	
	private static boolean append = true;
	private static JTextPane progress = new JTextPane();
	private static JButton downloadButton, outputButton, listButton, closeButton;
	
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
		JLabel searchLabel = new JLabel("OR Enter user IDs manually (space-separated):");
		
		JTextField userID = new JTextField("");
		JTextField outputPath = new JTextField("C:\\Users\\Robbie\\Documents\\ArnFound\\Data\\tweets_2016.txt");
		outputPath.setEnabled(false);
		JTextField listPath = new JTextField("C:\\Users\\Robbie\\Documents\\ArnFound\\Data\\twitterHandles.txt");
		listPath.setEnabled(false);
		
		final JFileChooser fc = new JFileChooser();
		fc.setCurrentDirectory(new File("C:\\Users\\Robbie\\Documents\\ArnFound\\Data"));
		
		outputButton = new JButton("Output File");
		outputButton.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				int returnVal = fc.showOpenDialog(pane);
				if (returnVal == JFileChooser.APPROVE_OPTION)
					outputPath.setText(fc.getSelectedFile().getAbsolutePath());
			}
		});
		
		listButton = new JButton("Select a list of users");
		listButton.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				int returnVal = fc.showOpenDialog(pane);
				if (returnVal == JFileChooser.APPROVE_OPTION)
					listPath.setText(fc.getSelectedFile().getAbsolutePath());
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
		
		downloadButton = new JButton("Run Search");
		downloadButton.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				if (outputPath.getText().equals(""))
				{
					JOptionPane.showMessageDialog(pane,
							"Please specify an output file before proceeding.");
				}
				else if (userID.getText().equals("") && listPath.getText().equals(""))
				{
					JOptionPane.showMessageDialog(pane,
							"Please specify a user ID or list of user IDs before proceeding.");
				}
				else
				{
					setButtonsEnabled(false);
					progress.setText("Running...");
					
					RelevantTweetsWorker.setUserParams(outputPath.getText(), append);
					if (!listPath.getText().equals(""))
					{
						for (String user : usersFromFile(listPath.getText()))
							TwitterWorker.addTask(user);
					}
					else
					{
						for (String user : userID.getText().split(" "))
							TwitterWorker.addTask(user);
					}
					
					TwitterWorker.addTask(TwitterWorker.SHUTDOWN);
				}
			}
		});
		
		JRadioButton apndTrue = new JRadioButton("Append (default)");
		apndTrue.setSelected(true);
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
		
		outputPath.setPreferredSize(new Dimension(300, 10));
		outputPath.setSize(outputPath.getPreferredSize());
		
		listPath.setPreferredSize(new Dimension(300, 10));
		listPath.setSize(listPath.getPreferredSize());
		
		userID.setPreferredSize(new Dimension(200, 20));
		userID.setSize(userID.getPreferredSize());
		
		progress.setPreferredSize(new Dimension(400, 400));
		progress.setSize(progress.getPreferredSize());
		JScrollPane progressPane = new JScrollPane(progress);
		
		c.insets = new Insets(2,4,2,4);
		c.fill = GridBagConstraints.BOTH;
		c.gridx = 0;
		c.gridy = 0;
		pane.add(outputButton, c);

		c.gridx = 1;
		c.gridwidth = 2;
		pane.add(outputPath, c);
		
		c.gridwidth = 1;
		c.gridx = 0;
		c.gridy = 1;
		pane.add(apndTrue, c);
		
		c.gridx = 1;
		pane.add(apndFalse, c);
		
		c.gridy = 2;
		c.gridx = 0;
		pane.add(listButton, c);
		
		c.gridx = 1;
		c.gridwidth = 2;
		pane.add(listPath, c);
		
		c.gridy = 3;
		c.gridx = 0;
		pane.add(searchLabel, c);
		
		c.gridx = 2;
		c.gridwidth = 1;
		pane.add(userID, c);
		
		c.gridx = 0;
		c.gridy = 4;
		pane.add(downloadButton, c);
		
		c.gridy = 5;
		c.gridx = 0;
		c.gridwidth = 3;
		pane.add(progressPane, c);

		c.gridy = 4;
		c.gridx = 2;
		c.gridwidth = 1;
		c.fill = GridBagConstraints.NONE;
		c.anchor = GridBagConstraints.EAST;
		pane.add(closeButton, c);
	}
	
	public static void setButtonsEnabled(boolean enabled)
	{
		downloadButton.setEnabled(enabled);
		listButton.setEnabled(enabled);
		outputButton.setEnabled(enabled);
		closeButton.setEnabled(enabled);
	}
	
	public static void updateProgress(String toAppend)
	{
		progress.setText(progress.getText() + "\r\n" + toAppend);
	}
	
	private static String[] usersFromFile(String path)
	{
		List<String> userIDs = new ArrayList<String>();
		
		InFile ids = null;
		try
		{
			ids = new InFile(path);
			while (ids.isReady())
			{
				String[] line = ids.readLine().replaceAll("@", "").split(" ");
				userIDs.addAll(Arrays.asList(line));
			}
		}
		catch (IOException e)
		{
			System.err.println("Error reading user ID list file.");
			e.printStackTrace();
		}
		
		return userIDs.toArray(new String[] {});
	}
}
