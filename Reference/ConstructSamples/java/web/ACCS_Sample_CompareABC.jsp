<%@ page import="com.chrome.kp.configcompare3.*" %>
<%
    //get attributes
    AdvantageBasedComparison comparison = (AdvantageBasedComparison) request.getAttribute( "compareResult" );
    AdvantageComparison[] styleComparisons = comparison.getComparisons();
    String scratchListIds = (String) request.getAttribute( "scratchListIds" );
    Style pivotStyle = comparison.getPivotConfiguration().getStyle();
%>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->
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
<script type="text/javascript" src="js/compare.js"></script>
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
    <td align="center"><img alt="photo" height="75px" width="150px" src="<%=pivotStyle.getStockPhotoUrl()%>"></td>
<%
	for( int i = 0; i < styleComparisons.length; i++ ) {
		Style comparisonStyle = styleComparisons[i].getComparisonConfiguration().getStyle();
		String photoUrl = comparisonStyle.getStockPhotoUrl();
%>
		<td align="center"><img alt="photo" height="75px" width="150px" src="<%=photoUrl%>"></td>
<%
	}
%>
	</tr>
	<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<%
	String primaryDescription = pivotStyle.getModelYear() + " " + pivotStyle.getDivisionName() + " " + pivotStyle.getModelName() + " " + pivotStyle.getStyleName();
%>
    <td align="center"><%=primaryDescription%></td>
<%
    for( int i = 0; i < styleComparisons.length; i++ ) {
		Style compareStyle = styleComparisons[i].getComparisonConfiguration().getStyle();
		String description = compareStyle.getModelYear() + " " + compareStyle.getDivisionName() + " " + compareStyle.getModelName() + " " + compareStyle.getStyleName();
%>
		<td align="center"><%=description%></td>
<%
	}
%>
	</tr>

	<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
    <td align="center"><%="$" + Double.toString( pivotStyle.getBaseInvoice() ) + " / " + "$" + Double.toString( pivotStyle.getBaseMsrp() )%></td>
<%
	for( int i = 0; i < styleComparisons.length; i++ ) {
		Style compareStyle = styleComparisons[i].getComparisonConfiguration().getStyle();
		String prices = "$" + Double.toString( compareStyle.getBaseInvoice() ) + " / " + "$" + Double.toString( compareStyle.getBaseMsrp() ) ;
%>
		<td align="center"><%=prices%></td>
<%
	}
%>
	</tr>

	<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
        <td align="center"><%="$" + Double.toString( pivotStyle.getDestination() )%></td>
<%
	for( int i = 0; i < styleComparisons.length; i++ ) {
		Style compareStyle = styleComparisons[i].getComparisonConfiguration().getStyle();
		String destinationCharge = "$" + Double.toString( compareStyle.getDestination() );
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
	for( int i = 0; i < styleComparisons.length; i++ ) {
%>
        <td align="center"><input type="radio" name="primaryButton"></td>
<%
	}
%>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center"><input type="button" name="newABC_Compare" value="Compare" onClick='doNewABC_Compare("<%=scratchListIds%>")'></td></tr>
</table>
<div id="pleaseWaitMsgDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%" align="center">Retrieving Data...Please Wait</td></tr></table>
</div>
<br>
<!-- show advantages -->
<a name="advantages"/><h3 class="label">ADVANTAGES</h3>
<%
    for( int compareIndex = 0; compareIndex < comparison.getComparisons().length; compareIndex++ ){
        AdvantageComparison styleComparison = comparison.getComparisons()[compareIndex];
        Style compareStyle = styleComparison.getComparisonConfiguration().getStyle();
        String compareDescription = compareStyle.getModelYear() + " " + compareStyle.getDivisionName() + " " + compareStyle.getModelName() + " " + compareStyle.getStyleName();
%>
<b>The <%=primaryDescription%> has the following advantages over the <%=compareDescription%>:</b>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        AdvantageComparisonItem[] comparisonItems = styleComparison.getComparisonItems();
        for( int i = 0; i < comparisonItems.length; i++ ) {
            String resultType = comparisonItems[i].getComparisonResultType().toString();
            if( resultType.equalsIgnoreCase( "Advantage" ) ) {
                String naturalLanguage = comparisonItems[i].getNaturalLanguageDescription();
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
    for( int compareIndex = 0; compareIndex < comparison.getComparisons().length; compareIndex++ ){
        AdvantageComparison styleComparison = comparison.getComparisons()[compareIndex];
        Style compareStyle = styleComparison.getComparisonConfiguration().getStyle();
        String compareDescription = compareStyle.getModelYear() + " " + compareStyle.getDivisionName() + " " + compareStyle.getModelName() + " " + compareStyle.getStyleName();
%>
<b>The <%=primaryDescription%> has the following disadvantages as compared to the <%=compareDescription%></b>:
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        AdvantageComparisonItem[] comparisonItems = styleComparison.getComparisonItems();
        for( int i = 0; i < comparisonItems.length; i++ ) {
            String resultType = comparisonItems[i].getComparisonResultType().toString();
            if( resultType.equalsIgnoreCase( "Disadvantage" ) ) {
                String naturalLanguage = comparisonItems[i].getNaturalLanguageDescription();
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
<a href="ACCS_Sample_Selector.jsp"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_CF_Selector.jsp"><b>Return to Consumer Friendly Selector</b></a><br>
<a href="ACCS_Sample_Search.jsp"><b>Return to Search</b></a><br>
</body>
</html>