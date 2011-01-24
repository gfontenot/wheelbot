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

public partial class ACCS_Sample_Selector_Data : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 configService = new AutomotiveConfigCompareService3();
    protected const String accountNumber = "0";
    protected const String accountSecret = "accountSecret";
    protected String result = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        String dataRequest = Request.QueryString["data"];

        switch( dataRequest ) 
        {
            case "locale":
                {
                    setAccountInfo(Request.QueryString["locale"]);
                    break;
                }
            case "orderAvailability":
                {
                    String orderAvailabilityQuery = Request.QueryString["orderAvailability"];
                    if (orderAvailabilityQuery == "Fleet")
                    {
                        Session["configOrderAvailability"] = OrderAvailability.Fleet;
                        Session["compareOrderAvailability"] = configcompare3.kp.chrome.com.OrderAvailability.Fleet;
                    }
                    else
                    {
                        Session["configOrderAvailability"] = OrderAvailability.Retail;
                        Session["compareOrderAvailability"] = configcompare3.kp.chrome.com.OrderAvailability.Retail;
                    }
                    break;
                }
            case "years":
                {
                    int[] modelYears = getModelYears();
                    for (int i = 0; i < modelYears.Length; i++)
                    {
                        if (i > 0)
                            result += ";;";

                        result += modelYears[i] + "~~" + modelYears[i];
                    }
                    break;
                }
            case "divisions":
                {
                    String modelYear = Request.QueryString["modelYear"];

                    Division[] divisions = getDivisions(Int32.Parse(modelYear));

                    for (int i = 0; i < divisions.Length; i++)
                    {
                        int divisionId = divisions[i].divisionId;
                        String divisionName = divisions[i].divisionName;
                        if (i > 0)
                            result += ";;";

                        result += divisionId + "~~" + divisionName;
                    }
                    break;
                }
            case "models":
                {
                    String modelYear = (String)Request.QueryString["modelYear"];
                    String divisionId = (String)Request.QueryString["divisionId"];

                    Model[] models = getModels(Int32.Parse(modelYear), Int32.Parse(divisionId));

                    for (int i = 0; i < models.Length; i++)
                    {
                        String modelName = models[i].modelName;
                        int modelId = models[i].modelId;
                        if (i > 0)
                            result += ";;";
                        
                        result += modelName + "~~" + modelId;
                    }
                    break;
                }

            case "styles":
                {
                    String modelYear = Request.QueryString["modelYear"];
                    String divisionName = Request.QueryString["divisionName"];
                    String modelId = Request.QueryString["modelId"];
                    String modelName = Request.QueryString["modelName"];

                    configcompare3.kp.chrome.com.Style[] styles = getStyles(Int32.Parse(modelId));

                    for(int i = 0; i < styles.Length; i++)
                    {
                        configcompare3.kp.chrome.com.Style style = styles[i];
                        String invoice = "";
                        String msrp = "";

                        invoice = "$" + style.baseInvoice.ToString();
                        msrp = "$" + style.baseMsrp.ToString();

                        if (i > 0)
                            result += ";;";
                        
                        result += modelYear + "~~" + divisionName + "~~" + modelName + "~~" + style.styleName + "~~" + invoice + "~~" + msrp + "~~" + style.styleId;
                    }

                    break;
                }
        }
    }

    private void setAccountInfo(String localeString)
    {
        String country = "US";
        String language = "en";

        if (localeString == "enCA")
            country = "CA";
        else if (localeString == "frCA")
        {
            country = "CA";
            language = "fr";
        }

        Locale configLocale = new Locale();
        configLocale.country = country;
        configLocale.language = language;

        configcompare3.kp.chrome.com.Locale compareLocale = new configcompare3.kp.chrome.com.Locale();
        compareLocale.country = country;
        compareLocale.language = language;

        //set config accountInfo
        AccountInfo configAccountInfo = new AccountInfo();
        configAccountInfo.accountNumber = accountNumber;
        configAccountInfo.accountSecret = accountSecret;
        configAccountInfo.locale = configLocale;
        Session["configAccountInfo"] = configAccountInfo;

        //set compare accountInfo
        configcompare3.kp.chrome.com.AccountInfo compareAccountInfo = new configcompare3.kp.chrome.com.AccountInfo();
        compareAccountInfo.accountNumber = accountNumber;
        compareAccountInfo.accountSecret = accountSecret;
        compareAccountInfo.locale = compareLocale;
        Session["compareAccountInfo"] = compareAccountInfo;
    }

    private int[] getModelYears()
    {
        AccountInfo accountInfo = (AccountInfo)Session["configAccountInfo"];
        OrderAvailability orderAvailability = (OrderAvailability)Session["configOrderAvailability"];

        ModelYearsRequest modelYearsRequest = new ModelYearsRequest();
        modelYearsRequest.accountInfo = accountInfo;
        modelYearsRequest.filterRules = getFilterRules( orderAvailability );

        int[] modelYears = configService.getModelYears(modelYearsRequest);

        return modelYears;
    }

    private Division[] getDivisions(int modelYear)
    {
        AccountInfo accountInfo = (AccountInfo)Session["configAccountInfo"];
        OrderAvailability orderAvailability = (OrderAvailability)Session["configOrderAvailability"];

        DivisionsRequest divisionsRequest = new DivisionsRequest();
        divisionsRequest.accountInfo = accountInfo;
        divisionsRequest.filterRules = getFilterRules(orderAvailability);
        divisionsRequest.modelYear = modelYear;

        Division[] divisions = configService.getDivisions(divisionsRequest);

        return divisions;
    }

    private Model[] getModels(int modelYear, int divisionID)
    {
        AccountInfo accountInfo = (AccountInfo)Session["configAccountInfo"];
        OrderAvailability orderAvailability = (OrderAvailability)Session["configOrderAvailability"];

        ModelsByDivisionRequest modelsRequest = new ModelsByDivisionRequest();
        modelsRequest.accountInfo = accountInfo;
        modelsRequest.filterRules = getFilterRules(orderAvailability);
        modelsRequest.modelYear = modelYear;
        modelsRequest.divisionId = divisionID;

        Model[] models = configService.getModelsByDivision(modelsRequest);

        return models;
    }

    private configcompare3.kp.chrome.com.Style[] getStyles(int modelId)
    {
        AccountInfo accountInfo = (AccountInfo)Session["configAccountInfo"];
        OrderAvailability orderAvailability = (OrderAvailability)Session["configOrderAvailability"];

        StylesRequest stylesRequest = new StylesRequest();
        stylesRequest.accountInfo = accountInfo;
        stylesRequest.filterRules = getFilterRules(orderAvailability);
        stylesRequest.modelId = modelId;

        configcompare3.kp.chrome.com.Style[] styles = configService.getStyles(stylesRequest);

        return styles;
    }

    private configcompare3.kp.chrome.com.FilterRules getFilterRules(OrderAvailability orderAvailability) {
        FilterRules filterRules = new FilterRules();
        filterRules.orderAvailability = orderAvailability;
        return filterRules;
    }
}