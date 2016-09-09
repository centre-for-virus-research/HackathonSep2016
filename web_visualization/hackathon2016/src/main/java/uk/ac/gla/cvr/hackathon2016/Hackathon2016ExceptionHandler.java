package uk.ac.gla.cvr.hackathon2016;

import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;

public class Hackathon2016ExceptionHandler implements ExceptionMapper<Exception>{

    @Context
    private HttpHeaders headers;
	@Override
	public Response toResponse(Exception exception) {
        String entity = exception.getMessage();
		return Response.status(500).entity(entity).build();
	}
}