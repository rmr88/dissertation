package tasks;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

public class RunShell
{
	private String cmd;
	private String dir;
//	private String[] params;
	
	public RunShell(String command)
	{
		this.cmd = command;
		this.dir = System.getProperty("user.dir");
	}
	
//	public RunShell(String command, String[] parameters) //not fully implemented
//	{
//		this.cmd = command;
//		this.dir = System.getProperty("user.dir");
//		this.params = parameters;
//	}
	
	public RunShell(String command, String directory)
	{
		this.cmd = command;
		this.dir = directory;
	}
	
//	public RunShell(String command, String directory, String[] parameters) //not fully implemented
//	{
//		this.cmd = command;
//		this.dir = directory;
//		this.params = parameters;
//	}
	
	public String run()
	{
		StringBuffer sb = new StringBuffer();
		ProcessBuilder proc;
		
		try
		{
			proc = new ProcessBuilder("cmd.exe", "/c", this.cmd);
			proc = proc.directory(new File(this.dir));
			Process p = proc.start();
			p.waitFor();
			
			String error = "";
			BufferedReader err = new BufferedReader(new InputStreamReader(p.getErrorStream()));
			while ((error = err.readLine()) != null)
				System.err.println(error);
			err.close();
			
			BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String line = "";
			while ((line = br.readLine()) != null)
				sb.append(line + "\r\n");
			br.close();
		}
		catch (IOException | InterruptedException e)
		{
			e.printStackTrace();
		}
		
		return sb.toString();
	}
	
	public String getCmd()
	{
		return this.cmd;
	}
}
