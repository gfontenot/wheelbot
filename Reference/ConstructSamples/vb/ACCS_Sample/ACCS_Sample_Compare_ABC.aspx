<%@ Page Language="VB" AutoEventWireup="true" CodeFile="ACCS_Sample_Compare_ABC.aspx.vb" Inherits="ACCS_Sample_Compare_ABC" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    ' get attributes
    dim comparison as AdvantageBasedComparison = Session( "compareResult" )
    dim styleComparisons as AdvantageComparison() = comparison.comparisons
    dim scratchListIds as String = Session( "scratchListIds" )
    Dim pivotStyle As configcompare3.kp.chrome.com.Style = comparison.pivotConfiguration.style

    Session.Remove("compareResult")
    Session.Remove("scratchListIds")
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
    dim comparisonItem as AdvantageComparison
	for each comparisonItem in styleComparisons
        Dim photoUrl As String = comparisonItem.comparisonConfiguration.style.stockPhotoUrl
%>
		<td align="center"><img alt="photo" height="75px" width="150px" src="<%=photoUrl%>"></td>
<%
	next comparisonItem
%>
	</tr>
	<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<%
	dim primaryDescription as String = pivotStyle.modelYear.ToString() + " " + pivotStyle.divisionName + " " + pivotStyle.modelName + " " + pivotStyle.styleName
%>
    <td align="center"><%=primaryDescription%></td>
<%
    for each comparisonItem in styleComparisons
        Dim compareStyle As configcompare3.kp.chrome.com.Style = comparisonItem.comparisonConfiguration.style
		dim description as String = compareStyle.modelYear.ToString() + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName
%>
		<td align="center"><%=description%></td>
<%
	next comparisonItem
%>
	</tr>

	<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
    <td align="center"><%="$" + pivotStyle.baseInvoice.ToString() + " / " + "$" + pivotStyle.baseMsrp.ToString()%></td>
<%
    for each comparisonItem in styleComparisons
        Dim comparisonStyle As configcompare3.kp.chrome.com.Style = comparisonItem.comparisonConfiguration.style
		dim prices as String = "$" + comparisonStyle.baseInvoice.ToString() + " / " + "$" + comparisonStyle.baseMsrp.ToString()
%>
		<td align="center"><%=prices%></td>
<%
	next comparisonItem
%>
	</tr>

	<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
        <td align="center"><%="$" + pivotStyle.destination.ToString() %></td>
<%
	for each comparisonItem in styleComparisons
        Dim comparisonStyle As configcompare3.kp.chrome.com.Style = comparisonItem.comparisonConfiguration.style
		dim destinationCharge as String = "$" + comparisonStyle.destination.ToString()
%>
		<td align="center"><%=destinationCharge%></td>
<%
	next comparisonItem
%>
	</tr>
	<tr>
		<td align="center"><b>Select Primary</b></td>
        <td align="center"><input type="radio" name="primaryButton" checked></td>
<%
    dim i as integer
	for i = 0 to styleComparisons.Length - 1
%>
        <td align="center"><input type="radio" name="primaryButton"></td>
<%
	next i
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
    dim compareIndex as Integer
    for compareIndex = 0 to comparison.comparisons.Length - 1
        dim styleComparison as AdvantageComparison = comparison.comparisons( compareIndex )
        Dim compareStyle As configcompare3.kp.chrome.com.Style = styleComparison.comparisonConfiguration.style
        dim compareDescription as String = compareStyle.modelYear.ToString() + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName
%>
<b>The <%=primaryDescription%> has the following advantages over the <%=compareDescription%>:</b>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        dim comparisonItems as AdvantageComparisonItem() = styleComparison.comparisonItems
        dim item as AdvantageComparisonItem
        for each item in comparisonItems 
            dim resultType as String = item.comparisonResultType.ToString()
            if( String.Compare( resultType,  "Advantage", true ) = 0 ) 
                dim naturalLanguage as String = item.naturalLanguageDescription
%>
    			<tr><td align="left"><%=naturalLanguage%></td></tr>

<%
	    	end if
        next item
%>
</table>
<br>
<%
    next compareIndex
%>
<br>
<!-- show disadvantages -->
<a name="disadvantages"/><h3 class="label">DISADVANTAGES</h3>
<%
    for compareIndex = 0 to comparison.comparisons.Length - 1 
        dim styleComparison as AdvantageComparison = comparison.comparisons( compareIndex )
        Dim compareStyle As configcompare3.kp.chrome.com.Style = styleComparison.comparisonConfiguration.style
        dim compareDescription as String = compareStyle.modelYear.ToString() + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName
%>
<b>The <%=primaryDescription%> has the following disadvantages as compared to the <%=compareDescription%></b>:
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        dim comparisonItems as AdvantageComparisonItem() = styleComparison.comparisonItems
        dim item as AdvantageComparisonItem
        for each item in comparisonItems 
            dim resultType as String = item.comparisonResultType.ToString()
            if( String.Compare( resultType, "Disadvantage", true ) = 0 ) 
            
                dim naturalLanguage as String = item.naturalLanguageDescription
%>
    			<tr><td align="left"><%=naturalLanguage%></td></tr>
<%
		    end if
	    next item
%>
</table>
<br>
<%
    next compareIndex
%>
<a href="ACCS_Sample_Selector.aspx"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_Search.aspx"><b>Return to Search</b></a><br>
</body>
</html>
