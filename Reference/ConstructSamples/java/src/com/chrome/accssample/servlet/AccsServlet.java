package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import javax.xml.rpc.Stub;
import java.util.Properties;
import java.io.InputStream;

/**
 * User: joe.fouts
 * Date: May 21, 2007
 * Time: 2:20:24 PM
 */
public class AccsServlet extends HttpServlet {

    private static String defaultUrl = "http://platform.chrome.com/AutomotiveConfigCompareService/AutomotiveConfigCompareService3?WSDL";
    private static String defaultAccountNumber = "0";
    private static String defaultAccountSecret = "accountSecret";
    private static String defaultCountry = "US";
    private static String defaultLanguage = "en";
    private static AutomotiveConfigCompareService3Port SERVICE = null;
    private static OrderAvailability defaultOrderAvailability = OrderAvailability.Fleet;
    
    public static AutomotiveConfigCompareService3Port getConfigCompareService() throws ServletException {
        if( SERVICE == null ){
            try{
                Stub stub =  (Stub) (new AutomotiveConfigCompareService3_Impl().getAutomotiveConfigCompareService3Port() );
                stub._setProperty( javax.xml.rpc.Stub.ENDPOINT_ADDRESS_PROPERTY, getProperties().getProperty( "service.url", defaultUrl ) );
                SERVICE = (AutomotiveConfigCompareService3Port) stub;
            } catch( Exception e ){
                throw new ServletException(e);
            }
        }
        return SERVICE;
    }

    public static AccountInfo getAccountInfo( HttpSession session ) {
        AccountInfo info = (AccountInfo) session.getAttribute( "accountInfo");
        if( info == null ){
            Properties properties = getProperties();
            Locale locale = new Locale();
            locale.setCountry( defaultCountry );
            locale.setLanguage( defaultLanguage );
            info = new AccountInfo();
            info.setAccountNumber( properties.getProperty( "accountNumber", defaultAccountNumber ) );
            info.setAccountSecret( properties.getProperty( "accountSecret", defaultAccountSecret ) );
            info.setLocale( locale );
            session.setAttribute( "accountInfo", info );
        }
        return info;
    }

    public static OrderAvailability getOrderAvailability( HttpSession session ) {
        OrderAvailability  availability = (OrderAvailability) session.getAttribute( "orderAvailability" );
        if( availability == null ){
            availability = defaultOrderAvailability;
            session.setAttribute( "orderAvailability", availability );
        }
        return availability;
    }

    public static Properties getProperties() {
        Properties properties = new Properties();
        InputStream stream = AccsServlet.class.getClassLoader().getResourceAsStream( "AccsSample.properties" );
        if( stream != null ){
            try {
                properties.load( stream );
            } catch( Exception e ){
                e.printStackTrace();
            }
        }
        return properties;
    }
}
