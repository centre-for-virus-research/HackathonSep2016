package uk.ac.gla.cvr.hackathon2016;

import javax.ws.rs.Path;

@Path("/")
public class Hackathon2016RequestHandler {
	
	@Path("/")
	public Object handleRequest() {
		Hackathon2016Controller cmdContext = new Hackathon2016Controller();
		return cmdContext;
	}
}
