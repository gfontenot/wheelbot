<%@ page import="com.chrome.kp.configcompare3.*"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%
	Configuration configStyle = (Configuration)session.getAttribute( "configStyle" );
%>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<title>Chrome Automotive Configuration Service&trade;</title>
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
<script type="text/javascript" src="js/request.js"></script>
<script type="text/javascript" src="js/configure.js"></script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td align="center">
		<h1><img alt="Chrome" border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Configuration Service&trade;</h1>
	</td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<!-- show description -->
<%
	String photoUrl = configStyle.getStyle().getStockPhotoUrl();
	String description = configStyle.getStyle().getModelYear() + " " + configStyle.getStyle().getDivisionName() + " " +
						 configStyle.getStyle().getModelName() + " " + configStyle.getStyle().getStyleName();
%>

	<tr><td align="center"><img alt="photo" src="<%=photoUrl%>"></td></tr>
	<tr><td align="center"><h1 class="label"><%=description%></h1></td></tr>
</table>
	<!-- links -->
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td><a href="#generalInfoHref" id="General Info" onClick='showOrHideGroup(this.id)'><b>Show General Info</b></a></td></tr>
	<tr><td><a href="#techSpecHref" id="Technical Specifications" onClick='showOrHideGroup(this.id)'><b>Show Technical Specifications</b></a></td></tr>
	<tr><td><a href="#standardsHref" id="Standards" onClick='showOrHideGroup(this.id)'><b>Show Standards</b></a></td></tr>
	<tr><td><a href="#optionsHref" id="Options" onClick='showOrHideGroup(this.id)'><b>Show Options</b></a></td></tr>
    <tr><td><a href="#checklistHref" id="Configuration Checklist" onClick='showOrHideGroup(this.id)'><b>Show Configuration Checklist</b></a></td></tr>
    <tr><td><a href="#" id="Colors" onclick="showColorWindow()"><b>Show Colors</b></a></td></tr>
</table>

<!-- show General Info -->
<div id="General Info Div" style="display:none;visibility:hidden">
<a name="generalInfoHref"/>
<h3 class="label">GENERAL INFORMATION</h3>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
    for( int i=0; i < configStyle.getStructuredConsumerInformation().length; i++ ){
        StructuredConsumerInformation info = configStyle.getStructuredConsumerInformation()[i];
        if( info.getItems().length > 0 ){
%>
    <tr><th colspan="3" align="center" bgcolor="yellow"><%=info.getTypeName()%></th></tr>
    <tr><th width="15%">Description</th><th width="75%">Value</th><th width="10%">Condition Note</th></tr>
<%
        	for( int j=0; j< info.getItems().length; j++ ){
            	StructuredConsumerInformationItem item = info.getItems()[j];
%>
    <tr><td width="15%"><%=item.getName()%></td><td width="75%"><%=item.getValue()%></td><td width="10%"><%=item.getConditionNote()==null?"&nbsp;":item.getConditionNote()%></td></tr>
<%
        	}
        }
    }
%>
</table>
<!-- show tech specs -->
</div>
<div id="Technical Specifications Div" style="display:none;visibility:hidden">
<a name="techSpecHref"/>
<h3 class="label">TECHNICAL SPECIFICATIONS</h3>
<%
	//store tech specs into hash
	HashMap techSpecHash = new HashMap();
	TechnicalSpecification[] technicalSpecifications = configStyle.getTechnicalSpecifications();
	for (int i = 0; i < technicalSpecifications.length; i++) {
		TechnicalSpecification technicalSpecification = technicalSpecifications[i];

		String techSpecHeaderName = technicalSpecification.getHeaderName();
		String techSpecFields = technicalSpecification.getTitleName() + "~~" +
								technicalSpecification.getValue() + "~~" +
								technicalSpecification.getMeasurementUnit();

		ArrayList techSpecGroup = (ArrayList)techSpecHash.get( techSpecHeaderName );
		if( techSpecGroup == null )
            techSpecGroup = new ArrayList();

    	techSpecGroup.add( techSpecFields );
		techSpecHash.put( techSpecHeaderName, techSpecGroup );
	}

	//iterate the hash and show standards
	Iterator iterator = techSpecHash.keySet().iterator();
	while ( iterator.hasNext() ) {
		String techSpecHeader = iterator.next().toString();
%>
<h4 class="label"><%=techSpecHeader.toUpperCase()%></h4>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
		ArrayList techSpecGroup = (ArrayList)techSpecHash.get( techSpecHeader );
		for( int i = 0; i < techSpecGroup.size(); i++ ) {
			String techSpecFields = (String)techSpecGroup.get(i);
			String title = techSpecFields.split( "~~" )[0];
			String value = techSpecFields.split( "~~" )[1];
			String unit = techSpecFields.split( "~~" )[2];

			if ( unit.equalsIgnoreCase( "null" ) || unit.length() < 1 )
				unit = "&nbsp";
			else
				unit = " (" + unit + ")";

			if( value.length() < 1 )
				value = "&nbsp;";
%>
			<tr><td width="40%" align="center"><b><%=title%><%=unit%></b></td><td align="center"><%=value%></td></tr>
<%
		}
%>
</table>
<%
	}
