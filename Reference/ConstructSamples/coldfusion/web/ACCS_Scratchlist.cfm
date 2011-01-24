<cfinclude template="ACCS_Sample_Util.cfm">
<cfset configService=createObject("webservice", "chromeConfigCompareService")>
<cfset command = url.cmd>

<cfif NOT IsDefined("Session.scratchList")>
    <cfset scratchList = StructNew()>
	<cflock timeout="20" scope="Session" type="Exclusive">
		<cfset Session.scratchList = scratchList>
	</cflock>
</cfif>

<cfif command EQ "add">

    <cfset styleId = url.styleId>

	<cfset styleRequest = StructNew()>
	<cfset styleRequest.accountInfo = Session.accountInfo>
	<cfset styleRequest.orderAvailability = Session.orderAvailability>
	<cfset styleRequest.styleId = styleId>
	<cfset styleRequest.returnParameters = getStyleReturnParametersNone()>
    <cfset configElement = configService.getConfigurationByStyleId(styleRequest)>

    <cfset scratchListId = styleId & "-" & CreateUUID()>
    <cfset a = StructInsert(Session.scratchList, scratchListId, configElement.configuration.style.configurationState, 1)>
    <cfset result = "success" & "~~" & scratchListId>

<cfelseif command EQ "remove">

    <cfset result = "fail">
    <cfset scratchListId = url.scratchListId>
    <cfset rc = StructDelete(Session.scratchList, scratchListId)>
    <cfset result = "success">

<cfelseif command EQ "clear">

    <cfset result = "fail">
    <cfset rc = StructDelete(Session, "scratchList")>
    <cfset result = "success">

</cfif>

<cfoutput>#result#</cfoutput>
