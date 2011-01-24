package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import javax.servlet.RequestDispatcher;
import java.io.IOException;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: gene.nguyen
 * Date: Apr 18, 2007
 * Time: 10:56:02 AM
 */

public class CompareAdvantageServlet extends AccsServlet {

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException {

        HttpSession session = request.getSession();

		//get service
		AutomotiveConfigCompareService3Port compareService = getConfigCompareService();

		// get account info
		AccountInfo accountInfo = (AccountInfo)session.getAttribute( "compareAccountInfo" );

		//get ids
		String primaryScratchListId = request.getParameter("primaryScratchListId");
        ConfigurationState primaryStyleState = (ConfigurationState) session.getAttribute( primaryScratchListId );

        //get configurationState for each id
        String[] scratchListIds = request.getParameter("scratchListIds").split("~~");
        ArrayList comparisonStateList = new ArrayList();
        for (int i = 0; i < scratchListIds.length; i++) {
            ConfigurationState chromeStyleState = (ConfigurationState) session.getAttribute( scratchListIds[i] );
            comparisonStateList.add( chromeStyleState );
		}

        ConfigurationState[] compareStates = (ConfigurationState[]) comparisonStateList.toArray( new ConfigurationState[comparisonStateList.size()] );

        //finally, do advantage based compare
		AdvantageBasedComparison advantageCompareResult = compareService.compareAdvantages( accountInfo, "chromerules",
                primaryStyleState, compareStates, new ReturnParameters() );
		request.setAttribute( "compareResult", advantageCompareResult );
        request.setAttribute( "scratchListIds", primaryScratchListId + "~~" + request.getParameter("scratchListIds") );

        RequestDispatcher dispatch = request.getRequestDispatcher( "ACCS_Sample_CompareABC.jsp" );
		dispatch.forward( request, response );
	}
}
