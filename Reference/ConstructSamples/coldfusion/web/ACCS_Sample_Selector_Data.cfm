<cfinclude template="ACCS_Sample_Util.cfm">

<cfset configService=createObject("webservice", "chromeConfigCompareService")>
<cfset dataType = url.data>
<cfset result = "">

<cfif dataType EQ "locale">
	<!---  get accountInfo --->
	<cfset accountInfo = StructNew()>
	<cfset accountInfo.accountNumber = "0">
	<cfset accountInfo.accountSecret = "accountSecret">

	<cfset accountInfo.locale = StructNew()>
	<cfset accountInfo.locale.language = "en">
	<cfset accountInfo.locale.country = "US">
	<cfset accountInfo.sessionId = "">

	<cfset locale = url.locale>

	<cfif locale EQ "enCA">
	   <cfset accountInfo.locale.country = "CA">
	<cfelseif locale EQ "frCA">
	    <cfset accountInfo.locale.language = "fr">
	    <cfset accountInfo.locale.country = "CA">
	</cfif>

	<!---  save accountInfo --->
	<cflock timeout="20" scope="Session" type="Exclusive">
		<cfset Session.accountInfo = accountInfo>
	</cflock>

<cfelseif dataType EQ "orderAvailability">
	<!---  get orderAvailability --->
	<cfset orderAvailability = url.orderAvailability>

	<!---  save orderAvailability --->
	<cflock timeout="20" scope="Session" type="Exclusive">
		<cfset Session.orderAvailability = orderAvailability>
	</cflock>

<cfelseif dataType EQ "years">
	<!---  get accountInfo and orderAvailability --->
	<cfset accountInfo = #Session.accountInfo#>
	<cfset orderAvailability = #Session.orderAvailability#>
	<cfset result = "">

	<!---  get modelYears --->
	<cfset modelYears = ArrayNew(1)>

	<cfset modelYearsRequest = StructNew()>
	<cfset modelYearsRequest.accountInfo = accountInfo>
	<cfset modelYearsRequest.filterRules = getFilterRules(orderAvailability)>

	<cfset modelYears = configService.getModelYears(modelYearsRequest)>
	<cfloop index="row" from="1" to="#ArrayLen(modelYears)#">
		<cfif row GT 1 AND row LTE #ArrayLen(modelYears)#>
			<cfset result = result & ";;">
		</cfif>

		<cfset result = result & modelYears[row] & "~~" & modelYears[row]>
	</cfloop>

<cfelseif dataType EQ "divisions">
	<!---  get accountInfo and orderAvailability --->
	<cfset accountInfo = #Session.accountInfo#>
	<cfset orderAvailability = #Session.orderAvailability#>

	<cfset modelYear = url.modelYear>
	<cfset result = "">

	<!---  get divisions --->
	<cfset divisions = ArrayNew(1)>

	<cfset divisionsRequest = StructNew()>
	<cfset divisionsRequest.accountInfo = accountInfo>
    <cfset divisionsRequest.filterRules = getFilterRules(orderAvailability)>
	<cfset divisionsRequest.modelYear = modelYear>

	<cfset divisions = configService.getDivisions(divisionsRequest)>
	<cfloop index="row" from="1" to="#ArrayLen(divisions)#">
		<cfif row GT 1 AND row LTE #ArrayLen(divisions)#>
			<cfset result = result & ";;">
		</cfif>

		<cfset result = result & divisions[row].divisionId & "~~" & divisions[row].divisionName>
	</cfloop>

<cfelseif dataType EQ "models">
	<!---  get accountInfo and orderAvailability --->
	<cfset accountInfo = #Session.accountInfo#>
	<cfset orderAvailability = #Session.orderAvailability#>

	<cfset modelYear = url.modelYear>
	<cfset divisionId = url.divisionId>
	<cfset result = "">

	<!---  get models --->
	<cfset models = ArrayNew(1)>

	<cfset modelsRequest = StructNew()>
	<cfset modelsRequest.accountInfo = accountInfo>
	<cfset modelsRequest.modelYear = modelYear>
	<cfset modelsRequest.divisionId = divisionId>
	<cfset modelsRequest.filterRules = getFilterRules(orderAvailability)>

	<cfset models = configService.getModelsByDivision(modelsRequest)>
	<cfloop index="row" from="1" to="#ArrayLen(models)#">
		<cfif row GT 1 AND row LTE #ArrayLen(models)#>
			<cfset result = result & ";;">
		</cfif>

		<cfset result = result & models[row].modelName & "~~" & models[row].modelId>
	</cfloop>

<cfelseif dataType EQ "styles">
	<!---  get accountInfo and orderAvailability --->
	<cfset accountInfo = #Session.accountInfo#>
	<cfset orderAvailability = #Session.orderAvailability#>

	<cfset modelYear = url.modelYear>
	<cfset divisionName = url.divisionName>
	<cfset modelId = url.modelId>
	<cfset modelName = url.modelName>
	<cfset result = "">

	<!---  get styles --->
	<cfset styles = ArrayNew(1)>

	<cfset stylesRequest = StructNew()>
	<cfset stylesRequest.accountInfo = accountInfo>
	<cfset stylesRequest.modelId = modelId>
	<cfset stylesRequest.filterRules = getFilterRules(orderAvailability)>

	<cfset styles = configService.getStyles(stylesRequest)>

	<cfloop index="row" from="1" to="#ArrayLen(styles)#">
		<cfset style = styles[row]>
		<cfset invoice = "">
		<cfset msrp = "">

        <cfset invoice = "$" & style.baseInvoice>
        <cfset msrp = "$" & style.baseMsrp>

		<cfif row GT 1 AND row LTE #ArrayLen(styles)#>
			<cfset result = result & ";;">
		</cfif>

		<cfset result = result & modelYear & "~~" & divisionName & "~~" & modelName & "~~" & style.styleName & "~~" & invoice & "~~" & msrp & "~~" & style.styleId>
	</cfloop>

</cfif>

<cfoutput>#result#</cfoutput>