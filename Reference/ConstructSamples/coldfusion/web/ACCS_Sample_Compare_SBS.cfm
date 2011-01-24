<cfinclude template="ACCS_Sample_Util.cfm">

<cfset configService = createObject("webservice", "chromeConfigCompareService")>

<cfset accountInfo = Session.accountInfo>

<!--- get ids to compare --->
<cfset scratchListIds = url.scratchListIds>
<cfset scratchListIds = ListToArray(scratchListIds, "~~")>

<!--- get style state for each style --->
<cfset chromeStyleStates = ArrayNew(1)>
<cfloop index="i" from="1" to="#ArrayLen(scratchListIds)#">
    <cfset scratchListId = scratchListIds[i]>
    <cfset chromeStyleState = Session.scratchList[scratchListId]>
	<cfset ArrayAppend(chromeStyleStates, chromeStyleState)>
</cfloop>

<!--- get category Ids --->
<cfset categoriesRequest = StructNew()>
<cfset categoriesRequest.accountInfo = accountInfo>
<cfset categoryDefinitions = configService.getCategoryDefinitions( categoriesRequest )>
<cfset categoryIds = ArrayNew(1)>
<cfloop index="i" from="1" to="#ArrayLen(categoryDefinitions)#">
	<cfset ArrayAppend(categoryIds, categoryDefinitions[i].categoryId)>
</cfloop>

<!--- get tech spec Ids --->
<cfset techspecsRequest = StructNew()>
<cfset techspecsRequest.accountInfo = accountInfo>
<cfset techSpecDefs = configService.getTechnicalSpecificationDefinitions( techspecsRequest )>
<cfset techSpecIds = ArrayNew(1)>
<cfloop index="i" from="1" to="#ArrayLen(techSpecDefs)#">
	<cfset ArrayAppend(techSpecIds, techSpecDefs[i].titleId)>
</cfloop>

<!--- now do side by side compare --->
<cfset sideBySideComparisonRequest = StructNew()>
<cfset sideBySideComparisonRequest.accountInfo = accountInfo>
<cfset sideBySideComparisonRequest.comparisonConfigurationStates = chromeStyleStates>
<cfset sideBySideComparisonRequest.includeCategoryComparisons = TRUE>
<cfset sideBySideComparisonRequest.filteredCategoryIds = categoryIds>
<cfset sideBySideComparisonRequest.includeTechSpecComparisons = TRUE>
<cfset sideBySideComparisonRequest.filteredTechSpecTitleIds = techSpecIds>
<cfset sideBySideComparisonResult = configService.compareSideBySide( sideBySideComparisonRequest )>

<cfset comparisonConfigurations = sideBySideComparisonResult.comparisonConfigurations>
<cfset comparisonGroups= sideBySideComparisonResult.comparisonGroups>

<cfoutput>
	<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->
	<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
	<head>
	<title>Chrome Automative Comparison Service&trade;</title>
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
	<script type="text/javascript" src="js/compare.js"></script>
<cfoutput>
	</head>
	<body>
		<table width="100%" border="0" cellspacing="0" cellpadding="2">
			<tr><td align="center">
				<h1><img border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Comparison Service&trade;</h1>
			</td></tr>
			<tr><td align="center"><h1 class="label">Side By Side Comparison</h1></td></tr>
		</table>
		<!--- show links --->
		<table width="100%" border="0" cellspacing="0" cellpadding="2">
		<cfloop index="i" from="1" to="#ArrayLen(comparisonGroups)#">
			<cfset groupName = comparisonGroups[i].groupName>
			<cfset href = "##" & groupName & "Href">

			<tr><td><a href="#href#" id="#groupName#" onClick="showOrHideGroup(this.id)"><b>Show #groupName#</b></a></td></tr>

		</cfloop>
		</table>
		<br>

		<table width="100%" border="1" cellspacing="0" cellpadding="5">
			<!--- show stock photos --->
			<tr>
				<td width="250px">&nbsp;</td>
				<cfloop index="i" from="1" to="#ArrayLen(comparisonConfigurations)#">
					<cfset compareStyle = comparisonConfigurations[i].style>
					<cfset photoUrl = compareStyle.stockPhotoUrl>

					<td align="center" width="350px"><img height="75px" width="150px" src="#photoUrl#"></td>

				</cfloop>
			</tr>

			<!--- show style descriptions --->
			<tr>
				<td align="center"><b>Description</b></td>
				<cfloop index="i" from="1" to="#ArrayLen(comparisonConfigurations)#">
					<cfset compareStyle = comparisonConfigurations[i].style>
					<cfset description = compareStyle.modelYear & " " & compareStyle.divisionName & " " & compareStyle.modelName & " " & compareStyle.styleName>

					<td align="center">#description#</td>
				</cfloop>
			</tr>

			<!--- show invoice/msrp --->
			<tr>
				<td align="center"><b>Invoice/MSRP</b></td>
				<cfloop index="i" from="1" to="#ArrayLen(comparisonConfigurations)#">
					<cfset compareStyle = comparisonConfigurations[i].style>
					<cfset prices = "$" & compareStyle.baseInvoice & " / " & "$" & compareStyle.baseMsrp>

					<td align="center">#prices#</td>
				</cfloop>
			</tr>

			<!--- show destination --->
			<tr>
				<td align="center"><b>Destination Charge</b></td>

				<cfloop index="i" from="1" to="#ArrayLen(comparisonConfigurations)#">
					<cfset compareStyle = comparisonConfigurations[i].style>
					<cfset destinationCharge = "$" & compareStyle.destination>

					<td align="center">#destinationCharge#</td>
				</cfloop>
			</tr>
		</table>

		<!--- show Categories  --->
		<cfloop index="i" from="1" to="#ArrayLen(comparisonGroups)#">
			<cfset groupName = comparisonGroups[i].groupName>
			<cfset divName = groupName & "Div">
			<cfset href = groupName & "Href">

			<div id="#divName#" style="display:none;visibility:hidden">
			<a name="#href#"/>
			<h3 class="label">#UCase(groupName)#</h3>
			<table width="100%" border="1" cellspacing="0" cellpadding="2">

			<cfset comparisonItems = comparisonGroups[i].comparisonItems>
			<cfloop index="j" from="1" to="#ArrayLen(comparisonItems)#">
				<cfset featureDescription = comparisonItems[j].featureDescription>
				<cfset comparisonValues = comparisonItems[j].comparisonValues>

				<tr>
					<td align="center" width="250px"><b>#featureDescription#</b></td>

					<cfloop index="k" from="1" to="#ArrayLen(comparisonValues)#">
						<cfset value = comparisonValues[k]>
						<cfif value EQ "">
							<cfset value = "&nbsp;">
						</cfif>

						<td align="center" width="350px">#value#</td>
					</cfloop>
				</tr>
			</cfloop>
			</table>
			</div>
		</cfloop>

		<!--- show warranty.  --->

		<h3 class="label">WARRANTY</h3>
		<table width="100%" border="1" cellspacing="0" cellpadding="5">
			<tr>
				<td align="center" width="250px"><b>Warranty</b></td>
				<cfloop index="i" from="1" to="#ArrayLen(comparisonConfigurations)#">
					<cfset warranty = comparisonConfigurations[i].consumerInformation.warranty>
					<td align="center" width="350px">#warranty#</td>
				</cfloop>
			</tr>
		</table>

		<br>
		<a href="ACCS_Sample_Selector.cfm"><b>Return to Selector</b></a>
		<br>
	</body>
	</html>
</cfoutput>