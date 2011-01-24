package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import javax.servlet.RequestDispatcher;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.regex.Pattern;
import java.util.regex.Matcher;


/**
 * Created by IntelliJ IDEA.
 * User: gene.nguyen
 * Date: Apr 13, 2007
 * Time: 4:37:27 PM
 */
public class ConfigServlet extends AccsServlet {

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException {

        HttpSession session = request.getSession();

        AccountInfo accountInfo = (AccountInfo) session.getAttribute( "configAccountInfo" );

        // get service
		AutomotiveConfigCompareService3Port service = getConfigCompareService();

        //load saved style or get from session
		ConfigurationState configState = null;
		String scratchListId = request.getParameter( "scratchListId" );
		if ( scratchListId.equals( "none" ) )  {
			String filePathAndName = request.getParameter( "filePathAndName" );
			session.setAttribute( "configAccountInfo", accountInfo );
			configState = loadSavedState( service, accountInfo, filePathAndName );
		}
		else {
			configState = (ConfigurationState) session.getAttribute( scratchListId );
		}

        // do checklist
        ToggleOptionResponse toggleResponse = service.getStyleFullyConfigured( accountInfo, configState, null );
        Configuration configStyle = toggleResponse.getConfiguration();

        // save fully configured
        session.setAttribute( scratchListId, configStyle.getStyle().getConfigurationState() );

        // show config page
        session.setAttribute( "configStyle", configStyle );
		RequestDispatcher dispatch = request.getRequestDispatcher( "ACCS_Sample_Config.jsp" );
		dispatch.forward( request, response );
	}

    private ConfigurationState loadSavedState( AutomotiveConfigCompareService3Port service, AccountInfo accountInfo, String filePathAndName )
	{
		ConfigurationState configState = null;
		try {
			BufferedReader in = new BufferedReader(new FileReader( filePathAndName ) );
			String serializedStyleState = in.readLine();
			in.close();

			//get styleState
			ConfigurationStateRequest stateRequest = new ConfigurationStateRequest();
			stateRequest.setAccountInfo( accountInfo );
			stateRequest.setSerializedValue( serializedStyleState );

            configState = service.materializeConfigurationState( accountInfo, serializedStyleState );
        }
		catch( Exception e ) {}

		return configState;
	}
}