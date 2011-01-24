<%@ Page Language="VB" AutoEventWireup="true" CodeFile="ACCS_Sample_Config_New.aspx.vb" Inherits="ACCS_Sample_Config_New" %>
<%@ Import Namespace = "System.IO" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    Dim configStyle As configcompare3.kp.chrome.com.Configuration = Session("configStyle")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Chrome Automotive Configuration Service&trade;</title>
    <style type="text/css">
    body {
	    font-family: Verdana, Arial, Helvetica, sans-serif;
	    margin-top: 0px;
	    margin-right: 5%;
	    margin-bottom: 0px;
	    margin-left: 5%;
    }
    .label {
	    color: #326BAD;
    }
    </style>
<script type="text/javascript" src="request.js"></script>
<script type="text/javascript" src="configure.js"></script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr>
	    <td align="center">
		    <h1><img alt="" style="border:0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif"/>Automotive Configuration Service&trade;</h1>
	    </td>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<!-- show description -->
<%
    Dim photoUrl As String = configStyle.style.stockPhotoUrl
    Dim description As String = configStyle.style.modelYear.ToString() + " " + configStyle.style.divisionName + " " + configStyle.style.modelName + " " + configStyle.style.styleName
    Dim singleQuote As String = Chr(34)
    Dim description2 As String = description.Replace( singleQuote, "" )
%>

	<tr><td align="center"><img alt="" src="<%=photoUrl%>"/></td></tr>
	<tr><td align="center"><h1 class="label"><%=description%></h1></td></tr>
</table>
<!-- show links -->
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td><a href="#generalInfoHref" id="General Info" onclick='showOrHideGroup(this.id)'><b>Show General Info</b></a></td></tr>
	<tr><td><a href="#techSpecHref" id="Technical Specifications" onclick='showOrHideGroup(this.id)'><b>Show Technical Specifications</b></a></td></tr>
	<tr><td><a href="#standardsHref" id="Standards" onclick='showOrHideGroup(this.id)'><b>Show Standards</b></a></td></tr>
	<tr><td><a href="#optionsHref" id="Options" onclick='showOrHideGroup(this.id)'><b>Show Options</b></a></td></tr>
	<tr><td><a href="#checklistHref" id="Configuration Checklist" onclick='showOrHideGroup(this.id)'><b>Show Configuration Checklist</b></a></td></tr>
	<tr><td><a href="#" id="Colors" onclick="showColorWindow()"><b>Show Colors</b></a></td></tr>
</table>

<!-- show General Info -->
<div id="General Info Div" style="display:none;visibility:hidden">
<a name="generalInfoHref"/>
<h3 class="label">GENERAL INFORMATION</h3>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
    Dim crashTestRating As String = configStyle.consumerInformation.crashTestRating
    If (Not crashTestRating is nothing ) Then
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Crash Test Rating</b></td><td style="width:60%"><%=crashTestRating%></td></tr>
<%
    End If


    Dim rebate As String = configStyle.consumerInformation.rebate
    If ( not rebate is nothing ) Then
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Rebate</b></td><td style="width:60%"><%=rebate%></td></tr>
<%
    End If

    Dim recall As String = configStyle.consumerInformation.recall
    If ( not recall is nothing ) Then
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Recall</b></td><td style="width:60%"><%=recall%></td></tr>
<%
    End If

    Dim warranty As String = configStyle.consumerInformation.warranty
    If (not warranty is nothing ) Then
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Warranty</b></td><td style="width:60%"><%=warranty%></td></tr>
<%
    End If
%>
</table>
</div>

<!-- show tech specs -->
<div id="Technical Specifications Div" style="display:none;visibility:hidden">
<a name="techSpecHref"/>
<h3 class="label">TECHNICAL SPECIFICATIONS</h3>
<%
    'store tech specs into hash( key = option name, value = array of options in same group )
    Dim techSpecHash As Hashtable = New Hashtable
    Dim techSpecs As TechnicalSpecification() = configStyle.technicalSpecifications
    Dim techSpec As TechnicalSpecification
    For Each techSpec In techSpecs
    
        Dim techSpecHeaderName As String = techSpec.headerName
        Dim techSpecFields As String = techSpec.titleName + "~" + techSpec.value + "~" + techSpec.measurementUnit

        Dim techSpecGroup As ArrayList = techSpecHash(techSpecHeaderName)
        If (techSpecGroup Is Nothing) Then
            techSpecGroup = New ArrayList()
        End If

        techSpecGroup.Add(techSpecFields)
        
        'remove old arraylist group and replace with new
        techSpecHash.Remove(techSpecHeaderName)
        techSpecHash.Add(techSpecHeaderName, techSpecGroup)
    Next techSpec

    Dim de As DictionaryEntry
    For Each de In techSpecHash
        Dim techSpecHeader As String = de.Key
