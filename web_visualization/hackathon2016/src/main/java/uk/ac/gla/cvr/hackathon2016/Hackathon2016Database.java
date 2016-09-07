package uk.ac.gla.cvr.hackathon2016;

import org.apache.cayenne.configuration.Constants;
import org.apache.cayenne.configuration.server.ServerRuntime;
import org.apache.cayenne.di.Binder;
import org.apache.cayenne.di.Module;

public class Hackathon2016Database {

	private static Hackathon2016Database instance;

	private ServerRuntime serverRuntime;
	
	private Hackathon2016Database() {
		this.serverRuntime = initLocal();
	}
	
	public static Hackathon2016Database getInstance() {
		if(instance == null) {
			instance = new Hackathon2016Database();
		}
		return instance;
	}

	@SuppressWarnings("unused")
	private ServerRuntime initLocal() {
		return new ServerRuntime("cayenne-hackathon2016-local.xml");		
	}

	public ServerRuntime getServerRuntime() {
		return serverRuntime;
	}

	@SuppressWarnings("unused")
	private ServerRuntime initAlpha() {
		return new ServerRuntime("cayenne-hackathon2016-alpha.xml");		
	}

	
	public static Module createCayenneDbConfigModule(String cacheSizeFinal,
			String jdbcDriverClass, String jdbcUrl, String username,
			String password) {
		Module dbConfigModule = new Module() {
			  @Override
			  public void configure(Binder binder) {
				binder.bindMap(Constants.PROPERTIES_MAP)
			       .put(Constants.JDBC_DRIVER_PROPERTY, jdbcDriverClass)
			       .put(Constants.JDBC_URL_PROPERTY, jdbcUrl)
			       .put(Constants.QUERY_CACHE_SIZE_PROPERTY, cacheSizeFinal)
			       .put(Constants.JDBC_USERNAME_PROPERTY, username)
			       .put(Constants.JDBC_PASSWORD_PROPERTY, password);
			  }
		};
		return dbConfigModule;
	}
}
