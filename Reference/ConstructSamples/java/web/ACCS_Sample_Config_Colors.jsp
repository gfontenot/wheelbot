<%@ page import="com.chrome.kp.configcompare3.*"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%
	Configuration configStyle = (Configuration)session.getAttribute( "configStyle" );
%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<title>Available Colors</title>
</head>
<body>
<label style="color:#326BAD; font-size:large">Available Color Combinations</label><br/><br/>
<%
	//for each color combination, get same exterior color combo and store in hash
	HashMap colorHash = new HashMap();
	for (int i = 0; i < configStyle.getColorCombinations().length; i++) {
		ColorCombination colorCombination = configStyle.getColorCombinations()[i];
		String exteriorColorKey = colorCombination.getPrimaryExteriorColor().getName() + " (" + colorCombination.getPrimaryExteriorColor().getManufacturersCode() + ")~";
        exteriorColorKey += (colorCombination.getPrimaryExteriorColor().getSwatchUrl() != null ? colorCombination.getPrimaryExteriorColor().getSwatchUrl() : "" ) + "~";
        exteriorColorKey += (colorCombination.getPrimaryExteriorColor().getRgbHexCode() != null ? colorCombination.getPrimaryExteriorColor().getRgbHexCode() : "" );

        String interiorColorName = colorCombination.getInteriorColor().getName();
		ArrayList exteriorColorList = (ArrayList) colorHash.get(exteriorColorKey);
		if( exteriorColorList == null ) exteriorColorList = new ArrayList();
		exteriorColorList.add(interiorColorName);
		colorHash.put(exteriorColorKey, exteriorColorList);
	}

	//now show colors
	Iterator iterator = colorHash.keySet().iterator();
	while (iterator.hasNext()) {
		String exteriorColorKey = iterator.next().toString();
		String exteriorColorName = exteriorColorKey.split( "~", -1 )[0];
		String exteriorColorMedia = exteriorColorKey.split( "~", -1 )[1];
		String exteriorColorRgb = exteriorColorKey.split( "~", -1 )[2];

		ArrayList interiorColors = (ArrayList)colorHash.get( exteriorColorKey );

%>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
    <tr><td align="center" style="width:30%"><b>Exterior Color</b></td><td align="center"><b>Interior Colors</b></td></tr>
    <tr>

        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="2">
                <tr><td align="center"><%=exteriorColorName%> <img alt="<%=exteriorColorName%>" width="10px" height="10px" src="<%=exteriorColorMedia%>"/></td></tr>
                <tr><td align="center" style="border: 1px solid black; background-color: #<%=exteriorColorRgb%>;">&nbsp;</td></tr>
            </table>
        </td>
        <td>
            <table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
                for( int j = 0; j < interiorColors.size(); j++ ){
%>
                    <tr><td align="center"><%=interiorColors.get(j).toString()%></td></tr>
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