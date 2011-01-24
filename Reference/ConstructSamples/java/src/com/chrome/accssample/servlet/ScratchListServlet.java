package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * User: joe.fouts
 * Date: May 25, 2007
 * Time: 2:27:36 PM
 */
public class ScratchListServlet extends AccsServlet {

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException {

        response.setContentType( "text/html" );
        HttpSession session = request.getSession();

        if( request.getParameter( "cmd" ).equals( "add" ) ){
            String result = "fail";
            try{
                String styleId = request.getParameter( "styleId" );
                AccountInfo accountInfo = (AccountInfo )session.getAttribute( "configAccountInfo" );
                OrderAvailability orderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );
                AutomotiveConfigCompareService3Port configService = getConfigCompareService();
                Configuration config = configService.getConfigurationByStyleId( accountInfo, orderAvailability, Integer.parseInt( styleId ), new ReturnParameters() );
                String scratchListId = styleId + "|" + System.currentTimeMillis();
                session.setAttribute( scratchListId, config.getStyle().getConfigurationState() );
                result = scratchListId;
            } catch( Exception e ){
                e.printStackTrace();
            } finally {
                PrintWriter out = response.getWriter();
                out.print( result );
            }
        }
        
        if( request.getParameter( "cmd" ).equals( "remove" ) ){
            String result = "fail";
            try{
                String scratchListId = request.getParameter( "scratchListId" );
                session.removeAttribute( scratchListId );
                result = "success";
            } catch( Exception e ){
                e.printStackTrace();
            } finally {
                PrintWriter out = response.getWriter();
                out.print( result );
            }
        }
    }

}
