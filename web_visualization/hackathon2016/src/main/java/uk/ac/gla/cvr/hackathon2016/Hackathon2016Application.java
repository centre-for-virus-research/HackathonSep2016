package uk.ac.gla.cvr.hackathon2016;

import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.logging.Logger;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import javax.ws.rs.ApplicationPath;

import org.glassfish.jersey.server.ResourceConfig;

import com.mysql.jdbc.AbandonedConnectionCleanupThread;

@WebListener
@ApplicationPath("/")
public class Hackathon2016Application extends ResourceConfig implements ServletContextListener {

	private static Logger logger = Logger.getLogger("uk.ac.gla.cvr.hackathon2016");
	
	public Hackathon2016Application() {
		super();
    	registerInstances(new Hackathon2016RequestHandler());
    	registerInstances(new Hackathon2016ExceptionHandler());
	}


	
	
	@Override
	public void contextInitialized(ServletContextEvent sce) {
	}

	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		cleanupMySQL();
	}
    
	private void cleanupMySQL() {
		Enumeration<Driver> drivers = DriverManager.getDrivers();
        Driver d = null;
        while(drivers.hasMoreElements()) {
            try {
                d = drivers.nextElement();
                DriverManager.deregisterDriver(d);
                logger.warning(String.format("Driver %s deregistered", d));
            } catch (SQLException ex) {
                logger.warning(String.format("Error deregistering driver %s: %s", d, ex.getMessage()));
            }
        }
        try {
            AbandonedConnectionCleanupThread.shutdown();
        } catch (InterruptedException e) {
            logger.warning("SEVERE problem cleaning up: " + e.getMessage());
            e.printStackTrace();
        }
     }
    
    
}