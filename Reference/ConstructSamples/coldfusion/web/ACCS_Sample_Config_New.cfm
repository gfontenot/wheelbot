<cfinclude template="ACCS_Sample_Util.cfm">

<!--- function createNewStyle  --->
<cffunction name="createNewStyle"><cfargument name="scratchListId" type="string" required="true">

    <cfset chromeStyleState = Session.scratchList[scratchListId]>

	<cfset configService=createObject("webservice", "chromeConfigCompareService")>

	<!---  get configuration  --->
	<cfset styleRequest = StructNew()>
	<cfset styleRequest.accountInfo = Session.accountInfo>
	<cfset styleRequest.configurationState = chromeStyleState>
	<cfset styleRequest.returnParameters = getStyleReturnParameters()>
	<cfset toggleResponse = configService.getStyleFullyConfigured( styleRequest )>
    <cfset configuration = toggleResponse.configuration>

	<!---  update scratch list --->
	<cflock timeout="20" scope="Session" type="Exclusive">
        <cfset a = StructInsert(Session.scratchList, scratchListId, configuration.style.configurationState, 1)>
	</cflock>

    <!---  set configuration --->
	<cflock timeout=20 scope="Session" type="Exclusive">
		<cfset Session.configurationStyle = configuration>
	</cflock>

	<cfreturn configuration>

</cffunction>


<!--- function loadSavedStyle  --->
<cffunction name="loadSavedStyle"><cfargument name="filePathAndName" type="string" required="true">

	<cfset configService=createObject("webservice", "chromeConfigCompareService")>

	<!--- get serialized state --->
	<cffile action="read" file="#filePathAndName#" variable="serializedState">

    <cfif NOT IsDefined("Session.accountInfo")>
        <cfset accountInfo = StructNew()>
        <cfset accountInfo.accountNumber = "0">
        <cfset accountInfo.accountSecret = "accountSecret">
        <cfset accountInfo.locale = StructNew()>
        <cfset accountInfo.locale.language = "en">
        <cfset accountInfo.locale.country = "US">
        <cfset accountInfo.sessionId = "">
        <cflock timeout="20" scope="Session" type="Exclusive">
            <cfset Session.accountInfo = accountInfo>
        </cflock>
    </cfif>

	<!---  get chromeStyleState using materializeStyleState--->
	<cfset materializeStateRequest = StructNew()>
	<cfset materializeStateRequest.accountInfo = Session.accountInfo>
	<cfset materializeStateRequest.serializedValue = serializedState>
	<cfset chromeStyleState = configService.materializeConfigurationState( materializeStateRequest )>

	<!---  now get configuration --->
	<cfset configRequest = StructNew()>
	<cfset configRequest.accountInfo = Session.accountInfo>
	<cfset configRequest.configurationState = chromeStyleState.configurationState>
	<cfset configRequest.returnParameters = getStyleReturnParameters()>

	<cfset toggleResponse = configService.getConfiguration( configRequest )>
	<cfset configuration = toggleResponse.configuration>

    <!---  set configuration --->
	<cflock timeout=20 scope="Session" type="Exclusive">
		<cfset Session.configurationStyle = configuration>
	</cflock>

	<cfreturn configuration>

</cffunction>
