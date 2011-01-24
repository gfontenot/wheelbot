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
public class ToggleOptionServlet extends AccsServlet {

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException {
		response.setContentType( "text/html" );
		PrintWriter out = response.getWriter();

		HttpSession session = request.getSession();

		//get service
		AutomotiveConfigCompareService3Port configService = getConfigCompareService();

		// get account info
		AccountInfo accountInfo = (AccountInfo) session.getAttribute( "configAccountInfo" );

        String returnString = "";

		//get config style
		Configuration configStyle = (Configuration)session.getAttribute( "configStyle" );
		String originatingOptionCode = request.getParameter( "optionCode" );
		ToggleOptionResponse optionToggleResponse = configService.toggleOption( accountInfo,
                configStyle.getStyle().getConfigurationState(), originatingOptionCode, null, false );

		//save config style
		Configuration newConfigStyle = optionToggleResponse.getConfiguration();
		session.setAttribute( "configStyle", newConfigStyle );

		//handle option conflict
		if( optionToggleResponse.isRequiresToggleToResolve() ) {
			returnString = "yesConflict~~";
			String conflictingOptionsAndDescs = "";

			//get conflicting option codes and descriptions
			String[] conflictingOptions = optionToggleResponse.getConflictResolvingChromeOptionCodes();
			for (int i = 0; i < conflictingOptions.length; i++) {
				String conflictingOptionCode = conflictingOptions[i];
				if( i > 0 && i < conflictingOptions.length )
					conflictingOptionsAndDescs += ";;";

				Option[] options = newConfigStyle.getOptions();
				for (int j = 0; j < options.length; j++) {
					Option option = options[j];
					if( option.getChromeOptionCode().equals( conflictingOptionCode ) ) {
                        String optionName = "";
                        for( int k=0; k < option.getDescriptions().length; k++ ){
                            if( option.getDescriptions()[k].getType() == OptionDescriptionType.PrimaryName ){
                                optionName = option.getDescriptions()[k].getDescription();
                            }
                        }
                        conflictingOptionsAndDescs += conflictingOptionCode + "::" + optionName;
						break;
					}
				}
			}

			//get manufacturer code and description for originating option code
			String manuCodeAndDesc = "";
			for( int i = 0; i < newConfigStyle.getOptions().length; i++ ) {
				Option option = newConfigStyle.getOptions()[i];
				if( option.getChromeOptionCode().equalsIgnoreCase( originatingOptionCode ) ) {
                    String optionName = "";
                    for( int j=0; j < option.getDescriptions().length; j++ ){
                        if( option.getDescriptions()[j].getType() == OptionDescriptionType.PrimaryName ){
                            optionName = option.getDescriptions()[j].getDescription();
                        }
                    }
                    manuCodeAndDesc = option.getOemOptionCode() + ";;" + optionName;
					break;
				}
			}

			if( optionToggleResponse.isOriginatingOptionAnAddition() )
				returnString += manuCodeAndDesc + "~~add~~" + conflictingOptionsAndDescs;
			else
				returnString += manuCodeAndDesc + "~~delete~~" + conflictingOptionsAndDescs;

			out.print( returnString );
			return;
		}
		else if( !optionToggleResponse.isRequiresToggleToResolve() )  { //no option conflict
			returnString = "noConflict~~";
			//get all option codes and states
			String allOptionCodesAndStates = "";
			for( int i = 0; i < newConfigStyle.getOptions().length; i++ ) {
				Option option = newConfigStyle.getOptions()[i];
				String optionCodeAndState = option.getChromeOptionCode() + "::" + option.getSelectionState();
				if( i > 0 && i < newConfigStyle.getOptions().length )
					allOptionCodesAndStates += ";;";

				allOptionCodesAndStates += optionCodeAndState;
			}

			//get new pricing
			String totalOptionsInvoice = Double.toString( newConfigStyle.getConfiguredOptionsInvoice() );
			String totalOptionsMsrp = Double.toString( newConfigStyle.getConfiguredOptionsMsrp() );

			String totalInvoice = Double.toString( newConfigStyle.getConfiguredTotalInvoice() );
			String totalMsrp = Double.toString( newConfigStyle.getConfiguredTotalMsrp() );

			returnString += allOptionCodesAndStates + "~~" + totalOptionsInvoice + "~~" + totalOptionsMsrp + "~~" + totalInvoice + "~~" + totalMsrp;

			out.print( returnString );
			return;
		}
		else {
			System.out.println( "TOGGLE FAILED" );
		}
	}
}