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

public partial class ACCS_Sample_Save_Style : System.Web.UI.Page
{
    protected AutomotiveConfigCompareService3 configService = new AutomotiveConfigCompareService3();
    protected String result = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        result = "success";

        //get style name
		String styleName = Request.QueryString[ "styleName" ];

        String type = Request.QueryString[ "actionType" ];
        switch( type )
        {
            case "add":
            {
                try
                {
                    configcompare3.kp.chrome.com.Configuration configStyle = (configcompare3.kp.chrome.com.Configuration)Session["configStyle"];
                    String serializedState = configStyle.style.configurationState.serializedValue;

                    String path = @"C:\tmp\savedStyles\";

                    if (!Directory.Exists(path))
                    {
                        DirectoryInfo di = Directory.CreateDirectory(path);
                    }

                    //delete old file, then create new file
                    String filename = path + styleName + ".xml";
                    if (File.Exists(filename))
                    {
                        File.Delete(filename);
                    }

                    StreamWriter sw = File.CreateText(filename);
                    {
                        sw.WriteLine(serializedState);
                        sw.Close();
                    }
                }
                catch (IOException)
                {
                    result = "failed";
                }
            }
            break;
        
            case "delete":
            {
                try
                {
                    if (File.Exists(styleName))
                    {
                        File.Delete(styleName);
                    }
                }
                catch (IOException)
                {
                    result = "failed";
                }
            }
            break;
        }
    }
}