<cfinclude template="ACCS_Sample_Config_New.cfm">

<cfset scratchListId = url.scratchListId>
<cfset filePathAndName = url.filePathAndName>

<cfif scratchListId EQ "none">
	<cfset configStyle = #loadSavedStyle( filePathAndName )#>
<cfelse>
	<cfset configStyle = #createNewStyle( scratchListId )#>
</cfif>

<cfoutput>
	<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->
	<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
	<head>
	<title>Chrome Automative Configuration Service&trade;</title>
</cfoutput>
	<style>
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
	<script type="text/javascript" src="js/request.js"></script>
	<script type="text/javascript" src="js/configure.js"></script>
	</head>
<cfoutput>
	<body>
	<table width="100%" border="0" cellspacing="0" cellpadding="2">
		<tr><td align="center">
			<h1><img border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Configuration Service&trade;</h1>
		</td></tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="2">
		<!--- show description --->
		<cfset description = configStyle.style.modelYear & " " & configStyle.style.divisionName & " " & configStyle.style.modelName & " " & configStyle.style.styleName>

		<tr><td align="center"><img src="#configStyle.style.stockPhotoUrl#"></td></tr>
		<tr><td align="center"><h1 class="label">#description#</h1></td></tr>
	</table>

	<!--- links --->
	<table width="100%" border="0" cellspacing="0" cellpadding="2">
		<tr><td><a href="##generalInfoHref" id="General Info" onClick='showOrHideGroup(this.id)'><b>Show General Info</b></a></td></tr>
		<tr><td><a href="##techSpecHref" id="Technical Specifications" onClick='showOrHideGroup(this.id)'><b>Show Technical_Specifications</b></a></td></tr>
		<tr><td><a href="##standardsHref" id="Standards" onClick='showOrHideGroup(this.id)'><b>Show Standards</b></a></td></tr>
		<tr><td><a href="##optionsHref" id="Options" onClick='showOrHideGroup(this.id)'><b>Show Options</b></a></td></tr>
		<tr><td><a href="##checklistHref" id="Configuration Checklist" onClick='showOrHideGroup(this.id)'><b>Show Configuration Checklist</b></a></td></tr>
		<tr><td><a href="##" id="Colors" onclick="showColorWindow()"><b>Show Colors</b></a></td></tr>
	</table>

	<div id="General Info Div" style="display:none;visibility:hidden">
		<!-- show General Info -->
		<a name="generalInfoHref"/><h3 class="label">GENERAL INFORMATION</h3>
		<table width="100%" border="1" cellspacing="0" cellpadding="2">
		    <cfif IsDefined("configStyle.consumerInformation.crashTestRating")>
				<tr><td valign="top" align="center" width="40%"><b>Crash Test Rating</b></td><td>#configStyle.consumerInformation.crashTestRating#</td></tr>
		    </cfif>
			<cfif IsDefined("configStyle.consumerInformation.rebate")>
				<tr><td valign="top" align="center" width="40%"><b>Rebate</b></td><td>#configStyle.consumerInformation.rebate#</td></tr>
		    </cfif>
		    <cfif IsDefined("configStyle.consumerInformation.recall")>
				<tr><td valign="top" align="center" width="40%"><b>Recall</b></td><td>#configStyle.consumerInformation.recall#</td></tr>
		    </cfif>
		    <cfif IsDefined("configStyle.consumerInformation.warranty")>
				<tr><td valign="top" align="center" width="40%"><b>Warranty</b></td><td>#configStyle.consumerInformation.warranty#</td></tr>
		    </cfif>
		</table>
	</div>

	<!--- TECH SPECS --->
	<div id="Technical Specifications Div" style="display:none;visibility:hidden">
		<a name="techSpecHref"/><h3 class="label">TECHNICAL SPECIFICATIONS</h3>
		<!--- store tech specs --->
		<cfset techSpecsStruct = StructNew()>
		<cfloop index="i" from="1" to="#ArrayLen(configStyle.technicalSpecifications)#">

			<cfset techSpec = configStyle.technicalSpecifications[i]>
			<cfset headerName = techSpec.headerName>

			<cfset techSpecGroupArray = ArrayNew(1)>
			<cfif structKeyExists(techSpecsStruct, headerName)>
				<cfset techSpecGroupArray = techSpecsStruct[headerName]>
			</cfif>

			<cfset ArrayAppend(techSpecGroupArray, techSpec)>
			<cfset insert = StructInsert(techSpecsStruct, headerName, techSpecGroupArray, 1)>
		</cfloop>


		<!--- show tech specs --->
		<cfloop collection="#techSpecsStruct#" item="key">
			<h4 class="label">#UCase(key)#</h4>
			<table width="100%" border="1" cellspacing="0" cellpadding="2">
			<cfset techSpecGroup = techSpecsStruct[key]>

			<cfloop index="i" from="1" to="#ArrayLen(techSpecGroup)#">
				<cfset techSpec = techSpecGroup[i]>
				<cfset techSpecTitle = techSpec.titleName>

				<cfset techSpecValue = techSpec.value>
				<cfif techSpecValue EQ "">
					<cfset techSpecValue = "&nbsp;">
				</cfif>

				<cfset techSpecUnit = "">
				<cftry>
					<cfset techSpecUnit = techSpec.measurementUnit>
					<cfcatch></cfcatch>
				</cftry>

				<cfif techSpecUnit NEQ "">
					<cfset techSpecUnit = "(" & techSpecUnit & ")">
				</cfif>

				<tr><td width="40%" align="center"><b>#techSpecTitle#&nbsp;#techSpecUnit#</b></td><td align="center">#techSpecValue#</td></tr>
			</cfloop>

			</table>
		</cfloop>
	</div>

	<!--- STANDARDS --->
	<div id="Standards Div" style="display:none;visibility:hidden">
		<a name="standardsHref"/><h3 class="label">STANDARDS</h3>
		<!--- store standards --->
		<cfset standardsStruct = StructNew()>
		<cfloop index="i" from="1" to="#ArrayLen(configStyle.standardEquipment)#">
			<cfset standard = configStyle.standardEquipment[i]>
			<cfset headerName = standard.headerName>

			<cfset standardGroupArray = ArrayNew(1)>
			<cfif structKeyExists(standardsStruct, headerName)>
				<cfset standardGroupArray = standardsStruct[headerName]>
			</cfif>

			<cfset ArrayAppend(standardGroupArray, standard)>
			<cfset insert = StructInsert(standardsStruct, headerName, standardGroupArray, 1)>
		</cfloop>


		<!--- show standards --->
		<cfloop collection="#standardsStruct#" item="key">
			<h4 class="label">#UCase(key)#</h4>
			<table width="100%" border="1" cellspacing="0" cellpadding="2">
			<cfset standardGroup = standardsStruct[key]>

			<cfloop index="i" from="1" to="#ArrayLen(standardGroup)#">
				<cfset standard = standardGroup[i]>
				<cfset standardDesc = standard.description>

				<tr><td align="left">#standardDesc#</td></tr>
			</cfloop>

			</table>
		</cfloop>
	</div>

	<!--- OPTIONS --->
	<div id="Options Div" style="display:none;visibility:hidden">
		<a name="optionsHref"/><h3 class="label">STANDARDS</h3>
		<!--- store options --->
		<cfset optionsStruct = StructNew()>
		<cfloop index="i" from="1" to="#ArrayLen(configStyle.options)#">
			<cfset option = configStyle.options[i]>
			<cfset headerName = option.headerName>

			<cfset optionGroupArray = ArrayNew(1)>
			<cfif structKeyExists(optionsStruct, headerName)>
				<cfset optionGroupArray = optionsStruct[headerName]>
			</cfif>

			<cfset ArrayAppend(optionGroupArray, option)>
			<cfset insert = StructInsert(optionsStruct, headerName, optionGroupArray, 1)>
		</cfloop>


		<!--- show options --->
		<cfloop collection="#optionsStruct#" item="key">
			<h4 class="label">#UCase(key)#</h4>
			<table width="100%" border="1" cellspacing="0" cellpadding="2">
				<tr>
					<td width="5%"  align="center"><b>State</b></>
					<td width="45%" align="center"><b>Description</b></td>
					<td width="10%" align="center"><b>Code</b></td>
					<td width="20%" align="center"><b>Invoice</b></td>
					<td width="20%" align="center"><b>MSRP</b></td>
				</tr>
			<cfset optionGroup = optionsStruct[key]>

			<cfloop index="i" from="1" to="#ArrayLen(optionGroup)#">
				<cfset option = optionGroup[i]>
				<cfset oemOptionCode = option.oemOptionCode>
				<cfset chromeOptionCode = option.chromeOptionCode>
				<cfset optionDesc = getFullOptionDescription(option)>
				<cfset optionInvoice = option.invoice>
				<cfset optionMsrp = option.msrp>

				<tr>
					<cfif option.selectionState EQ "Excluded">
						<td width="5%" align="center"><img id="img#chromeOptionCode#" src="images/excluded.gif" title="Excluded" onClick='toggleOption("#chromeOptionCode#")'></td>

					<cfelseif option.selectionState EQ "Included">
						<td width="5%" align="center"><img id="img#chromeOptionCode#" src="images/included.gif" title="Included" onClick='toggleOption("#chromeOptionCode#")'></td>

					<cfelseif option.selectionState EQ "Required">
						<td width="5%" align="center"><img id="img#chromeOptionCode#" src="images/required.gif" title="Required" onClick='toggleOption("#chromeOptionCode#")'></td>

					<cfelseif option.selectionState EQ "Selected">
						<td width="5%" align="center"><img id="img#chromeOptionCode#" src="images/selected.gif" title="Selected" onClick='toggleOption("#chromeOptionCode#")'></td>

					<cfelseif option.selectionState EQ "Unselected">
						<td width="5%" align="center"><img id="img#chromeOptionCode#" src="images/unselected.gif" title="Unselected" onClick='toggleOption("#chromeOptionCode#")'></td>

					<cfelseif option.selectionState EQ "Upgraded">
						<td width="5%" align="center"><img id="img#chromeOptionCode#" src="images/upgraded.gif" title="Upgraded" onClick='toggleOption("#chromeOptionCode#")'></td>
					</cfif>

					<td width="40%" align="center">#optionDesc#</td>
					<td width="10%" align="center">#oemOptionCode#</td>
					<td width="20%" align="center">#optionInvoice#</td>
					<td width="20%" align="center">#optionMsrp#</td>
				</tr>
			</cfloop>

			</table>
		</cfloop>
	</div>

	<!--- PRICING --->
	<h3 class="label">PRICING SUMMARY</h3>

	<cfset baseInvoice = configStyle.style.baseInvoice>
	<cfset baseMsrp = configStyle.style.baseMsrp>
	<cfset destCharge = configStyle.style.destination>

	<cfset totalOptionInvoice = configStyle.configuredOptionsInvoice>
	<cfset totalOptionMsrp = configStyle.configuredOptionsMsrp>

	<cfset totalInvoice = configStyle.configuredTotalInvoice>
	<cfset totalMsrp = configStyle.configuredTotalMsrp>

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
			<td align="center" width="15%"><span id="baseInvoice">$#baseInvoice#</span></td>
			<td align="center" width="15%"><span id="baseMsrp">$#baseMsrp#</span></td>
		</tr>
		<tr>
			<td align="center" width="70%"><b>Destination Charge</b></td>
			<td align="center" width="15%"><span id="destChargeInvoice">$#destCharge#</span></td>
			<td align="center" width="15%"><span id="destChargeMsrp">$#destCharge#</span></td>
		</tr>
		<tr>
			<td align="center" width="70%"><b>Total Options Price</b></td>
			<td align="center" width="15%"><span id="totalOptionInvoice">$#totalOptionInvoice#</span></td>
			<td align="center" width="15%"><span id="totalOptionMsrp">$#totalOptionMsrp#</span></td>
		</tr>
		<tr>
			<td align="center" width="70%"><b>Total Price</b></td>
			<td align="center" width="15%"><span id="totalInvoice"><b>$#totalInvoice#</b></span></td>
			<td align="center" width="15%"><span id="totalMsrp"><b>$#totalMsrp#</b></span></td>
		</tr>
	</table>

    <div id="Configuration Checklist Div" style="display:none;visibility:hidden">
    <a name="checklistHref"/><h3 class="label">CONFIGURATION CHECKLIST</h3>
    <cfset items = configStyle.configurationCheckListItems>
    <cfloop index="i" from="1" to="#ArrayLen(items)#">
        <cfset item = items[i]>
        <cfset satisfiedStateColor = IIf(item.satisfied,DE("White"),DE("Red"))>
        <table name="checklistTable" width="100%" border="1" cellspacing="0" cellpadding="2">
            <tr>
                <td colspan="100%" align="left" width="15%" style="background-color: Lime;"><b>#item.itemName#</b></td>
            </tr>
            <cfloop index="j" from="1" to="#ArrayLen(item.chromeOptionCodes)#">
                <cfset chromeOptionCode = item.chromeOptionCodes[j]>
                <cfloop index="k" from="1" to="#ArrayLen(configStyle.options)#">
                    <cfset option = configStyle.options[k]>
                    <cfif chromeOptionCode EQ option.chromeOptionCode>
                        <cfset statusDescription = "&nbsp;">
                        <cfif option.selectionState EQ "Selected" OR option.selectionState EQ "Included" OR option.selectionState EQ "Required">
                              <cfset statusDescription = "-->">
                        </cfif>
                        <cfset checklistOptionDescription = getPrimaryOptionDescription(option)>
                        <tr>
                            <td align="right" width="10%" style="border-right: 1px solid black;"><b><span id="checklistStatus#option.chromeOptionCode#">#statusDescription#</span></b></td>
                            <td align="center" width="10%" style="border-right: 1px solid black;"><b>#option.oemOptionCode#</b></td>
                            <td align="left" width="80%"><b>#checklistOptionDescription#</b></td>
                        </tr>
                        <cfbreak>
                    </cfif>
                </cfloop>
            </cfloop>
        </table><br>
    </cfloop>
    </div>

	<div id="modalWinMask" style="position:absolute; width:100%; height:100%; top:0; left:0; padding:0; margin:0;background:black; Filter:Alpha(opacity=25); -moz-opacity:.25; opacity:.25; visibility:hidden; display:none; z-index:1;">&nbsp;</div>
	<div align="center" id="conflictDialog" style="border-width:thin; border-top:1px solid; border-left:1px solid; border-right:1px solid; border-bottom:1px solid; position:absolute; width:600px; background:##FFFFFF; visibility:hidden; display:none; z-index:2;">
		<form name="conflictForm">
	        <div id="conflictContent">
	        </div>
	    </form>
	</div>
	<br>
	<input type="button" name="Save Style" value="Save Style" onClick='saveStyle("#description#")'><span style="font-size:10px">&nbsp;( Saved Styles will appear in the Selector page )</span>
	<div id="styleSaveDiv" style="visibility:hidden">
		<table width="100%"><tr><td width="100%">Style Saved</td></tr></table>
	</div>
	<br><br>
	<a href="ACCS_Sample_Selector.cfm"><b>Return to Selector</b></a>
	</body>
	</html>
</cfoutput>