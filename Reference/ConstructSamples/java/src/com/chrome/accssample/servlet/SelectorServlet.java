package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Created by IntelliJ IDEA.
 * User: gene.nguyen
 * Date: Apr 13, 2007
 * Time: 4:37:27 PM
 */
public class SelectorServlet extends AccsServlet {

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException {

		response.setContentType( "text/html" );
		PrintWriter out = response.getWriter();

		HttpSession session = request.getSession();

		//get config service
		AutomotiveConfigCompareService3Port configService = getConfigCompareService();

        //get data request type
		String selectorRequest = request.getParameter( "data" );
		String returnString = "";
		//============================================get Locale
		if( selectorRequest.equalsIgnoreCase( "locale" ) ) {
			//get config locale
			Locale configLocale = new Locale();
			configLocale.setCountry( "US" );
			configLocale.setLanguage( "en" );

			String queryLocale = request.getParameter( "locale" );
			if ( queryLocale.equalsIgnoreCase( "enCA" ) )  {
				configLocale.setCountry( "CA" );
				configLocale.setLanguage( "en" );
			}
			else if ( queryLocale.equalsIgnoreCase( "frCA" ) ) {
				configLocale.setCountry( "CA" );
				configLocale.setLanguage( "fr" );
			}

			// set accountInfo for config
			AccountInfo configAccountInfo = getAccountInfo( session );
			configAccountInfo.setLocale( configLocale );

			session.setAttribute( "configAccountInfo", configAccountInfo );

			// set accountInfo for compare
			Locale compareLocale = new Locale();
			compareLocale.setCountry( "US" );
			compareLocale.setLanguage( "en" );

			if ( queryLocale.equalsIgnoreCase( "enCA" ) )  {
				compareLocale.setCountry( "CA" );
				compareLocale.setLanguage( "en" );
			}
			else if ( queryLocale.equalsIgnoreCase( "frCA" ) ) {
				compareLocale.setCountry( "CA" );
				compareLocale.setLanguage( "fr" );
			}

			// get/set config account info
			AccountInfo compareAccountInfo = getAccountInfo( session );
			compareAccountInfo.setLocale( compareLocale );

			session.setAttribute( "compareAccountInfo", compareAccountInfo );
		}

		//============================================get orderAvailability
		if( selectorRequest.equalsIgnoreCase( "orderAvailability" ) ) {
			String orderAvailability = request.getParameter( "orderAvailability" );

			// get/set config orderAvailability
			OrderAvailability configOrderAvailability = OrderAvailability.Fleet;
			if( orderAvailability.equalsIgnoreCase( "Retail" ) )
				configOrderAvailability = OrderAvailability.Retail;

			session.setAttribute( "configOrderAvailability", configOrderAvailability );

			// get/set compare orderAvailability
			OrderAvailability compareOrderAvailability = OrderAvailability.Fleet;
			if( orderAvailability.equalsIgnoreCase( "Retail" ) )
				compareOrderAvailability = OrderAvailability.Retail;

			session.setAttribute( "compareOrderAvailability", compareOrderAvailability );
		}

		//============================================get ModelYears
		if( selectorRequest.equalsIgnoreCase( "years" ) ) {
			AccountInfo configAccountInfo = (AccountInfo)session.getAttribute( "configAccountInfo" );
			OrderAvailability configOrderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );

            FilterRules filterRules = createFilterRules( configOrderAvailability );
            int modelYears[] = configService.getModelYears( configAccountInfo, filterRules );

			for ( int i = 0; modelYears != null && i < modelYears.length; i++ ) {
				int year = modelYears[i];
				if ( i > 0 )
					returnString += ";;";

				returnString += year + "~~" + year;
			}
			out.print( returnString );
			return;
		}
		//============================================get Divisions
		if ( selectorRequest.equalsIgnoreCase( "divisions" ) ) {

			AccountInfo configAccountInfo = (AccountInfo)session.getAttribute( "configAccountInfo" );
			OrderAvailability configOrderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );

			String year = request.getParameter( "modelYear" );

