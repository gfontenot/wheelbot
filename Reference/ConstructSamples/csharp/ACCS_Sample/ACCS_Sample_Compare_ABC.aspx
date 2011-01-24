<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ACCS_Sample_Compare_ABC.aspx.cs" Inherits="ACCS_Sample_Compare_ABC" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    //get attributes
    AdvantageBasedComparison comparison = (AdvantageBasedComparison) Session[ "compareResult" ];
    AdvantageComparison[] styleComparisons = comparison.comparisons;
    String scratchListIds = (String)Session[ "scratchListIds" ];
    configcompare3.kp.chrome.com.Style pivotStyle = comparison.pivotConfiguration.style;

    Session.Remove("compareResult");
    Session.Remove("scratchListIds");
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
		<h1><img border="0" alt="Chrome" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Comparison Service&trade;</h1>
	</td></tr>
	<tr><td align="center"><h1 class="label">Advantage Based Comparison</h1></td></tr>
</table>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
	<!-- show stock photos -->
	<tr><td>&nbsp;</td>
    <td align="center"><img alt="photo" height="75px" width="150px" src="<%=pivotStyle.stockPhotoUrl%>"></td>
<%
	foreach( AdvantageComparison comparisonItem in styleComparisons ) 
    {
        String photoUrl = comparisonItem.comparisonConfiguration.style.stockPhotoUrl;
%>
		<td align="center"><img alt="photo" height="75px" width="150px" src="<%=photoUrl%>"></td>
<%
	}
%>
	</tr>
	<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<%
	String primaryDescription = pivotStyle.modelYear + " " + pivotStyle.divisionName + " " + pivotStyle.modelName + " " + pivotStyle.styleName;
%>
    <td align="center"><%=primaryDescription%></td>
<%
    foreach( AdvantageComparison comparisonItem in styleComparisons ) 
    {
        configcompare3.kp.chrome.com.Style compareStyle = comparisonItem.comparisonConfiguration.style;
		String description = compareStyle.modelYear + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName;
%>
		<td align="center"><%=description%></td>
<%
	}
%>
	</tr>

	<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
    <td align="center"><%="$" + pivotStyle.baseInvoice.ToString() + " / " + "$" + pivotStyle.baseMsrp.ToString()%></td>
<%
    foreach (AdvantageComparison comparisonItem in styleComparisons)
    {
        configcompare3.kp.chrome.com.Style comparisonStyle = comparisonItem.comparisonConfiguration.style;
		String prices = "$" + comparisonStyle.baseInvoice.ToString() + " / " + "$" + comparisonStyle.baseMsrp.ToString();
%>
		<td align="center"><%=prices%></td>
<%
	}
%>
	</tr>

	<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
        <td align="center"><%="$" + pivotStyle.destination.ToString() %></td>
<%
	foreach( AdvantageComparison comparisonItem in styleComparisons ) 
    {
        configcompare3.kp.chrome.com.Style comparisonStyle = comparisonItem.comparisonConfiguration.style;
		String destinationCharge = "$" + comparisonStyle.destination.ToString();
%>
		<td align="center"><%=destinationCharge%></td>
<%
	}
%>
	</tr>
	<tr>
		<td align="center"><b>Select Primary</b></td>
        <td align="center"><input type="radio" name="primaryButton" checked></td>
<%
	for( int i = 0; i < styleComparisons.Length; i++ ) 
    {
%>
        <td align="center"><input type="radio" name="primaryButton"></td>
<%
	}
%>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center"><input type="button" name="newABC_Compare" value="Compare" onclick='doNewABC_Compare("<%=scratchListIds%>")'></td></tr>
</table>
<div id="pleaseWaitMsgDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%" align="center">Retrieving Data...Please Wait</td></tr></table>
</div>
<br>
<!-- show advantages -->
<a name="advantages"/><h3 class="label">ADVANTAGES</h3>
<%
    for( int compareIndex = 0; compareIndex < comparison.comparisons.Length; compareIndex++ )
    {
        AdvantageComparison styleComparison = comparison.comparisons[compareIndex];
        configcompare3.kp.chrome.com.Style compareStyle = styleComparison.comparisonConfiguration.style;
        String compareDescription = compareStyle.modelYear + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName;
%>
<b>The <%=primaryDescription%> has the following advantages over the <%=compareDescription%>:</b>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        AdvantageComparisonItem[] comparisonItems = styleComparison.comparisonItems;
        foreach (AdvantageComparisonItem item in comparisonItems) 
        {
            String resultType = item.comparisonResultType.ToString();
            if( String.Compare( resultType,  "Advantage", true ) == 0 ) 
            {
                String naturalLanguage = item.naturalLanguageDescription;
%>
    			<tr><td align="left"><%=naturalLanguage%></td></tr>

<%
	    	}
        }
%>
</table>
<br>
<%
    }
%>
<br>
<!-- show disadvantages -->
<a name="disadvantages"/><h3 class="label">DISADVANTAGES</h3>
<%
    for( int compareIndex = 0; compareIndex < comparison.comparisons.Length; compareIndex++ )
    {
        AdvantageComparison styleComparison = comparison.comparisons[compareIndex];
        configcompare3.kp.chrome.com.Style compareStyle = styleComparison.comparisonConfiguration.style;
        String compareDescription = compareStyle.modelYear + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName;
%>
<b>The <%=primaryDescription%> has the following disadvantages as compared to the <%=compareDescription%></b>:
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        AdvantageComparisonItem[] comparisonItems = styleComparison.comparisonItems;
        foreach( AdvantageComparisonItem item in comparisonItems ) 
        {
            String resultType = item.comparisonResultType.ToString();
            if( String.Compare( resultType, "Disadvantage", true ) == 0 ) 
            {
                String naturalLanguage = item.naturalLanguageDescription;
%>
    			<tr><td align="left"><%=naturalLanguage%></td></tr>
<%
		    }
	    }
%>
</table>
<br>
<%
    }
%>
<a href="ACCS_Sample_Selector.aspx"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_Search.aspx"><b>Return to Search</b></a><br>
</body>
</html>
