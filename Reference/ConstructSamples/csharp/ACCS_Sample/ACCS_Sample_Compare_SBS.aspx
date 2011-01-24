<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ACCS_Sample_Compare_SBS.aspx.cs" Inherits="ACCS_Sample_Compare_SBS" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    //get attributes and remove them from the session
    configcompare3.kp.chrome.com.Configuration[] comparisonConfigurations = (configcompare3.kp.chrome.com.Configuration[])Session["comparisonConfigurations"];
    SideBySideComparisonGroup[] comparisonGroups = (SideBySideComparisonGroup[])Session[ "comparisonGroups" ];

    Session.Remove("comparisonConfigurations");
    Session.Remove("comparisonGroups");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<title>Chrome Automotive Comparison Service&trade;</title>
<style type="text/css">
body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	margin-right: 5%;
	margin-left: 5%;
}
.label {
	color: #326BAD;
}
</style>
<script type="text/javascript" src="compare.js"></script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td align="center">
		<h1><img alt="Chrome" border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Comparison Service&trade;</h1>
	</td></tr>
	<tr><td align="center"><h1 class="label">Side By Side Comparison</h1></td></tr>
</table>
<!-- show links -->
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<%
	foreach( SideBySideComparisonGroup group in comparisonGroups ) 
    {
		String groupName = group.groupName;
		String href = "#" + groupName + "Href";
%>
	<tr><td><a href="<%=href%>" id="<%=groupName%>" onclick="showOrHideGroup(this.id)"><b>Show <%=groupName%></b></a></td></tr>
<%
	}
%>
</table>
<br>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<!-- show stock photos -->
	<tr>
		<td width="250px">&nbsp;</td>
<%
    foreach (configcompare3.kp.chrome.com.Configuration compareConfiguration in comparisonConfigurations)
    {
        configcompare3.kp.chrome.com.Style compareStyle = compareConfiguration.style;
		String photoUrl = compareStyle.stockPhotoUrl;
%>
		<td align="center" width="350px"><img alt="photo" height="75px" width="150px" src="<%=photoUrl%>"></td>
<%
	}
%>
	</tr>
<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<%
    foreach (configcompare3.kp.chrome.com.Configuration compareConfiguration in comparisonConfigurations)
    {
        configcompare3.kp.chrome.com.Style compareStyle = compareConfiguration.style;
		String description = compareStyle.modelYear + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName;
%>
		<td align="center"><%=description%></td>
<%
	}
%>
	</tr>
<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
<%
    foreach (configcompare3.kp.chrome.com.Configuration compareConfiguration in comparisonConfigurations)
    {
        configcompare3.kp.chrome.com.Style compareStyle = compareConfiguration.style;
		String prices = "$" + compareStyle.baseInvoice.ToString() + " / " + "$" + compareStyle.baseMsrp.ToString() ;
%>
		<td align="center"><%=prices%></td>
<%
	}
%>
	</tr>

<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
<%
    foreach (configcompare3.kp.chrome.com.Configuration compareConfiguration in comparisonConfigurations)
    {
        configcompare3.kp.chrome.com.Style compareStyle = compareConfiguration.style;
		String destinationCharge = "$" + compareStyle.destination.ToString();
%>
		<td align="center"><%=destinationCharge%></td>
<%
	}
%>
	</tr>
</table>
<br>
<!-- Show Categories -->
<%
    foreach (SideBySideComparisonGroup group in comparisonGroups )
    {
        String groupName = group.groupName;
		String divName = groupName + "Div";
		String hrefName = groupName + "Href";
%>
		<div id="<%=divName%>" style="display:none;visibility:hidden">
			<a name="<%=hrefName%>"/>
			<h3 class="label"><%=groupName.ToUpper()%></h3>
			<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
		foreach( SideBySideComparisonGroupItem item in group.comparisonItems ) 
        {
            String featureDescription = item.featureDescription;
            String[] comparisonValues = item.comparisonValues;
%>
			<tr><td align="center" width="250px"><b><%=featureDescription%></b></td>
<%
			for( int k = 0; k < comparisonConfigurations.Length; k++) {
				String value = comparisonValues[k];
				if ( value == null || value.Length < 1 )
					value = "&nbsp;";
%>
			<td align="center" width="350px"><%=value%></td>
<%
			}
%>
			</tr>
<%
		}
%>
			</table><br>
		</div>
<%
	}
%>
<!-- show warranty -->
<h3 class="label">WARRANTY</h3>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
	<tr>
		<td align="center" width="250px"><b>Warranty</b></td>
<%
    for( int i = 0; i < comparisonConfigurations.Length; i++) {
        String warranty = comparisonConfigurations[i].consumerInformation.warranty;
%>
		<td align="center"><%=warranty%></td>
<%
	}
%>
	</tr>
</table>
<br>
<a href="ACCS_Sample_Selector.aspx"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_Search.aspx"><b>Return to Search</b></a><br>
</body>
</html>
