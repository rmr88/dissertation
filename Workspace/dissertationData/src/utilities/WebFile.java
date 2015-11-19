package utilities;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;

public class WebFile
{
	//private String url;
	private URL urlObj;
	private FileOutputStream fos;
	private ReadableByteChannel rbc;
	
	public WebFile(String _url, String outDir) throws IOException
	{
		//this.url = _url;
		this.urlObj = new URL(_url);
		this.rbc = Channels.newChannel(this.urlObj.openStream());
		this.fos = new FileOutputStream(outDir);
	}
	
	public void downloadToFile() throws IOException
	{
		this.fos.getChannel().transferFrom(this.rbc, 0, Long.MAX_VALUE);
	}
	
	//TODO download to object in Java scope?
}