%>
	<h4 class="label"><%=techSpecHeader.ToUpper()%></h4>
	<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
        Dim techSpecGroup As ArrayList = de.Value
        Dim techSpecFields As String
        For Each techSpecFields In techSpecGroup
            
            Dim title As String = Split(techSpecFields.ToString, "~")(0)
            Dim value As String = Split(techSpecFields.ToString, "~")(1)
            Dim unit As String = Split(techSpecFields.ToString, "~")(2)

            If (value Is Nothing Or value.Length = 0) Then
                value = "&nbsp;"
            End If
        
            if ( unit is nothing or unit.Length < 1 )
				unit = "&nbsp"
			else
				unit = " (" + unit + ")"
            end if
    %>  
            <tr><td style="width:40%" align="center"><b><%=title%><%=unit%></b></td><td align="center" style="width:60%"><%=value%></td></tr>
    <%
	    next techSpecFields
%>
	</table>
	<br/>
<%
	next de
%>
</div>

<!-- show standards -->
<div id="Standards Div" style="display:none;visibility:hidden">
<a name="standardsHref"/>
<h3 class="label">STANDARDS</h3>
<%
    ' store standards into hash( key = option name, value = array of options in same group )
    Dim standardsHash As Hashtable = New Hashtable
    Dim standards As Standard() = configStyle.standardEquipment
    Dim standardItem As Standard
    For Each standardItem In standards
    
        Dim standardHeaderName As String = standardItem.headerName
        Dim standardDesc As String = standardItem.description

        Dim standardGroup As ArrayList = standardsHash(standardHeaderName)
        If (standardGroup Is Nothing) Then
            standardGroup = New ArrayList
        End If

        standardGroup.Add(standardDesc)
        
        ' remove old arraylist group and replace with new
        standardsHash.Remove(standardHeaderName)
        standardsHash.Add(standardHeaderName, standardGroup)
    Next standardItem

    For Each de In standardsHash
    
        Dim standardHeader As String = de.Key
%>
	<h4 class="label"><%=standardHeader.ToUpper()%></h4>
	<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
        Dim standardGroup As ArrayList = de.Value
        Dim standardDesc As String
        For Each standardDesc In standardGroup
        
%>  
            <tr><td align="left" style="width:100%"><%=standardDesc%></td></tr>
<%
        Next standardDesc
%>
	</table>
	<br/>
<%
    Next de
%>
</div>

<!-- show options -->
<div id="Options Div" style="display:none;visibility:hidden">
<a name="optionsHref"/>
<h3 class="label">OPTIONS</h3>
<%
    ' store options into hash( key = option name, value = array of options in same group )
    Dim optionsHash As Hashtable = New Hashtable
    Dim options As configcompare3.kp.chrome.com.Option() = configStyle.options
    Dim optionItem As configcompare3.kp.chrome.com.Option
    For Each optionItem In options
    
        Dim primaryDescription As String = ""
        Dim extendedDescription As String = ""
        Dim od As OptionDescription
        For Each od In optionItem.descriptions
        
            If (od.type.Equals(OptionDescriptionType.PrimaryName)) Then
                primaryDescription = od.description
            ElseIf (od.type.Equals(OptionDescriptionType.Extended)) Then
                extendedDescription = od.description 
            End If
        next od
        
        Dim optionHeaderName As String = optionItem.headerName
        Dim optionFields As String = optionItem.selectionState.ToString() + "~" + _
                primaryDescription + "~" + _
                extendedDescription + "~" + _
                optionItem.oemOptionCode + "~" + _
                optionItem.chromeOptionCode + "~" + _
                optionItem.invoice.ToString() + "~" + _
                optionItem.msrp.ToString() + "~"

        Dim optionsGroup As ArrayList = optionsHash(optionHeaderName)
        If (optionsGroup Is Nothing) Then
            optionsGroup = New ArrayList
        End If

        optionsGroup.Add(optionFields)
        
        ' remove old arraylist group and replace with new
        optionsHash.Remove(optionHeaderName)
        optionsHash.Add(optionHeaderName, optionsGroup)
    Next optionItem

	for each de in optionsHash 
    
        Dim optionHeader As String = de.Key
