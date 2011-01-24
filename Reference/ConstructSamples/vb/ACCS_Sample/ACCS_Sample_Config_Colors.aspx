<%@ Page Language="VB" AutoEventWireup="true" CodeFile="ACCS_Sample_Config_Colors.aspx.vb" Inherits="ACCS_Sample_Config_Colors" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    dim configStyle as configcompare3.kp.chrome.com.Configuration = Session("configStyle")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Available Colors</title>
</head>
<body>
<label style="color:#326BAD; font-size:large">Available Color Combinations</label><br/><br/>
<%
    ' for each color combination, get same exterior color combo and store in hash
    dim colorsHash as Hashtable = new Hashtable
    dim colorCombinations as ColorCombination() = configStyle.colorCombinations
    dim colorCombination as ColorCombination
    for each colorCombination in colorCombinations 
    
        dim exteriorKey as String = colorCombination.primaryExteriorColor.name + " (" + colorCombination.primaryExteriorColor.manufacturersCode + ")~"
        if( not colorCombination.primaryExteriorColor.swatchUrl is nothing )
            exteriorKey += colorCombination.primaryExteriorColor.swatchUrl
        end if
        exteriorKey += "~"
        if( not colorCombination.primaryExteriorColor.rgbHexCode is nothing )
            exteriorKey += colorCombination.primaryExteriorColor.rgbHexCode
        end if
            
        dim interiorColorName as String = colorCombination.interiorColor.name + " (" + colorCombination.interiorColor.manufacturersCode + ")"
        dim interiorColorsList as ArrayList = new ArrayList
        if (colorsHash.ContainsKey(exteriorKey))
        
            interiorColorsList = colorsHash(exteriorKey)

            ' remove old arraylist group
            colorsHash.Remove(exteriorKey)
        end if
            
        interiorColorsList.Add(interiorColorName)
        colorsHash.Add(exteriorKey, interiorColorsList)
    next colorCombination

    ' now show colors
    dim de as DictionaryEntry
    for each de in colorsHash
    
        dim exteriorKey as String = de.Key
        dim arrayValues as String() = Split( exteriorKey, "~" )
        dim exteriorName as String = arrayValues(0)
        dim exteriorMedia as String = arrayValues(1)
        Dim exteriorColorRgb As String = arrayValues(2)

        dim interiorColorList as ArrayList= de.Value
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
                dim interiorColor as String
                for each interiorColor in interiorColorList 
%>
                    <tr>
                        <td align="center"><%=interiorColor%></td>
                    </tr>
<%                   
                next interiorColor
%>        
            </table>
        </td>
    </tr>
</table>
<br />
<%        
    next de
%>
<input type="button" value="Close Window" onclick="window.close()"/>
</body>
</html>
