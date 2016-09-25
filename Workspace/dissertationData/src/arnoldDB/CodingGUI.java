package arnoldDB;

import java.awt.Container;

import javax.swing.JFrame;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

public class CodingGUI
{ 	
	public static void main(String args[])
	{
		SwingUtilities.invokeLater(new Runnable()
		{
			public void run()
			{
			    try
			    {
			    	initialize();
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
		JFrame frame = new JFrame("Arnold DB --Coding");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		addComponentsToPane(frame.getContentPane());
		frame.pack();
		frame.setVisible(true);
	}
	
	private static void initialize()
	{
		
	}
	
	private static void addComponentsToPane(Container pane)
	{
		
	}
}