%>
	<h4 class="label"><%=optionHeader.ToUpper()%></h4>
	<table width="100%" border="1" cellspacing="0" cellpadding="2">
		<tr>
			<td style="width:5%"  align="center"><b>State</b></td>
			<td style="width:45%" align="center"><b>Description</b></td>
			<td style="width:10%" align="center"><b>Code</b></td>
			<td style="width:20%" align="center"><b>Invoice</b></td>
			<td style="width:20%" align="center"><b>MSRP</b></td>
		</tr>
<%
        Dim optionGroup As ArrayList = de.Value
        Dim optionFields As String
        For Each optionFields In optionGroup    
            Dim optionState As String = Split(optionFields, "~")(0)
            Dim optionDesc As String = Split(optionFields, "~")(1)
            Dim optionExtDesc As String = Split(optionFields, "~")(2)
            Dim manufacturerOptionCode As String = Split(optionFields, "~")(3)
            Dim chromeOptionCode As String = Split(optionFields, "~")(4)
            Dim optionInvoice As String = Split(optionFields, "~")(5)
            Dim optionMsrp As String = Split( optionFields, "~" )(6)

            If (optionExtDesc.Length > 0) Then
                optionDesc += ", " + optionExtDesc
            End If
    %>
		    <tr>
    <%
            If (optionState = "Excluded") Then
    %>
				    <td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/excluded.gif" alt="Excluded" title="Excluded" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
    <%
            ElseIf (optionState = "Included") Then
    %>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/included.gif" alt="Included" title="Included" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
    <%
            ElseIf (optionState = "Required") Then
    %>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/required.gif" alt="Required" title="Required" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
    <%
            ElseIf (optionState = "Selected") Then
    %>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/selected.gif" alt="Selected" title="Selected" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
    <%
            ElseIf (optionState = "Unselected") Then
    %>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/unselected.gif" alt="Unselected" title="Unselected" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
    <%
            ElseIf (optionState = "Upgraded") Then
    %>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/upgraded.gif" alt="Upgraded" title="Upgraded" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
    <%
            End If
    %>
			    <td style="width:45%" align="center"><%=optionDesc%></td>
			    <td style="width:10%" align="center"><%=manufacturerOptionCode%></td>
			    <td style="width:20%" align="center">$<%=optionInvoice%></td>
			    <td style="width:20%" align="center">$<%=optionMsrp%></td>
		    </tr>
    <%
		    next optionFields
%>
		</table>
		<br/>
<%
	next de
%>
</div>

<!-- show pricing -->
<a name="pricing"/><h3 class="label">PRICING SUMMARY</h3>
<%
    Dim baseInvoice As String = configStyle.style.baseInvoice.ToString()
    Dim baseMsrp As String = configStyle.style.baseMsrp.ToString()
    Dim destCharge As String = configStyle.style.destination.ToString()

    Dim totalOptionInvoice As String = configStyle.configuredOptionsInvoice.ToString()
    Dim totalOptionMsrp As String = configStyle.configuredOptionsMsrp.ToString()

    Dim totalInvoice As String = configStyle.configuredTotalInvoice.ToString()
    Dim totalMsrp As String = configStyle.configuredTotalMsrp.ToString()
%>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr>
		<td align="center" style="width:70%">&nbsp;</td>
		<td align="center" style="width:15%"><b>Invoice</b></td>
		<td align="center" style="width:15%"><b>MSRP</b></td>
	</tr>
