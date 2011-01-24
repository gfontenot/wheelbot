using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using configcompare3.kp.chrome.com;

public partial class ACCS_Sample_Config_ToggleOption : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 configService = new AutomotiveConfigCompareService3();
    protected String result = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        AccountInfo accountInfo = (AccountInfo)Session["configAccountInfo"];

		//get config style
        configcompare3.kp.chrome.com.Configuration configStyle = (configcompare3.kp.chrome.com.Configuration)Session["configStyle"];
		String originatingOptionCode = Request.QueryString[ "optionCode" ];

        ToggleOptionRequest toggleRequest = new ToggleOptionRequest();
        toggleRequest.accountInfo = accountInfo;
        toggleRequest.configurationState = configStyle.style.configurationState;
        toggleRequest.chromeOptionCode = originatingOptionCode;
        toggleRequest.returnParameters = null;

		ToggleOptionResponse optionToggleResponse = configService.toggleOption( toggleRequest );

		//save config style
        configcompare3.kp.chrome.com.Configuration newConfigStyle = optionToggleResponse.configuration;
		Session[ "configStyle" ] = newConfigStyle;

		//handle option conflict
		if( optionToggleResponse.requiresToggleToResolve ) 
        {
			result = "yesConflict~~";
			String conflictingOptionsAndDescs = "";

			//get conflicting option codes and descriptions
			String[] conflictingOptions = optionToggleResponse.conflictResolvingChromeOptionCodes;
			for (int i = 0; i < conflictingOptions.Length; i++) 
            {
				String conflictingOptionCode = conflictingOptions[i];
				if( i > 0 && i < conflictingOptions.Length )
					conflictingOptionsAndDescs += ";;";

				Option[] options = newConfigStyle.options;
				for (int j = 0; j < options.Length; j++) 
                {
					Option option = options[j];
					if( option.chromeOptionCode == conflictingOptionCode ) 
                    {
                        String optionName = "";
                        for( int k=0; k < option.descriptions.Length; k++ )
                        {
                            if( option.descriptions[k].type == OptionDescriptionType.PrimaryName )
                            {
                                optionName = option.descriptions[k].description;
                            }
                        }
                        conflictingOptionsAndDescs += conflictingOptionCode + "::" + optionName;
						break;
					}
				}
			}

			//get manufacturer code and description for originating option code
			String manuCodeAndDesc = "";
			for( int i = 0; i < newConfigStyle.options.Length; i++ ) 
            {
				Option option = newConfigStyle.options[i];
				if( String.Compare( option.chromeOptionCode, originatingOptionCode, true ) == 0 ) 
                {
                    String optionName = "";
                    for( int j=0; j < option.descriptions.Length; j++ )
                    {
                        if( option.descriptions[j].type == OptionDescriptionType.PrimaryName )
                        {
                            optionName = option.descriptions[j].description;
                        }
                    }
                    manuCodeAndDesc = option.oemOptionCode + ";;" + optionName;
					break;
				}
			}

            if (optionToggleResponse.originatingOptionAnAddition )
				result += manuCodeAndDesc + "~~add~~" + conflictingOptionsAndDescs;
			else
				result += manuCodeAndDesc + "~~delete~~" + conflictingOptionsAndDescs;
		}
        else if (!optionToggleResponse.requiresToggleToResolve )
        { //no option conflict
			result = "noConflict~~";
			//get all option codes and states
			String allOptionCodesAndStates = "";
			for( int i = 0; i < newConfigStyle.options.Length; i++ ) 
            {
				Option option = newConfigStyle.options[i];
				String optionCodeAndState = option.chromeOptionCode + "::" + option.selectionState;
				if( i > 0 && i < newConfigStyle.options.Length )
					allOptionCodesAndStates += ";;";

				allOptionCodesAndStates += optionCodeAndState;
			}

			//get new pricing
            String totalOptionsInvoice = newConfigStyle.configuredOptionsInvoice.ToString();
            String totalOptionsMsrp = newConfigStyle.configuredOptionsMsrp.ToString();

            String totalInvoice = newConfigStyle.configuredTotalInvoice.ToString();
            String totalMsrp = newConfigStyle.configuredTotalMsrp.ToString();

			result += allOptionCodesAndStates + "~~" + totalOptionsInvoice + "~~" + totalOptionsMsrp + "~~" + totalInvoice + "~~" + totalMsrp;;
		}

    }
}
