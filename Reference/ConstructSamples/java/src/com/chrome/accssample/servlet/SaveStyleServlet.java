package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.AutomotiveConfigCompareService3Port;
import com.chrome.kp.configcompare3.ConfigurationState;
import com.chrome.kp.configcompare3.Configuration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import java.io.IOException;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;

/**
 * Created by IntelliJ IDEA.
 * User: gene.nguyen
 * Date: May 31, 2007
 * Time: 3:29:07 PM
 * To change this template use File | Settings | File Templates.
 */
public class SaveStyleServlet extends AccsServlet {

	public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException {

        String result = "success";
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        //get style name
		String styleName = request.getParameter( "styleName" );

        String type = request.getParameter( "actionType" );
        if( type.equals( "add" ) )
        {
            FileWriter fileWriter = null;
            try
            {
                //make sure have write access to this dir
                String savedStylesDir = ".." + File.separator + "webapps" + File.separator +
                    request.getContextPath().substring( 1 ) + File.separator + "savedStyles";

                // get chrome style state and serialized style
                Configuration configStyle = (Configuration) session.getAttribute( "configStyle" );
                String serializedValue = configStyle.getStyle().getConfigurationState().getSerializedValue();

                if( !new File( savedStylesDir ).exists() )  {
                    new File( savedStylesDir ).mkdir();
                }
              
                //delete old style file
                File filePathAndName = new File( savedStylesDir, styleName + ".xml" );
                if( filePathAndName.exists() )
                    filePathAndName.delete();

                //save style to new file
                filePathAndName = new File( savedStylesDir, styleName + ".xml" );

                fileWriter = new FileWriter( filePathAndName );
                fileWriter.write( serializedValue );
            }
            catch( IOException io )
            {
                result = "failed";
            }
            finally
            {
                if( fileWriter != null )
                    fileWriter.close();
                out.write( result );
            }
        }
        else if( type.equals( "delete" ) )
        {
            try
            {
                File targetFile = new File( styleName );
                if( !targetFile.exists() || !targetFile.delete() )
                    result = "failed";
            }
            catch( SecurityException se )
            {
                result = "failed";
            }
            finally
            {
                out.write( result );
            }
        }
    }
}