</table>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
	<tr>
		<td align="center" style="width:70%"><b>Base Price</b></td>
		<td align="center" style="width:15%"><span id="baseInvoice">$<%=baseInvoice%></span></td>
		<td align="center" style="width:15%"><span id="baseMsrp">$<%=baseMsrp%></span></td>
	</tr>
	<tr>
		<td align="center" style="width:70%"><b>Destination Charge</b></td>
		<td align="center" style="width:15%"><span id="destChargeInvoice">$<%=destCharge%></span></td>
		<td align="center" style="width:15%"><span id="destChargeMsrp">$<%=destCharge%></span></td>
	</tr>
	<tr>
		<td align="center" style="width:70%"><b>Total Options Price</b></td>
		<td align="center" style="width:15%"><span id="totalOptionInvoice">$<%=totalOptionInvoice%></span></td>
		<td align="center" style="width:15%"><span id="totalOptionMsrp">$<%=totalOptionMsrp%></span></td>
	</tr>
	<tr>
		<td align="center" style="width:70%"><b>Total Price( minus Destination )</b></td>
		<td align="center" style="width:15%"><span id="totalInvoice"><b>$<%=totalInvoice%></b></span></td>
		<td align="center" style="width:15%"><span id="totalMsrp"><b>$<%=totalMsrp%></b></span></td>
	</tr>
</table>
<div id="Configuration Checklist Div" style="display:none;visibility:hidden">
<a name="checklistHref"/><h3 class="label">CONFIGURATION CHECKLIST</h3>
<%
    Dim items As ConfigurationCheckListItem() = configStyle.configurationCheckListItems
    Dim item As ConfigurationCheckListItem
    For Each item In items
        Dim satisfiedStateColor As String = IIf(item.satisfied, "White", "Red")
%>
<table name="checklistTable" width="100%" border="1" cellspacing="0" cellpadding="2" style="background-color: <%=satisfiedStateColor%>;">
    <tr>
		<td colspan="100%" align="left" width="15%" style="background-color: Lime;"><b><%=item.itemName%></b></td>
    </tr>
<%
        dim chromeOptionCode as String
        For Each chromeOptionCode In item.chromeOptionCodes
        
            dim thisOption as configcompare3.kp.chrome.com.Option
            for each thisOption in configStyle.options
                if( chromeOptionCode = thisOption.chromeOptionCode ) then
               
	                dim statusDescription as String = "&nbsp;"
                    if( thisOption.selectionState = OptionSelectionState.Selected or thisOption.selectionState = OptionSelectionState.Included or thisOption.selectionState = OptionSelectionState.Required )
                          statusDescription = "-->"
                    end if
                    dim checklistOptionDescription as String = "" 
                    dim optDescription as OptionDescription
                    for each optDescription in thisOption.descriptions
                    
	                    if( optDescription.type = OptionDescriptionType.PrimaryName )
                            checklistOptionDescription = optDescription.description
		                 	exit for
		                end if
                    next optDescription
%>
    <tr>
    	<td align="right" width="10%" style="border-right: 1px solid black;"><b><span id="checklistStatus<%=thisOption.chromeOptionCode%>"><%=statusDescription%></span></b></td>
		<td align="center" width="10%" style="border-right: 1px solid black;"><b><%=thisOption.oemOptionCode%></b></td>
		<td align="left" width="80%"><b><%=checklistOptionDescription%></b></td>
    </tr>
<%
                    exit for
                end if
            next thisOption
        next chromeOptionCode
%>
</table><br/>
<%
    next item
%>
</div>
<div id="modalWinMask" style="position:absolute; top:0; left:0; padding:0; margin:0; background:black; Filter:Alpha(opacity=25); -moz-opacity:.25; opacity:.25; visibility:hidden; display:none; z-index:1;">&nbsp;</div>
<div id="conflictDialog" style="border-width:thin; border-top:1px solid; border-left:1px solid; border-right:1px solid; border-bottom:1px solid; position:absolute; width:600px; background:#FFFFFF; visibility:hidden; display:none; z-index:2;">
<div id="conflictContent"> </div>
</div>
<br/>
<input type="button" name="Save Style" value="Save Style" onclick='saveStyle("<%=description2%>")'/><span style="font-size:10px">&nbsp;( Saved Styles will appear in the Selector page )</span>
<div id="styleSaveDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%">Style Saved</td></tr></table>
</div>
<br />

<a href="ACCS_Sample_Selector.aspx"><b>Return to Selector</b></a><br />
<a href="ACCS_Sample_Search.aspx"><b>Return to Search</b></a><br />
</body>
</html>
