<%@ Page Language="VB" AutoEventWireup="true" CodeFile="ACCS_Sample_Compare_SBS.aspx.vb" Inherits="ACCS_Sample_Compare_SBS" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    ' get attributes and remove them from the session
    Dim comparisonConfigurations As configcompare3.kp.chrome.com.Configuration() = Session("comparisonConfigurations")
    dim comparisonGroups as SideBySideComparisonGroup() = Session( "comparisonGroups" )

    Session.Remove("comparisonConfigurations")
    Session.Remove("comparisonGroups")
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
    dim group as SideBySideComparisonGroup
	for each group in comparisonGroups 
		dim groupName as String = group.groupName
		dim href as String = "#" + groupName + "Href"
%>
	<tr><td><a href="<%=href%>" id="<%=groupName%>" onclick="showOrHideGroup(this.id)"><b>Show <%=groupName%></b></a></td></tr>
<%
	next group
%>
</table>
<br>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<!-- show stock photos -->
	<tr>
		<td width="250px">&nbsp;</td>
<%
    Dim compareConfig As configcompare3.kp.chrome.com.Configuration
    For Each compareConfig In comparisonConfigurations
        Dim compareStyle As configcompare3.kp.chrome.com.Style = compareConfig.style
        Dim photoUrl As String = compareStyle.stockPhotoUrl
%>
		<td align="center" width="350px"><img alt="photo" height="75px" width="150px" src="<%=photoUrl%>"></td>
<%
Next compareConfig
%>
	</tr>
<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<%
    For Each compareConfig In comparisonConfigurations
        Dim compareStyle As configcompare3.kp.chrome.com.Style = compareConfig.style
        Dim description As String = compareStyle.modelYear.ToString() + " " + compareStyle.divisionName + " " + compareStyle.modelName + " " + compareStyle.styleName
%>
		<td align="center"><%=description%></td>
<%
Next compareConfig
%>
	</tr>
<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
<%
    For Each compareConfig In comparisonConfigurations
        Dim compareStyle As configcompare3.kp.chrome.com.Style = compareConfig.style
        Dim prices As String = "$" + compareStyle.baseInvoice.ToString() + " / " + "$" + compareStyle.baseMsrp.ToString()
%>
		<td align="center"><%=prices%></td>
<%
Next compareConfig
%>
	</tr>

<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
<%
    For Each compareConfig In comparisonConfigurations
        Dim compareStyle As configcompare3.kp.chrome.com.Style = compareConfig.style
        Dim destinationCharge As String = "$" + compareStyle.destination.ToString()
%>
		<td align="center"><%=destinationCharge%></td>
<%
Next compareConfig
%>
	</tr>
</table>
<br>
<!-- Show Categories -->
<%
    for each group in comparisonGroups
        dim groupName as String = group.groupName
		dim divName as String = groupName + "Div"
        Dim hrefName As String = groupName + "Href"        
%>
		<div id="<%=divName%>" style="display:none;visibility:hidden">
			<a name="<%=hrefName%>"/>
			<h3 class="label"><%=groupName.ToUpper()%></h3>
			<table width="100%" border="1" cellspacing="0" cellpadding="5">
<%
        dim item as SideBySideComparisonGroupItem
		for each item in group.comparisonItems
            dim featureDescription as String = item.featureDescription
            dim comparisonValues as String() = item.comparisonValues
%>
			<tr><td align="center" width="250px"><b><%=featureDescription%></b></td>
<%
    Dim k As Integer
    For k = 0 To comparisonConfigurations.Length - 1
        Dim value As String = comparisonValues(k)
        If (value Is Nothing Or value.Length < 1) Then
            value = "&nbsp;"
        End If
%>
			<td align="center" width="350px"><%=value%></td>
<%
			next k
%>
			</tr>
<%
		next item
%>
			</table><br>
		</div>
<%
	next group
%>
<!-- show warranty -->
<h3 class="label">WARRANTY</h3>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
	<tr>
		<td align="center" width="250px"><b>Warranty</b></td>
<%
    dim i as Integer
    For i = 0 To comparisonConfigurations.Length - 1
        Dim warranty As String = comparisonConfigurations(i).consumerInformation.warranty
%>
		<td align="center"><%=warranty%></td>
<%
	next i
%>
	</tr>
</table>
<br>
<a href="ACCS_Sample_Selector.aspx"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_Search.aspx"><b>Return to Search</b></a><br>
</body>
</html>