%>
</div>
<!-- show standards -->
<div id="Standards Div" style="display:none;visibility:hidden">
<a name="standardsHref"/>
<h3 class="label">STANDARDS</h3>
<%
	//store standards into hash( key = standards header, value = array of standards fields )
	HashMap standardsHash = new HashMap();
	Standard[] standards = configStyle.getStandardEquipment();
	for (int i = 0; i < standards.length; i++) {
		Standard standard = standards[i];

		String standardHeaderName = standard.getHeaderName();
		String standardDesc = standard.getDescription();

		ArrayList standardGroup = (ArrayList)standardsHash.get( standardHeaderName );
		if( standardGroup == null )
			standardGroup = new ArrayList();

    	standardGroup.add( standardDesc );
		standardsHash.put( standardHeaderName, standardGroup );
	}

	//iterate the hash and show standards
	iterator = standardsHash.keySet().iterator();
	while ( iterator.hasNext() ) {
		String standardHeader = iterator.next().toString();
%>
<h4 class="label"><%=standardHeader%><br><br>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<%
		ArrayList standardGroup = (ArrayList)standardsHash.get( standardHeader );
		for( int i = 0; i < standardGroup.size(); i++ ) {
			String standardDesc = (String)standardGroup.get(i);
%>
			<tr><td align="left"><%=standardDesc%></td></tr>
<%
		}
%>
</table>
<%
	}
