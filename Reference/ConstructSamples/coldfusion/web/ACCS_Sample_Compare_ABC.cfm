<cfinclude template="ACCS_Sample_Util.cfm">

<cfset compareService = createObject("webservice", "chromeConfigCompareService")>

<!---  get accountInfo --->
<cfset accountInfo = Session.accountInfo>

<!--- get ids to compare --->
<cfset primaryId = url.primaryScratchListId>
<cfset scratchListIds = url.scratchListIds>
<cfset scratchListIdsList = ListToArray(scratchListIds, "~~")>

<!--- get style state for each style --->
<cfset primaryStyleState = Session.scratchList[primaryId]>
<cfset compareStyleStates = ArrayNew(1)>
<cfloop index="i" from="1" to="#ArrayLen(scratchListIdsList)#">
    <cfset compareId = scratchListIdsList[i]>
	<cfset chromeStyleState = Session.scratchList[compareId]>
	<cfset ArrayAppend(compareStyleStates, chromeStyleState)>
</cfloop>

<!--- do advantage based compare --->
<cfset compareRequest = StructNew()>
<cfset compareRequest.accountInfo = accountInfo>
<cfset compareRequest.ruleSetName = "chromerules">
<cfset compareRequest.pivotConfigurationState = primaryStyleState>
<cfset compareRequest.comparisonConfigurationStates = compareStyleStates>
<cfset advantageCompareResult = compareService.compareAdvantages( compareRequest )>

<cfset pivotStyle = advantageCompareResult.pivotConfiguration.style>
<cfset styleComparisons = advantageCompareResult.comparisons>

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
				<h1><img style="border:0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif" alt="Chrome"/>Automotive Comparison Service&trade;</h1>
			</td></tr>
			<tr><td align="center"><h1 class="label">Advantage Based Comparison</h1></td></tr>
		</table>
		<table width="100%" border="1" cellspacing="0" cellpadding="5">
			<!--- show photos --->
			<tr>
			    <td>&nbsp;</td>
                <td align="center"><img alt="Photo" height="75px" width="150px" src="#pivotStyle.stockPhotoUrl#"/></td>
                <cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
                    <cfset style = styleComparisons[i].comparisonConfiguration.style>
                    <td align="center"><img alt="Photo" height="75px" width="150px" src="#style.stockPhotoUrl#"/></td>
                </cfloop>
			</tr>

			<!--- show description --->
			<tr>
			    <td align="center"><b>Description</b></td>
                <cfset primaryDesc = pivotStyle.modelYear & " " & pivotStyle.divisionName & " " & pivotStyle.modelName & " " & pivotStyle.styleName>
                <td align="center">#primaryDesc#</td>
                <cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
                    <cfset style = styleComparisons[i].comparisonConfiguration.style>
                    <cfset description = style.modelYear & " " & style.divisionName & " " & style.modelName & " " & style.styleName>
                    <td align="center">#description#</td>
                </cfloop>
			</tr>

			<!--- show prices --->
			<tr>
			    <td align="center"><b>Invoice/MSRP</b></td>
			    <cfset prices = "$" & pivotStyle.baseInvoice & " / " & "$" & pivotStyle.baseMsrp>
			    <td align="center">#prices#</td>
                <cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
                    <cfset style = styleComparisons[i].comparisonConfiguration.style>
                    <cfset prices = "$" & style.baseInvoice & " / " & "$" & style.baseMsrp>
                    <td align="center">#prices#</td>
                </cfloop>
			</tr>
			<!--- show destination --->
			<tr>
			    <td align="center"><b>Destination Charge</b></td>
                <cfset destination = "$" & pivotStyle.destination>
                <td align="center">#destination#</td>
                <cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
                    <cfset style = styleComparisons[i].comparisonConfiguration.style>
                    <cfset destination = "$" & style.destination>
                    <td align="center">#destination#</td>
                </cfloop>
			</tr>

			<tr>
			    <td align="center"><b>Select Primary</b></td>
			    <td align="center"><input type="radio" name="primaryButton" checked="checked" /></td>
                <cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
                    <td align="center"><input type="radio" name="primaryButton"/></td>
                </cfloop>
			</tr>

		</table>

		<table width="100%" border="0" cellspacing="0" cellpadding="5">
			<tr><td align="center"><input type="button" name="newABC_Compare" value="Compare" onclick='doNewABC_Compare("#primaryScratchListId & "~~" & scratchListIds#")'/></td></tr>
		</table>
		<div id="pleaseWaitMsgDiv" style="visibility:hidden">
			<table width="100%"><tr><td style="width:100%" align="center">Retrieving Data...Please Wait</td></tr></table>
		</div>

		<!--- show advantages --->
		<h3 class="label">ADVANTAGES</h3>
		<cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
		    <cfset styleComparison = styleComparisons[i]>
		    <cfset style = styleComparison.comparisonConfiguration.style>
		    <cfset description = style.modelYear & " " & style.divisionName & " " & style.modelName & " " & style.styleName>
            <b>The #primaryDesc# has the following advantages over the #description#:</b>
            <table width="100%" border="1" cellspacing="0" cellpadding="5">
            	<cfset noneFound = TRUE>
            	<cftry>
            		<cfset comparisonItems = styleComparison.comparisonItems>
	                <cfloop index="j" from="1" to="#ArrayLen(comparisonItems)#">
	                    <cfset item = comparisonItems[j]>
	                    <cfset resultType = item.comparisonResultType>
	                    <cfif resultType EQ "Advantage">
	                    	<cfset noneFound = FALSE>
	                        <cfset naturalLanguage = item.naturalLanguageDescription>
	                        <tr><td align="left">#naturalLanguage#</td></tr>
	                    </cfif>
	                </cfloop>
					<cfcatch>
					</cfcatch>
				</cftry>
				<cfif noneFound>
					<tr><td align="left">No Advantages found.</td></tr>
				</cfif>
            </table>
            <br>
        </cfloop>

		<!--- show disadvantages --->
		<h3 class="label">DISADVANTAGES</h3>
		<cfloop index="i" from="1" to="#ArrayLen(styleComparisons)#">
		    <cfset styleComparison = styleComparisons[i]>
		    <cfset style = styleComparison.comparisonConfiguration.style>
		    <cfset description = style.modelYear & " " & style.divisionName & " " & style.modelName & " " & style.styleName>
		    <b>The #primaryDesc# has the following advantages over the #description#:</b>
		    <table width="100%" border="1" cellspacing="0" cellpadding="5">
		    	<cfset noneFound = TRUE>
			    <cftry>
			   		<cfset comparisonItems = styleComparison.comparisonItems>
	                <cfloop index="j" from="1" to="#ArrayLen(comparisonItems)#">
	                    <cfset item = comparisonItems[j]>
	                    <cfset resultType = item.comparisonResultType>
	                    <cfif resultType EQ "Disadvantage">
	                    	<cfset noneFound = FALSE>
	                        <cfset naturalLanguage = item.naturalLanguageDescription>
	                        <tr><td align="left">#naturalLanguage#</td></tr>
	                    </cfif>
	                </cfloop>
					<cfcatch>
					</cfcatch>
				</cftry>
				<cfif noneFound>
					<tr><td align="left">No Disadvantages found.</td></tr>
				</cfif>
			</table>
            <br>
        </cfloop>

		<br>
		<a href="ACCS_Sample_Selector.cfm"><b>Return to Selector</b></a>
		<br>
	</body>
	</html>
</cfoutput>