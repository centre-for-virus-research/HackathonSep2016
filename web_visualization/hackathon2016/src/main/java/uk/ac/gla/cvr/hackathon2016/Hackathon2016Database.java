package uk.ac.gla.cvr.hackathon2016;

import org.apache.cayenne.configuration.Constants;
import org.apache.cayenne.configuration.server.ServerRuntime;
import org.apache.cayenne.di.Binder;
import org.apache.cayenne.di.Module;

public class Hackathon2016Database {

	private static Hackathon2016Database instance;
	private static String jdbcUrl, username, password;

	private ServerRuntime serverRuntime;
	
	private Hackathon2016Database(String jdbcUrl, String username, String password) {
		this.serverRuntime = initLocal(jdbcUrl, username, password);
	}
	
	public static Hackathon2016Database getInstance() {
		if(instance == null) {
			instance = new Hackathon2016Database(jdbcUrl, username, password);
		}
		return instance;
	}

	@SuppressWarnings("unused")
	private ServerRuntime initLocal(String jdbcUrl, String username, String password) {
		return new ServerRuntime("cayenne-hackathon2016-local.xml", 
				createCayenneDbConfigModule("20000", "com.mysql.jdbc.Driver", jdbcUrl, username, password));		
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

	public static void setJdbcUrl(String jdbcUrl) {
		Hackathon2016Database.jdbcUrl = jdbcUrl;
	}

	public static void setUsername(String username) {
		Hackathon2016Database.username = username;
	}

	public static void setPassword(String password) {
		Hackathon2016Database.password = password;
	}
	
	
	
}