%>
</div>
<!-- show options -->
<div id="Options Div" style="display:none;visibility:hidden">
<a name="optionsHref"/>
<h3 class="label">OPTIONS</h3>
<%
	//store options into hash( key = option header, value = array of options fields )
	HashMap optionsHash = new HashMap();
	Option[] options = configStyle.getOptions();
	for (int i = 0; i < options.length; i++) {
		Option option = options[i];

        String primaryDescription = "";
        String extendedDescription = "";
        for( int j=0; j < option.getDescriptions().length; j++ ){
            if( option.getDescriptions()[j].getType() == OptionDescriptionType.PrimaryName ){
                primaryDescription = option.getDescriptions()[j].getDescription();
            } else if ( option.getDescriptions()[j].getType() == OptionDescriptionType.Extended ){
                extendedDescription = option.getDescriptions()[j].getDescription();
            }
        }
        String optionHeaderName = option.getHeaderName();
		String optionFields = option.getSelectionState().toString() + "~~" +
                primaryDescription + "~~" +
				extendedDescription + "~~" +
				option.getOemOptionCode() + "~~" +
				option.getChromeOptionCode() + "~~" +
				Double.toString( option.getInvoice() ) + "~~" +
				Double.toString(option.getMsrp()) + "~~";

		ArrayList optionsGroup = (ArrayList)optionsHash.get( optionHeaderName );
		if( optionsGroup == null )
            optionsGroup = new ArrayList();

    	optionsGroup.add( optionFields );
		optionsHash.put(optionHeaderName, optionsGroup);
	}

	//iterate the hash and show options
	iterator = optionsHash.keySet().iterator();

	while (iterator.hasNext()) {
		String optionHeader = iterator.next().toString();
%>
	<h4 class="label"><%=optionHeader%></h4>
	<table width="100%" border="1" cellspacing="0" cellpadding="2">
		<tr>
			<td width="5%"  align="center"><b>State</b></td>
			<td width="45%" align="center"><b>Description</b></td>
			<td width="10%" align="center"><b>Code</b></td>
			<td width="20%" align="center"><b>Invoice</b></td>
			<td width="20%" align="center"><b>MSRP</b></td>
		</tr>
<%
	ArrayList optionGroup = (ArrayList)optionsHash.get( optionHeader );
	for( int i = 0; i < optionGroup.size(); i++ ) {
		String optionFields = (String)optionGroup.get(i);

		String optionState = optionFields.split( "~~" )[0];
		String optionDesc = optionFields.split( "~~" )[1];
		String optionExtDesc = optionFields.split( "~~" )[2];
		String manufacturerOptionCode = optionFields.split( "~~" )[3];
		String chromeOptionCode = optionFields.split( "~~" )[4];
		String optionInvoice = optionFields.split( "~~" )[5];
		String optionMsrp = optionFields.split( "~~" )[6];

		if ( optionExtDesc != null && optionExtDesc.length() > 0 )
			optionDesc += ", " + optionExtDesc;
%>
		<tr>
<%
			if ( optionState.equalsIgnoreCase( "Excluded" ) ) {
%>
				<td width="5%" align="center"><img alt="excluded" id="img<%=chromeOptionCode%>" src="images/excluded.gif" title="Excluded" onClick='toggleOption("<%=chromeOptionCode%>")'></td>
<%
			} else if ( optionState.equalsIgnoreCase( "Included" ) ) {
%>				<td width="5%" align="center"><img alt="included" id="img<%=chromeOptionCode%>" src="images/included.gif" title="Included" onClick='toggleOption("<%=chromeOptionCode%>")'></td>
<%
			} else if ( optionState.equalsIgnoreCase( "Required" ) ) {
%>				<td width="5%" align="center"><img alt="required" id="img<%=chromeOptionCode%>" src="images/required.gif" title="Required" onClick='toggleOption("<%=chromeOptionCode%>")'></td>
<%
			} else if ( optionState.equalsIgnoreCase( "Selected" ) ) {
%>				<td width="5%" align="center"><img alt="selected" id="img<%=chromeOptionCode%>" src="images/selected.gif" title="Selected" onClick='toggleOption("<%=chromeOptionCode%>")'></td>
<%
			} else if ( optionState.equalsIgnoreCase( "Unselected" ) ) {
%>				<td width="5%" align="center"><img alt="unselected" id="img<%=chromeOptionCode%>" src="images/unselected.gif" title="Unselected" onClick='toggleOption("<%=chromeOptionCode%>")'></td>
<%
			} else if ( optionState.equalsIgnoreCase( "Upgraded" ) ) {
%>				<td width="5%" align="center"><img alt="upgraded" id="img<%=chromeOptionCode%>" src="images/upgraded.gif" title="Upgraded" onClick='toggleOption("<%=chromeOptionCode%>")'></td>
<%
			}
%>
			<td width="40%" align="center"><%=optionDesc%></td>
			<td width="10%" align="center"><%=manufacturerOptionCode%></td>
			<td width="20%" align="center">$<%=optionInvoice%></td>
			<td width="20%" align="center">$<%=optionMsrp%></td>
		</tr>
<%
		}
%>
		</table>
		<br>
<%
	}
%>
</div>
<a name="pricing"/><h3 class="label">PRICING SUMMARY</h3>
<%
	String baseInvoice = Double.toString( configStyle.getStyle().getBaseInvoice() );
	String baseMsrp = Double.toString( configStyle.getStyle().getBaseMsrp() );
	String destCharge = Double.toString( configStyle.getStyle().getDestination() );

	String totalOptionInvoice = Double.toString( configStyle.getConfiguredOptionsInvoice() );
	String totalOptionMsrp = Double.toString( configStyle.getConfiguredOptionsMsrp() );

	String totalInvoice = Double.toString( configStyle.getConfiguredTotalInvoice() );
	String totalMsrp = Double.toString( configStyle.getConfiguredTotalMsrp() );
%>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr>
		<td align="center" width="70%">&nbsp;</td>
		<td align="center" width="15%"><b>Invoice</b></td>
		<td align="center" width="15%"><b>MSRP</b></td>
	</tr>
