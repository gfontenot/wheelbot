<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ACCS_Sample_Config_New.aspx.cs" Inherits="ACCS_Sample_Config_New" %>
<%@ Import Namespace = "configcompare3.kp.chrome.com" %>
<%
    configcompare3.kp.chrome.com.Configuration configStyle = (configcompare3.kp.chrome.com.Configuration)Session["configStyle"];
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
    String photoUrl = configStyle.style.stockPhotoUrl;
	String description = configStyle.style.modelYear + " " + configStyle.style.divisionName + " " +
						 configStyle.style.modelName + " " + configStyle.style.styleName;
	
	String description2 = description.Replace( "\"", "\\\"" );
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
    String crashTestRating = configStyle.consumerInformation.crashTestRating;
	if( crashTestRating != null && crashTestRating.Length > 0 ) {
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Crash Test Rating</b></td><td style="width:60%"><%=crashTestRating%></td></tr>
<%
	}

    String rebate = configStyle.consumerInformation.rebate;
	if( rebate != null && rebate.Length > 0 ) {
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Rebate</b></td><td style="width:60%"><%=rebate%></td></tr>
<%
	}

    String recall = configStyle.consumerInformation.recall;
	if( recall != null && recall.Length > 0 ) {
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Recall</b></td><td style="width:60%"><%=recall%></td></tr>
<%
	}

    String warranty = configStyle.consumerInformation.warranty;
	if( warranty != null && warranty.Length > 0 ) {
%>
		<tr><td valign="top" align="center" style="width:40%"><b>Warranty</b></td><td style="width:60%"><%=warranty%></td></tr>
<%
	}
%>
</table>
</div>

<!-- show tech specs -->
<div id="Technical Specifications Div" style="display:none;visibility:hidden">
<a name="techSpecHref"/>
<h3 class="label">TECHNICAL SPECIFICATIONS</h3>
<%
	//store tech specs into hash( key = option name, value = array of options in same group )
	Hashtable techSpecHash = new Hashtable();
    TechnicalSpecification[] techSpecs = configStyle.technicalSpecifications;
    foreach( TechnicalSpecification techSpec in techSpecs )
    {
        String techSpecHeaderName = techSpec.headerName;
        String techSpecFields = techSpec.titleName + "~" +
                                techSpec.value + "~" +
                                techSpec.measurementUnit;


        ArrayList techSpecGroup = (ArrayList)techSpecHash[techSpecHeaderName];
        if (techSpecGroup == null)
            techSpecGroup = new ArrayList();

        techSpecGroup.Add(techSpecFields);
        
        //remove old arraylist group and replace with new
        techSpecHash.Remove(techSpecHeaderName);
        techSpecHash.Add(techSpecHeaderName, techSpecGroup);
	}

    foreach (DictionaryEntry de in techSpecHash)
    {
       String techSpecHeader = (String)de.Key;
%>
	<h4 class="label"><%=techSpecHeader.ToUpper()%></h4>
	<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
	    ArrayList techSpecGroup = (ArrayList)de.Value;
        foreach( String techSpecFields in techSpecGroup )
        {
            String title = techSpecFields.Split('~')[0];
            String value = techSpecFields.Split('~')[1];
            String unit = techSpecFields.Split('~')[2];

            if (value == null || value.Length < 1)
                value = "&nbsp;";

            if (unit == null || unit.Length < 1)
                unit = "&nbsp";
            else
                unit = " (" + unit + ")";
%>  
        <tr><td style="width:40%" align="center"><b><%=title%><%=unit%></b></td><td align="center" style="width:60%"><%=value%></td></tr>
<%
	    }
%>
	</table>
	<br/>
<%
	}
%>
</div>

