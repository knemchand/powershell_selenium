package com.mycompany.app;

import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.lang.StringBuilder;
import java.net.BindException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.concurrent.TimeUnit;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.HttpResponse;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHttpEntityEnclosingRequest;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.openqa.selenium.By;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.Dimension;
// import org.openqa.selenium.firefox.ProfileManager;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.firefox.internal.ProfilesIni;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.Platform;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.HttpCommandExecutor;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import org.testng.annotations.*;
import org.testng.*;

public class AppTest // extends BaseTest
//
{ // http://www.programcreek.com/java-api-examples/index.php?api=org.testng.ITestContext
public RemoteWebDriver driver = null;
@Test(description="Finds a cruise")
public void test1() throws InterruptedException {

	driver.get("http://m.carnival.com/");
	WebDriverWait wait = new WebDriverWait(driver, 30);
	String value1 = null;

	wait.until(ExpectedConditions.visibilityOfElementLocated(By.className("ccl-logo")));
	value1 = "ddlDestinations";

	String xpath_selector1 = String.format("//select[@id='%s']", value1);
	wait.until(ExpectedConditions.elementToBeClickable(By.xpath(xpath_selector1)));
	WebElement element = driver.findElement(By.xpath(xpath_selector1));

	System.out.println( element.getAttribute("id"));
	Actions builder = new Actions(driver);
	builder.moveToElement(element).build().perform();

	String csspath_selector2 = "div.find-cruise-submit > a";
	WebElement element2 = driver.findElement(By.cssSelector(csspath_selector2));
	System.out.println( element2.getText());
	new Actions(driver).moveToElement(element2).click().build().perform();
	Thread.sleep(5000);

	//print the node information
	//String result = getIPOfNode(driver);
	//System.out.println(result);
}

@Test(description="Takes S screenshot - is actually a utility")
public void test2() throws InterruptedException {
	//take a screenshot
	//File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
	//save the screenshot in png format on the disk.
	//FileUtils.copyFile(scrFile, new File(System.getProperty("user.dir") + "\\screenshot.png"));
}

public String seleniumHost = null;
public String seleniumPort = null;

public String seleniumBrowser = null;
@AfterSuite(alwaysRun = true,enabled =true) 
public void cleanupSuite() {

	        System.out.println("testClass1.cleanupSuite: after suite");6
           driver.close();
           driver.quit();
	    }
@BeforeSuite(alwaysRun = true)
public void setupBeforeSuite( ITestContext context ) throws InterruptedException {
	DesiredCapabilities capabilities = DesiredCapabilities.firefox();


	seleniumHost = context.getCurrentXmlTest().getParameter("selenium.host");
	seleniumPort = context.getCurrentXmlTest().getParameter("selenium.port");
	seleniumBrowser = context.getCurrentXmlTest().getParameter("selenium.browser");

	capabilities =   new DesiredCapabilities(seleniumBrowser, "", Platform.ANY);
	FirefoxProfile profile = new ProfilesIni().getProfile("default");
	capabilities.setCapability("firefox_profile", profile);

	try {
		driver = new RemoteWebDriver(new URL("http://"+  seleniumHost  + ":" + seleniumPort   +  "/wd/hub"), capabilities);
	} catch (MalformedURLException ex) { }

	try{
		driver.manage().window().setSize(new Dimension(600, 800));
		driver.manage().timeouts().pageLoadTimeout(50, TimeUnit.SECONDS);
		driver.manage().timeouts().implicitlyWait(20, TimeUnit.SECONDS);
	}  catch(Exception ex) {
		System.out.println(ex.toString());
	}

}
private static String getIPOfNode(RemoteWebDriver remoteDriver)
{
	String hostFound = null;
	try  {
		HttpCommandExecutor ce = (HttpCommandExecutor) remoteDriver.getCommandExecutor();
		String hostName = ce.getAddressOfRemoteServer().getHost();
		int port = ce.getAddressOfRemoteServer().getPort();
		HttpHost host = new HttpHost(hostName, port);
		DefaultHttpClient client = new DefaultHttpClient();
		URL sessionURL = new URL(String.format("http://%s:%d/grid/api/testsession?session=%s", hostName, port, remoteDriver.getSessionId()));
		BasicHttpEntityEnclosingRequest r = new BasicHttpEntityEnclosingRequest( "POST", sessionURL.toExternalForm());
		HttpResponse response = client.execute(host, r);
		JSONObject object = extractObject(response);
		URL myURL = new URL(object.getString("proxyId"));
		if ((myURL.getHost() != null) && (myURL.getPort() != -1)) {
			hostFound = myURL.getHost();
		}
	} catch (Exception e) {
		System.err.println(e);
	}
	return hostFound;
}

private static JSONObject extractObject(HttpResponse resp) throws IOException, JSONException {
	InputStream contents = resp.getEntity().getContent();
	StringWriter writer = new StringWriter();
	IOUtils.copy(contents, writer, "UTF8");
	JSONObject objToReturn = new JSONObject(writer.toString());
	return objToReturn;
}
}


