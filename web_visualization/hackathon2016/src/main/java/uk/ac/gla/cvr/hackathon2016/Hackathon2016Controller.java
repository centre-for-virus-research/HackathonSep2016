package uk.ac.gla.cvr.hackathon2016;

import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

public class Hackathon2016Controller {

	public Hackathon2016Controller() {
	}
	
	@POST()
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public String post(String commandString, @Context HttpServletResponse response) {
		System.out.println("POST received: "+commandString);
		String commandResult = "{ok: 1234}";
		addCacheDisablingHeaders(response);
		return commandResult;
	}
	
	// URL navigation
	@Path("/{urlPathSegment}")
	public Object handle(@PathParam("urlPathSegment") String urlPathSegment) {
		return null;
	}

	
	
	private void addCacheDisablingHeaders(HttpServletResponse response) {
		response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
		response.setHeader("Pragma", "no-cache"); // HTTP 1.0.
		response.setHeader("Expires", "0"); // Proxies.
	}
	
}