<!-- show standards -->
<div id="Standards Div" style="display:none;visibility:hidden">
<a name="standardsHref"/>
<h3 class="label">STANDARDS</h3>
<%
	//store standards into hash( key = option name, value = array of options in same group )
	Hashtable standardsHash = new Hashtable();
    Standard[] standards = configStyle.standardEquipment;
    foreach( Standard standard in standards )
    {
        String standardHeaderName = standard.headerName;
        String standardDesc = standard.description;

        ArrayList standardGroup = (ArrayList)standardsHash[standardHeaderName];
        if (standardGroup == null)
            standardGroup = new ArrayList();

        standardGroup.Add(standardDesc);
        
        //remove old arraylist group and replace with new
        standardsHash.Remove(standardHeaderName);
        standardsHash.Add(standardHeaderName, standardGroup);
	}

    foreach (DictionaryEntry de in standardsHash)
    {
        String standardHeader = (String)de.Key;
%>
	<h4 class="label"><%=standardHeader.ToUpper()%></h4>
	<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
        ArrayList standardGroup = (ArrayList)de.Value;
        foreach( String standardDesc in standardGroup )
        {
%>  
            <tr><td align="left" style="width:100%"><%=standardDesc%></td></tr>
<%
	    }
%>
	</table>
	<br/>
<%
	}
%>
</div>

<!-- show options -->
<div id="Options Div" style="display:none;visibility:hidden">
<a name="optionsHref"/>
<h3 class="label">OPTIONS</h3>
<%
	//store options into hash( key = option name, value = array of options in same group )
	Hashtable optionsHash = new Hashtable();
    Option[] options = configStyle.options;
    foreach( Option option in options )
    {
        String primaryDescription = "";
        String extendedDescription = "";
        foreach( OptionDescription od in option.descriptions )
        {
            if (od.type == OptionDescriptionType.PrimaryName)
            {
                primaryDescription = od.description;
            }
            else if (od.type == OptionDescriptionType.Extended)
            {
                extendedDescription = od.description;
            }
        }
        String optionHeaderName = option.headerName;
        String optionFields = option.selectionState.ToString() + "~" +
                primaryDescription + "~" +
                extendedDescription + "~" +
                option.oemOptionCode + "~" +
                option.chromeOptionCode + "~" +
                option.invoice.ToString() + "~" +
                option.msrp.ToString() + "~";

        ArrayList optionsGroup = (ArrayList)optionsHash[ optionHeaderName ];
        if (optionsGroup == null)
            optionsGroup = new ArrayList();

        optionsGroup.Add(optionFields);
        
        //remove old arraylist group and replace with new
        optionsHash.Remove(optionHeaderName);
        optionsHash.Add(optionHeaderName, optionsGroup);
	}

	foreach( DictionaryEntry de in optionsHash )
    {
       String optionHeader = (String)de.Key;
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
	ArrayList optionGroup = (ArrayList)de.Value;
    foreach( String optionFields in optionGroup)
    {
        String optionState = optionFields.Split('~')[0];
        String optionDesc = optionFields.Split('~')[1];
        String optionExtDesc = optionFields.Split('~')[2];
        String manufacturerOptionCode = optionFields.Split('~')[3];
        String chromeOptionCode = optionFields.Split('~')[4];
        String optionInvoice = optionFields.Split('~')[5];
        String optionMsrp = optionFields.Split('~')[6];

		if ( optionExtDesc != null && optionExtDesc.Length > 0 )
			optionDesc += ", " + optionExtDesc;
%>
		<tr>
<%
			if ( optionState == "Excluded" ) {
%>
				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/excluded.gif" alt="Excluded" title="Excluded" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
<%
			} else if ( optionState == "Included" ) {
%>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/included.gif" alt="Included" title="Included" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
<%
			} else if ( optionState == "Required" ) {
%>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/required.gif" alt="Required" title="Required" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
<%
			} else if ( optionState == "Selected" ) {
%>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/selected.gif" alt="Selected" title="Selected" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
<%
			} else if ( optionState == "Unselected" ) {
%>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/unselected.gif" alt="Unselected" title="Unselected" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
<%
			} else if ( optionState == "Upgraded" ) {
%>				<td style="width:5%" align="center"><img id="img<%=chromeOptionCode%>" src="images/upgraded.gif" alt="Upgraded" title="Upgraded" onclick='toggleOption("<%=chromeOptionCode%>")'/></td>
<%
			}
%>
			<td style="width:45%" align="center"><%=optionDesc%></td>
			<td style="width:10%" align="center"><%=manufacturerOptionCode%></td>
			<td style="width:20%" align="center">$<%=optionInvoice%></td>
			<td style="width:20%" align="center">$<%=optionMsrp%></td>
		</tr>
<%
		}
%>
		</table>
		<br/>
<%
	}
