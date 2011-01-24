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
using System.IO;

using configcompare3.kp.chrome.com;

public partial class ACCS_Sample_Config_New : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 configService = new AutomotiveConfigCompareService3();
    protected String result = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        AccountInfo accountInfo = (AccountInfo)Session["configAccountInfo"];
        OrderAvailability orderAvailability = (OrderAvailability)Session["configOrderAvailability"];

        //load saved style or get from session
        ConfigurationState configState = null;
        String scratchListId = Request.QueryString["scratchListId"];
        if (scratchListId == "none" )
        {
            String filePathAndName = Request.QueryString[ "filePathAndName" ];
            configState = loadSavedState(accountInfo, filePathAndName);
        }
        else
        {
            configState = (ConfigurationState)Session[ scratchListId ];
        }

        // do checklist
        FullyConfiguredRequest configRequest = new FullyConfiguredRequest();
        configRequest.accountInfo = accountInfo;
        configRequest.configurationState = configState;
        configRequest.returnParameters = null;

        ToggleOptionResponse toggleResponse = configService.getStyleFullyConfigured( configRequest );
        configcompare3.kp.chrome.com.Configuration configStyle = toggleResponse.configuration;

        // save fully configured
        Session[scratchListId] = configStyle.style.configurationState;

        // show config page
        Session[ "configStyle" ] = configStyle;
    }

    private ConfigurationState loadSavedState(AccountInfo accountInfo, String filePathAndName)
	{	
        StreamReader file = File.OpenText( filePathAndName );
        String serializedStyleState = file.ReadToEnd();
        file.Close();
		
		//get styleState
		ConfigurationStateRequest stateRequest = new ConfigurationStateRequest();
		stateRequest.accountInfo = accountInfo;
		stateRequest.serializedValue = serializedStyleState;

        ConfigurationStateElement configState = configService.materializeConfigurationState( stateRequest );
        
		return configState.configurationState;
	}
}