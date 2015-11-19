package tests;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonNull;
import com.google.gson.JsonObject;

import utilities.Cosponsor;
import utilities.OutFile;


public class JSONReader
{
	private URL url;
	private BufferedReader br = null;
	private Gson gson = new Gson();
	private JsonObject json = new JsonObject();
	private OutFile out = null;
	private final String[] KEYS = {"bill_id", "bill_type", "congress", "cosponsors#",
			"introduced_at", "sponsor:thomas_id","subjects#", "subjects_top_term"};
	private final int LIMIT = this.KEYS.length-1;
	
	public JSONReader(String outDir) throws IOException
	{
		out = new OutFile(outDir, false);
		out.writeRow(this.KEYS, "\t", "#");
	}
	
	public void run(String _url)
	{
		JsonObject obj;
		JsonElement element;
		
		try
		{
			this.url = new URL(_url);
			this.br = new BufferedReader(new InputStreamReader(url.openStream()));
			this.json = this.gson.fromJson(this.br, JsonNull.class);
			
			for (int i = 0; i < this.LIMIT; i++)
			{
				if (this.KEYS[i].contains("#"))
				{
					if (KEYS[i].equals("cosponsors#")) //TODO: figure out how to do this one better, using check for JSON array
					{
						Cosponsor[] cosponsors = this.gson.fromJson(this.json.get(this.KEYS[i].replace("#", "")), Cosponsor[].class);
					
						this.out.write("[");
						for (int c = 0; c < cosponsors.length-1; c++)
							this.out.write(cosponsors[c].thomas_id + ";");
						this.out.write(cosponsors[cosponsors.length-1].thomas_id + "]\t");
					}
					else
					{
						this.out.write(this.json.get(this.KEYS[i].replace("#", "")).
								toString().replaceAll("\"", "").replaceAll(",", ";") + "\t");
					}
				}
				else if (this.KEYS[i].contains(":"))
				{
					element = this.json.get(this.KEYS[i].substring(0, this.KEYS[i].indexOf(":")));
					obj = element.getAsJsonObject();
					this.out.write(obj.get(this.KEYS[i].substring(this.KEYS[i].indexOf(":")+1)).getAsString() + "\t");
				}
				else
				{
					this.out.write(this.json.get(this.KEYS[i]).getAsString() + "\t");
				}
			}
			this.out.writeLine(this.json.get(this.KEYS[this.LIMIT]).getAsString());
		} 
		catch (IOException e)
		{
			e.printStackTrace();
		}
	}
}
