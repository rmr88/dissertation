package launchers;

import java.awt.Container;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import tasks.VoteViewDownload;
import utilities.InFile;
import utilities.OutFile;

public class VoteViewLauncher
{
	private static String folder = "C:\\Users\\Robbie\\Documents\\dissertation\\Data\\VoteView\\downloads";
	
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
        JButton downloadButton, parseButton, closeButton;
        
        downloadButton = new JButton("Download Files");
        downloadButton.addActionListener(new ActionListener()
		{
        	public void actionPerformed(ActionEvent e)
        	{ 
        		VoteViewLauncher.download();
        	}
		});
        
        parseButton = new JButton("Parse Files");
        parseButton.addActionListener(new ActionListener()
		{
        	public void actionPerformed(ActionEvent e)
        	{ 
        		VoteViewLauncher.parse();
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
        
		pane.setLayout(new GridBagLayout());
		GridBagConstraints c = new GridBagConstraints();
		
	    c.insets = new Insets(2,4,2,4);
	    c.fill = GridBagConstraints.BOTH;
	    c.gridx = 0;
	    c.gridy = 0;
	    pane.add(downloadButton, c);

	    c.gridx = 1;
	    pane.add(parseButton, c);

		c.gridx = 1;
		c.gridy = 1;
		pane.add(closeButton, c);
	}
	
	public static void download()
	{
		
//		try
//		{
//			new VoteViewDownload("ftp://voteview.com/dtaord/#kh.ord", folder).run();
//		}
//		catch (IOException e)
//		{
//			e.printStackTrace();
//		}
		
		File folderObj = new File(folder);
		File[] files = folderObj.listFiles();
		
		for (File dict : files)
		{
			//File dict = new File(folder + "\\hou93desc_dtl.txt");
			if (dict.getName().matches("^hou[0-9]{2,3}desc_dtl.txt"))
			{
				parseDTL(dict, 7);
			}
			else if (dict.getName().matches("^hou[0-9]{2,3}desc_htm.txt"))
			{
				parseHTM(dict);
				System.out.println(dict.getName());
			}
			else if (dict.getName().matches("^sen[0-9]{2,3}desc_dtl.txt"))
			{
				parseDTL(dict, 12);
			}
			else if (dict.getName().matches("^sen[0-9]{2,3}desc_htm.txt"))
			{
				parseHTM(dict); //TODO 102nd congress, and possibly others, needs different parsing of bill names, yea/ nay counts, etc.
				System.out.println(dict.getName());
			}
		}
		
		System.out.println("Done with downloads.");
	}
	
	public static void parseDTL(File dict, int index)
	{
		String line = "";
		String nextLine = "";
		InFile in = null;
		OutFile out = null;
		
		try
		{
			in = new InFile(dict);
			out = new OutFile(folder + "\\" + dict.getName().replace("dtl", "final"), false);
			
			nextLine = in.readLine();
			while (in.isReady())
			{
				line = nextLine.substring(0, 4) + "\t";
				do
				{
					line += nextLine.substring(index).replaceFirst("\\s+$", ""); //TODO will need to dynamically update this index to account for different layouts
					nextLine = in.readLine();
				}
				while (nextLine.substring(0, 4).equals(line.substring(0, 4))
						&& in.isReady());
				
				line = line.replaceAll(" {2,}", "\t");
				line = line.replaceAll("Y=[0-9]* N=[0-9]*", "$0\t\t");
				line = line.replaceAll("\t\t\t", "\t");
				line = line.replaceFirst("Y=[0-9]* N=[0-9]*\\t.*, \\w\\.\\w\\.|"
						+ "Y=[0-9]* N=[0-9]*\\t.*, [\\w]{2,5}\\.", "$0\t");
				line = line.replaceAll("OHIOTO", "OHIO\tTO");
				line = line.replaceAll("IOWATO", "IOWA\tTO");
				line = line.replaceAll("UTAHTO", "UTAH\tTO");
				
				out.writeLine(line.trim());
			}
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
		finally
		{
			in.close();
			out.close();
		}
	}
	
	public static void parseHTM(File dict)
	{
		
	}
	
	public static void parse()
	{
		System.out.println("running run() method...");

		File folderObj = new File(folder);
		File[] files = folderObj.listFiles();
		
		InFile in = null;
		OutFile outMC = null;
		OutFile outVote = null;
		String line = "";
		int[] indices = {0, 3, 8, 10, 12, 20, 23, 24, 25, 36};
		String mcData = "";
		String mcID = "";
		
		try
		{
			outMC = new OutFile(folder.substring(0, folder.lastIndexOf("\\")) + "\\mcVoteData.txt", false);
			outVote = new OutFile(folder.substring(0, folder.lastIndexOf("\\")) + "\\voteData.txt", false); 
		}
		catch (IOException e1)
		{
			e1.printStackTrace();
		}
		
		for(File textFile : files)
		{
			try
			{
				in = new InFile(textFile);
				
				while (in.isReady())
				{
					line = in.readLine();
					
					for (int index = 1; index < indices.length; index++)
						mcData += line.substring(indices[index-1], indices[index]).trim() + "\t";
					outMC.writeLine(mcData.trim());
					
					mcID = line.substring(indices[1], indices[2]).trim();
					for (int x = indices[indices.length-1]; x < line.length(); x++)
						outVote.writeLine(mcID + "\t" + line.substring(x, x+1)); //TODO will need to add bill ID to each record.
					
					mcData = "";
				}
			}
			catch (IOException e)
			{
				e.printStackTrace();
			}
			finally
			{
				in.close();
			}
		}
		System.out.println("Done parsing files.");
	}
}