</table>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
	<tr>
		<td align="center" width="70%"><b>Base Price</b></td>
		<td align="center" width="15%"><span id="baseInvoice">$<%=baseInvoice%></span></td>
		<td align="center" width="15%"><span id="baseMsrp">$<%=baseMsrp%></span></td>
	</tr>
	<tr>
		<td align="center" width="70%"><b>Destination Charge</b></td>
		<td align="center" width="15%"><span id="destChargeInvoice">$<%=destCharge%></span></td>
		<td align="center" width="15%"><span id="destChargeMsrp">$<%=destCharge%></span></td>
	</tr>
	<tr>
		<td align="center" width="70%"><b>Total Options Price</b></td>
		<td align="center" width="15%"><span id="totalOptionInvoice">$<%=totalOptionInvoice%></span></td>
		<td align="center" width="15%"><span id="totalOptionMsrp">$<%=totalOptionMsrp%></span></td>
	</tr>
	<tr>
		<td align="center" width="70%"><b>Total Price( minus Destination )</b></td>
		<td align="center" width="15%"><span id="totalInvoice"><b>$<%=totalInvoice%></b></span></td>
		<td align="center" width="15%"><span id="totalMsrp"><b>$<%=totalMsrp%></b></span></td>
	</tr>
</table>
<div id="Configuration Checklist Div" style="display:none;visibility:hidden">
<a name="checklistHref"/><h3 class="label">CONFIGURATION CHECKLIST</h3>
<%
    ConfigurationCheckListItem[] items = configStyle.getConfigurationCheckListItems();
    for( int i = 0; i < items.length; i++ ){
        ConfigurationCheckListItem item = items[i];
        String satisfiedStateColor = item.isSatisfied() ? "White" : "Red";
%>
<table name="checklistTable" width="100%" border="1" cellspacing="0" cellpadding="2"  style="background-color: <%=satisfiedStateColor%>;">
    <tr>
		<td colspan="100%" align="left" width="15%" style="background-color: Lime;"><b><%=item.getItemName()%></b></td>
    </tr>
<%
        for( int j=0; j < item.getChromeOptionCodes().length; j++ ){
            String chromeOptionCode = item.getChromeOptionCodes()[j];
            for( int k=0; k < configStyle.getOptions().length; k++ ){
                Option option = configStyle.getOptions()[k];
                if( chromeOptionCode.equals( option.getChromeOptionCode() ) ){
	                String statusDescription = "&nbsp;";
                    if( option.getSelectionState() == OptionSelectionState.Selected || option.getSelectionState() == OptionSelectionState.Included || option.getSelectionState() == OptionSelectionState.Required ){
                          statusDescription = "-->";
                    }
                    String checklistOptionDescription = "";
                    for( int m=0; m < option.getDescriptions().length; m++ ){
	                    if( option.getDescriptions()[m].getType() == OptionDescriptionType.PrimaryName ){
		                 	checklistOptionDescription = option.getDescriptions()[m].getDescription();
		                 	break;
		                }
                    }
%>
    <tr>
    	<td align="right" width="10%" style="border-right: 1px solid black;"><b><span id="checklistStatus<%=option.getChromeOptionCode()%>"><%=statusDescription%></span></b></td>
		<td align="center" width="10%" style="border-right: 1px solid black;"><b><%=option.getOemOptionCode()%></b></td>
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
<div id="modalWinMask" style="position:absolute; width:100%; height:100%; top:0; left:0; padding:0; margin:0;background:black; Filter:Alpha(opacity=25); -moz-opacity:.25; opacity:.25; visibility:hidden; display:none; z-index:1;">&nbsp;</div>
<div align="center" id="conflictDialog" style="border-width:thin; border-top:1px solid; border-left:1px solid; border-right:1px solid; border-bottom:1px solid; position:absolute; width:600px; background:#FFFFFF; visibility:hidden; display:none; z-index:2;">
	<form name="conflictForm">
        <div id="conflictContent">
        </div>
    </form>
</div>
<br>
<input type="button" name="Save Style" value="Save Style" onClick='saveStyle("<%=description.replaceAll("\"", "")%>")'><span style="font-size:10px">&nbsp;( Saved Styles will appear in the Selector page )</span>
<div id="styleSaveDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%">Style Saved</td></tr></table>
</div>
<br>
<a href="ACCS_Sample_Selector.jsp"><b>Return to Selector</b></a><br>
<a href="ACCS_Sample_CF_Selector.jsp"><b>Return to Consumer Friendly Selector</b></a><br>
<a href="ACCS_Sample_Search.jsp"><b>Return to Search</b></a><br>
</body>
</html>