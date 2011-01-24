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

public partial class ACCS_Sample_Compare_SBS : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 compareService = new AutomotiveConfigCompareService3();

    protected void Page_Load(object sender, EventArgs e)
    {
        // get attributes
        AccountInfo accountInfo = (AccountInfo)Session[ "compareAccountInfo" ];
        String[] scratchListIds = Request.QueryString["scratchListIds"].Split(new String[] { "~~" }, StringSplitOptions.None );

        ConfigurationState[] allStyleStates = new ConfigurationState[scratchListIds.Length];
        
        //get configurationState for each id
        for (int i = 0; i < scratchListIds.Length; i++)
        {
            ConfigurationState chromeStyleState = (ConfigurationState)Session[ scratchListIds[i] ];
            allStyleStates[i] = chromeStyleState;
        }

        //get category Ids
        CategoryDefinitionsRequest catDefRequest = new CategoryDefinitionsRequest();
        catDefRequest.accountInfo = accountInfo;
        CategoryDefinition[] categoryDefinitions = compareService.getCategoryDefinitions(catDefRequest);
        int[] categoryIds = new int[categoryDefinitions.Length];
        for (int i = 0; i < categoryDefinitions.Length; i++)
        {
            categoryIds[i] = categoryDefinitions[i].categoryId;
        }

        //get tech. specs Ids
        TechnicalSpecificationDefinitionsRequest techSpecRequest = new TechnicalSpecificationDefinitionsRequest();
        techSpecRequest.accountInfo = accountInfo;
        TechnicalSpecificationDefinition[] techSpecDefinitions = compareService.getTechnicalSpecificationDefinitions(techSpecRequest);
        int[] techSpecIds = new int[techSpecDefinitions.Length];
        for (int i = 0; i < techSpecDefinitions.Length; i++)
        {
            techSpecIds[i] = techSpecDefinitions[i].titleId;
        }

        SideBySideComparisonRequest sbsRequest = new SideBySideComparisonRequest();
        sbsRequest.accountInfo = accountInfo;
        sbsRequest.comparisonConfigurationStates = allStyleStates;
        sbsRequest.includeCategoryComparisons = true;
        sbsRequest.filteredCategoryIds = categoryIds;
        sbsRequest.includeTechSpecComparisons = true;
        sbsRequest.filteredTechSpecTitleIds = techSpecIds;
        SideBySideComparison sideBySideComparisonResult = compareService.compareSideBySide(sbsRequest);
        configcompare3.kp.chrome.com.Configuration[] comparisonConfigurations = sideBySideComparisonResult.comparisonConfigurations;
        SideBySideComparisonGroup[] comparisonGroups = sideBySideComparisonResult.comparisonGroups;

        Session["comparisonConfigurations"] = comparisonConfigurations;
        Session["comparisonGroups"] = comparisonGroups;
    }
}
