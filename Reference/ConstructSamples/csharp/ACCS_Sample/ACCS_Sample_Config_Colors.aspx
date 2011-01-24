<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ACCS_Sample_Config_Colors.aspx.cs" Inherits="ACCS_Sample_Config_Colors" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    configcompare3.kp.chrome.com.Configuration configStyle = (configcompare3.kp.chrome.com.Configuration)Session["configStyle"];
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Available Colors</title>
</head>
<body>
<label style="color:#326BAD; font-size:large">Available Color Combinations</label><br/><br/>
<%
    //for each color combination, get same exterior color combo and store in hash
    Hashtable colorsHash = new Hashtable();
    ColorCombination[] colorCombinations = configStyle.colorCombinations;
    foreach( ColorCombination colorCombination in colorCombinations )
    {
        String exteriorKey = colorCombination.primaryExteriorColor.name + " (" + colorCombination.primaryExteriorColor.manufacturersCode + ")~";
        exteriorKey += colorCombination.primaryExteriorColor.swatchUrl != null ? colorCombination.primaryExteriorColor.swatchUrl : "";
        exteriorKey += "~";
        exteriorKey += colorCombination.primaryExteriorColor.rgbHexCode != null ? colorCombination.primaryExteriorColor.rgbHexCode : "";
        
        String interiorColorName = colorCombination.interiorColor.name + " (" + colorCombination.interiorColor.manufacturersCode + ")";
        ArrayList interiorColorsList = new ArrayList();
        if (colorsHash.ContainsKey(exteriorKey))
        {
            interiorColorsList = (ArrayList)colorsHash[exteriorKey];

            //remove old arraylist group
            colorsHash.Remove(exteriorKey);
        }
        interiorColorsList.Add(interiorColorName);
        colorsHash.Add(exteriorKey, interiorColorsList);
    }

    //now show colors
    foreach (DictionaryEntry de in colorsHash)
    {
        String exteriorKey = (String)de.Key;
        String exteriorName = exteriorKey.Split('~')[0];
        String exteriorMedia = exteriorKey.Split('~')[1];
        String exteriorColorRgb = exteriorKey.Split('~')[2];

        ArrayList interiorColorList = (ArrayList)de.Value;
%>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
    <tr><td align="center" style="width:30%"><b>Exterior Color</b></td><td align="center"><b>Interior Colors</b></td></tr>
    <tr>
        
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="2">
                <tr><td align="center"><%=exteriorName%> <img alt="<%=exteriorName%>" width="10px" height="10px" src="<%=exteriorMedia%>"/></td></tr>
                <tr><td align="center" style="border: 1px solid black; background-color: #<%=exteriorColorRgb%>;">&nbsp;</td></tr>
            </table>
        </td>
        <td>
            <table width="100%" border="1" cellspacing="0" cellpadding="2">
<%            
                foreach( String interiorColor in interiorColorList )
                {
%>
                    <tr>
                        <td align="center"><%=interiorColor%></td>
                    </tr>
<%                   
                }
%>        
            </table>
        </td>
    </tr>
</table>
<br />
<%        
    }
%>
<input type="button" value="Close Window" onclick="window.close()">
</body>
</html>
