package arnoldDB;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class CodingLauncher
{
	public static void main(String args[])
	{
		String connectionString = "jdbc:microsoft:sqlserver://ROBBIE-HP;DatabaseName=arnoldDB;user=stataRead;password=851hiatus";
		Connection conn = null;
		try
		{
			Class.forName("com.microsoft.jdbc.sqlserver.SQLServerDriver");
			conn = DriverManager.getConnection(connectionString);
		}
		catch (SQLException e)
		{
			System.err.println("Error getting connection to database.");
			e.printStackTrace();
		}
		catch (ClassNotFoundException e)
		{
			e.printStackTrace();
		}
		
		//DB read
		//DBReader();
		//GUI
		//DB write
	}
	
	private void DBReader()
	{
		
	}
}
