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

public partial class ACCS_Sample_Compare_ABC : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 compareService = new AutomotiveConfigCompareService3();

    protected void Page_Load(object sender, EventArgs e)
    {
        // get account info
        AccountInfo accountInfo = (AccountInfo)Session["compareAccountInfo"];

        //get ids
        String primaryScratchListId = Request.QueryString["primaryScratchListId"];
        ConfigurationState primaryStyleState = (ConfigurationState)Session[primaryScratchListId];

        //get configurationState for each id
        String[] scratchListIds = Request.QueryString["scratchListIds"].Split(new String[] { "~~" }, StringSplitOptions.None);
        ArrayList comparisonStateList = new ArrayList();
        for (int i = 0; i < scratchListIds.Length; i++)
        {
            ConfigurationState chromeStyleState = (ConfigurationState)Session[scratchListIds[i]];
            comparisonStateList.Add(chromeStyleState);
        }

        ConfigurationState[] compareStates = (ConfigurationState[])comparisonStateList.ToArray(new ConfigurationState().GetType());

        //finally, do advantage based compare
        AdvantageBasedComparisonRequest abcRequest = new AdvantageBasedComparisonRequest();
        abcRequest.accountInfo = accountInfo;
        abcRequest.ruleSetName = "chromerules";
        abcRequest.pivotConfigurationState = primaryStyleState;
        abcRequest.comparisonConfigurationStates = compareStates;

        AdvantageBasedComparison advantageCompareResult = compareService.compareAdvantages(abcRequest);
        Session["compareResult"] = advantageCompareResult;
        Session["scratchListIds"] = primaryScratchListId + "~~" + Request.QueryString["scratchListIds"];
    }
}
