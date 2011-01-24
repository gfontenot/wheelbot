package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;
import com.chrome.kp.configcompare3.AutomotiveConfigCompareService3Port;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import javax.servlet.RequestDispatcher;

/**
 * Created by IntelliJ IDEA.
 * User: gene.nguyen
 * Date: Apr 18, 2007
 * Time: 10:56:02 AM
 */

public class CompareSideBySideServlet extends AccsServlet {

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws ServletException {

        try{
            HttpSession session = request.getSession();

            //get service
            AutomotiveConfigCompareService3Port compareService = getConfigCompareService();

            // get attributes
            AccountInfo accountInfo = (AccountInfo)session.getAttribute( "compareAccountInfo" );
            String[] scratchListIds = request.getParameter("scratchListIds").split("~~");

            ConfigurationState[] allStyleStates = new ConfigurationState[ scratchListIds.length ];
            //get chromeStyleState for each id
            for (int i = 0; i < scratchListIds.length; i++) {
                ConfigurationState chromeStyleState = (ConfigurationState) session.getAttribute( scratchListIds[i] ); 
                allStyleStates[i] = chromeStyleState;
            }

            //get category Ids
            CategoryDefinition[] categoryDefinitions = compareService.getCategoryDefinitions( accountInfo );
            int[] categoryIds = new int[ categoryDefinitions.length ];
            for( int i = 0; i < categoryDefinitions.length; i++ ) {
                categoryIds[i] = categoryDefinitions[i].getCategoryId();
            }

            //get tech. specs Ids
            TechnicalSpecificationDefinition[] techSpecDefinitions = compareService.getTechnicalSpecificationDefinitions( accountInfo );
            int[] techSpecIds = new int[ techSpecDefinitions.length ];
            for( int i = 0; i < techSpecDefinitions.length; i++ ) {
                techSpecIds[i] = techSpecDefinitions[i].getTitleId();
            }

            ReturnParameters styleReturnParameters = new ReturnParameters();
            styleReturnParameters.setIncludeConsumerInfo( true );
            SideBySideComparison sideBySideComparisonResult = compareService.compareSideBySide(
                    accountInfo, allStyleStates, true, categoryIds, true, techSpecIds, styleReturnParameters );
            Configuration[] comparedConfigurations = sideBySideComparisonResult.getComparisonConfigurations();
            SideBySideComparisonGroup[] comparisonGroups = sideBySideComparisonResult.getComparisonGroups();

            request.setAttribute( "comparedConfigurations", comparedConfigurations );
            request.setAttribute( "comparisonGroups", comparisonGroups );

            RequestDispatcher dispatch = request.getRequestDispatcher( "ACCS_Sample_CompareSBS.jsp" );
            dispatch.forward( request, response );

        } catch( Exception e ){
            throw new ServletException(e);
        }
	}

}