            FilterRules filterRules = createFilterRules( configOrderAvailability );
            Division[] divisions = configService.getDivisions( configAccountInfo, Integer.parseInt( year ), filterRules );
			for ( int i = 0; divisions != null && i < divisions.length; i++ ) {
				int divisionId = divisions[i].getDivisionId();
				String divisionName = divisions[i].getDivisionName();
				if (i > 0) {
					returnString += ";;";
				}
				returnString += divisionId + "~~" + divisionName;
			}
			out.print( returnString );
			return;
		}
		//============================================get Models
		if ( selectorRequest.equalsIgnoreCase( "models" ) ) {

			AccountInfo configAccountInfo = (AccountInfo)session.getAttribute( "configAccountInfo" );
			OrderAvailability configOrderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );

			String year = request.getParameter( "modelYear" );
			String divisionId = request.getParameter( "divisionId" );

            FilterRules filterRules = createFilterRules( configOrderAvailability );
            Model[] models = configService.getModelsByDivision( configAccountInfo, Integer.parseInt( year ), Integer.parseInt( divisionId ), filterRules );

			for( int i = 0; models != null && i < models.length; i++ ) {
				String modelName = models[i].getModelName();
				int modelId = models[i].getModelId();
				if (i > 0) {
					returnString += ";;";
				}
				returnString += modelName + "~~" + modelId;
			}
			out.print( returnString );
			return;
		}

        if ( selectorRequest.equalsIgnoreCase( "cfmodelnames" ) ) {
            AccountInfo configAccountInfo = (AccountInfo)session.getAttribute( "configAccountInfo" );
			OrderAvailability configOrderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );

			String year = request.getParameter( "modelYear" );
			String divisionId = request.getParameter( "divisionId" );

            FilterRules filterRules = createFilterRules( configOrderAvailability );
            String[] cfModelNames = configService.getConsumerFriendlyModelNamesByDivision( configAccountInfo,
                    Integer.parseInt( year ), Integer.parseInt( divisionId ), filterRules );

			for( int i = 0; cfModelNames != null && i < cfModelNames.length; i++ ) {
				String modelName = cfModelNames[i];
				if (i > 0) {
					returnString += "~~";
				}
				returnString += modelName;
			}
			out.print( returnString );
			return;
        }

        if ( selectorRequest.equalsIgnoreCase( "stylesbycfmodelname" ) ) {

			AccountInfo configAccountInfo = (AccountInfo)session.getAttribute( "configAccountInfo" );
			OrderAvailability configOrderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );

			String year = request.getParameter( "modelYear" );
			int divisionId = Integer.parseInt( request.getParameter( "divisionId" ) );
			String cfModelName = request.getParameter( "cfModelName" );

            FilterRules filterRules = createFilterRules( configOrderAvailability );
            Style[] styles = configService.getStylesByConsumerFriendlyModelNameAndDivision( configAccountInfo,
                    Integer.parseInt(year), divisionId, cfModelName, filterRules );
            returnString = stylesToReturnString( styles );

			out.print( returnString );
			return;

        }

        //============================================get Styles
		if ( selectorRequest.equalsIgnoreCase( "styles" ) ) {

			AccountInfo configAccountInfo = (AccountInfo)session.getAttribute( "configAccountInfo" );
			OrderAvailability configOrderAvailability = (OrderAvailability)session.getAttribute( "configOrderAvailability" );
			
			int modelId = Integer.parseInt( request.getParameter( "modelId" ) );

            FilterRules filterRules = createFilterRules( configOrderAvailability );
            Style[] styles = configService.getStyles( configAccountInfo, modelId, filterRules );
            returnString = stylesToReturnString( styles );

			out.print( returnString );
			return;
		}
	}

    private String stylesToReturnString( Style[] styles ){

        String returnString = "";

        for( int i = 0; styles != null && i < styles.length; i++ ) {
            Style style = styles[i];
            String invoice = "";
            String msrp= "";
            invoice = "$" + Double.toString( style.getBaseInvoice() );
            msrp = "$" + Double.toString( style.getBaseMsrp() );
            if (i > 0) {
                returnString += ";;";
            }
            returnString += style.getModelYear() + "~~" + style.getDivisionName() + "~~" + style.getModelName() + "~~" + style.getStyleName() + "~~" + invoice + "~~" + msrp + "~~" + style.getStyleId();
            returnString += "~~" + style.getConsumerFriendlyModelName() + "~~" + style.getConsumerFriendlyStyleName();
            returnString += "~~" + style.getConsumerFriendlyBodyType() + "~~" + style.getConsumerFriendlyDrivetrain();
        }

        return returnString;
    }

    private FilterRules createFilterRules( OrderAvailability availability ){
        FilterRules filterRules = new FilterRules();
        filterRules.setOrderAvailability( availability );
        return filterRules;
    }

}
