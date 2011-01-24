<%@ page import="com.chrome.kp.configcompare3.*"%>
<%@ page import="java.util.ArrayList" %>
<%
    //get attributes
    Configuration[] comparedConfigurations = (Configuration[]) request.getAttribute( "comparedConfigurations" );
    SideBySideComparisonGroup[] comparisonGroups = (SideBySideComparisonGroup[]) request.getAttribute( "comparisonGroups" );
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
		<h1><img alt="Chrome" border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Comparison Service&trade;</h1>
	</td></tr>
	<tr><td align="center"><h1 class="label">Side By Side Comparison</h1></td></tr>
</table>
<!-- show links -->
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<%
	for( int i = 0; i < comparisonGroups.length; i++ ) {
		String groupName = comparisonGroups[i].getGroupName();
		String href = "#" + groupName + "Href";
%>
	<tr><td><a href="<%=href%>" id="<%=groupName%>" onClick="showOrHideGroup(this.id)"><b>Show <%=groupName%></b></a></td></tr>
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
	for( int i = 0; i < comparedConfigurations.length; i++) {
		Style compareStyle = comparedConfigurations[i].getStyle();
		String photoUrl = compareStyle.getStockPhotoUrl();
%>
		<td align="center" width="350px"><img alt="photo" height="75px" width="150px" src="<%=photoUrl%>"></td>
<%
	}
%>
	</tr>
<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<%
	for( int i = 0; i < comparedConfigurations.length; i++ ) {
		Style compareStyle = comparedConfigurations[i].getStyle();
		String description = compareStyle.getModelYear() + " " + compareStyle.getDivisionName() + " " + compareStyle.getModelName() + " " + compareStyle.getStyleName();
%>
		<td align="center"><%=description%></td>
<%
	}
%>
	</tr>
<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
<%
	for( int i = 0; i < comparedConfigurations.length; i++ ) {
		Style compareStyle = comparedConfigurations[i].getStyle();
		String prices = "$" + Double.toString( compareStyle.getBaseInvoice() ) + " / " + "$" + Double.toString( compareStyle.getBaseMsrp() ) ;
%>
		<td align="center"><%=prices%></td>
<%
	}
%>
	</tr>

<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
<%
	for( int i = 0; i < comparedConfigurations.length; i++ ) {
		Style compareStyle = comparedConfigurations[i].getStyle();
		String destinationCharge = "$" + Double.toString( compareStyle.getDestination() );
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
	for( int i = 0; i < comparisonGroups.length; i++ )  {
		String groupName = comparisonGroups[i].getGroupName();
		String divName = groupName + "Div";
		String hrefName = groupName + "Href";
%>
		<div id="<%=divName%>" style="display:none;visibility:hidden">
			<a name="<%=hrefName%>"/>
			<h3 class="label"><%=groupName.toUpperCase()%></h3>
			<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
		for( int j = 0; j < comparisonGroups[i].getComparisonItems().length; j++) {
			String featureDescription = comparisonGroups[i].getComparisonItems()[j].getFeatureDescription();
			String[] comparisonValues = comparisonGroups[i].getComparisonItems()[j].getComparisonValues();
%>
			<tr><td align="center" width="250px"><b><%=featureDescription%></b></td>
<%
			for( int k = 0; k < comparedConfigurations.length; k++) {
				String value = comparisonValues[k];
				if ( value == null || value.length() < 1 )
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
	for( int i = 0; i < comparedConfigurations.length; i++ ) {
        String warranty = comparedConfigurations[i].getConsumerInformation().getWarranty();
%>
		<td align="center"><%=warranty%></td>
<%
	}
%>
	</tr>
</table>
<br>
<a href="ACCS_Sample_Selector.jsp"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_CF_Selector.jsp"><b>Return to Consumer Friendly Selector</b></a><br>
<a href="ACCS_Sample_Search.jsp"><b>Return to Search</b></a><br>
</body>
</html>