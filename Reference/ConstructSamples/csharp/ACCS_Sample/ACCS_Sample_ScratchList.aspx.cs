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

public partial class ACCS_Sample_ScratchList : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 configService = new AutomotiveConfigCompareService3();
    protected String result = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        String cmd = Request.QueryString["cmd"];

        result = "fail";
        switch( cmd )
        {
            case "add":
            {
                String styleId = Request.QueryString[ "styleId" ];
                AccountInfo accountInfo = (AccountInfo )Session[ "configAccountInfo" ];
                OrderAvailability orderAvailability = (OrderAvailability)Session[ "configOrderAvailability" ];

                ConfigurationByStyleIdRequest styleRequest = new ConfigurationByStyleIdRequest();
                styleRequest.accountInfo = accountInfo;
                styleRequest.orderAvailability = orderAvailability;
                styleRequest.styleId = Int32.Parse(styleId);
                styleRequest.returnParameters = new ReturnParameters();

                configcompare3.kp.chrome.com.Configuration config = configService.getConfigurationByStyleId( styleRequest ).configuration;
                String scratchListId = styleId + "|" + DateTime.Now.ToBinary().ToString();
                Session[scratchListId] = config.style.configurationState;
                result = scratchListId;
            }
            break;

            case "remove":
            {

                String scratchListId = Request.QueryString[ "scratchListId" ];
                Session.Remove( scratchListId );
                result = "success";
            }
            break;
        }
    }
}