%>
</div>

<!-- show pricing -->
<a name="pricing"/><h3 class="label">PRICING SUMMARY</h3>
<%
    String baseInvoice = configStyle.style.baseInvoice.ToString();
    String baseMsrp = configStyle.style.baseMsrp.ToString();
    String destCharge = configStyle.style.destination.ToString();

    String totalOptionInvoice = configStyle.configuredOptionsInvoice.ToString();
    String totalOptionMsrp = configStyle.configuredOptionsMsrp.ToString();

    String totalInvoice = configStyle.configuredTotalInvoice.ToString();
    String totalMsrp = configStyle.configuredTotalMsrp.ToString();
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
    ConfigurationCheckListItem[] items = configStyle.configurationCheckListItems;
    foreach( ConfigurationCheckListItem item in items )
    {
        String satisfiedStateColor  = item.satisfied ? "White" : "Red";
%>
<table name="checklistTable" width="100%" border="1" cellspacing="0" cellpadding="2" style="background-color: <%=satisfiedStateColor%>;">
    <tr>
		<td colspan="100%" align="left" width="15%" style="background-color: Lime;"><b><%=item.itemName%></b></td>
    </tr>
<%
        foreach (String chromeOptionCode in item.chromeOptionCodes)
        {
            foreach( Option option in configStyle.options )
            {
                if( chromeOptionCode == option.chromeOptionCode )
                {
	                String statusDescription = "&nbsp;";
                    if( option.selectionState == OptionSelectionState.Selected || option.selectionState == OptionSelectionState.Included || option.selectionState == OptionSelectionState.Required )
                    {
                          statusDescription = "-->";
                    }
                    String checklistOptionDescription = "";
                    foreach( OptionDescription optDescription in option.descriptions )
                    {
	                    if( optDescription.type == OptionDescriptionType.PrimaryName ){
                            checklistOptionDescription = optDescription.description;
		                 	break;
		                }
                    }
%>
    <tr>
    	<td align="right" width="10%" style="border-right: 1px solid black;"><b><span id="checklistStatus<%=option.chromeOptionCode%>"><%=statusDescription%></span></b></td>
		<td align="center" width="10%" style="border-right: 1px solid black;"><b><%=option.oemOptionCode%></b></td>
		<td align="left" width="80%"><b><%=checklistOptionDescription%></b></td>
    </tr>
<%
                    break;
                }
            }
        }
%>
</table><br>
<%
    }
%>
</div>
<div id="modalWinMask" style="position:absolute; top:0; left:0; padding:0; margin:0; background:black; Filter:Alpha(opacity=25); -moz-opacity:.25; opacity:.25; visibility:hidden; display:none; z-index:1;">&nbsp;</div>
<div id="conflictDialog" style="border-width:thin; border-top:1px solid; border-left:1px solid; border-right:1px solid; border-bottom:1px solid; position:absolute; width:600px; background:#FFFFFF; visibility:hidden; display:none; z-index:2;">
<div id="conflictContent"> </div>
</div>
<br/>
<input type="button" name="Save Style" value="Save Style" onclick='saveStyle("<%=description2%>")'><span style="font-size:10px">&nbsp;( Saved Styles will appear in the Selector page )</span>
<div id="styleSaveDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%">Style Saved</td></tr></table>
</div>
<br>

<a href="ACCS_Sample_Selector.aspx"><b>Return to Selector</b></a><br />
<a href="ACCS_Sample_Search.aspx"><b>Return to Search</b></a><br />
</body>
</html>
