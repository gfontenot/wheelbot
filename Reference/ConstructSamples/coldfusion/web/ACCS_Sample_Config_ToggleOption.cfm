<cfinclude template="ACCS_Sample_Util.cfm">
<cfset configService=createObject("webservice", "chromeConfigCompareService")>

<!---  get accountInfo --->
<cfset accountInfo = #Session.accountInfo#>

<!--- get code to toggle --->
<cfset originatingOptionCode = url.optionCode>

<!---  get chromeStyleState --->
<cfset configStyle = #Session.configurationStyle#>
<cfset chromeStyleState = configStyle.style.configurationState>

<!---  toggle option  --->
<cfset toggleOptionRequest = StructNew()>
<cfset toggleOptionRequest.accountInfo = accountInfo>
<cfset toggleOptionRequest.configurationState = chromeStyleState>
<cfset toggleOptionRequest.chromeOptionCode = originatingOptionCode>
<cfset toggleOptionRequest.returnParameters = getStyleReturnParameters()>

<cfset toggleOptionResponse = configService.toggleOption( toggleOptionRequest )>
<cfset newConfigStyle = toggleOptionResponse.configuration>

<!---  save configurationStyle --->
<cflock timeout=20 scope="Session" type="Exclusive">
	<cfset Session.configurationStyle = newConfigStyle>
</cflock>

<!--- handle option conflict --->
<cfset result = "">
<cfif toggleOptionResponse.requiresToggleToResolve EQ "YES">

	<!--- get conflicting option codes and descriptions --->
	<cfset conflictingOptionsAndDescs = "">
	<cfset conflictOptions = toggleOptionResponse.conflictResolvingChromeOptionCodes>
	<cfloop index="i" from="1" to="#ArrayLen( conflictOptions )#">
		<cfset conflictingOptionCode = conflictOptions[i]>

		<cfif i GT 1 AND i LTE #ArrayLen( conflictOptions )#>
			<cfset conflictingOptionsAndDescs = conflictingOptionsAndDescs & ";;">
		</cfif>

		<cfset conflictingOptionDesc = "">
		<cfset options = newConfigStyle.options>
		<cfloop index="j" from="1" to="#ArrayLen(options)#">
			<cfset option = options[j]>
			<cfif option.chromeOptionCode EQ conflictingOptionCode>
				<cfset conflictingOptionsAndDescs = conflictingOptionsAndDescs & conflictingOptionCode & "::" & getPrimaryOptionDescription(option)>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfloop>

	<!--- get manufacturer code and description for originating option code --->
	<cfset originatingManuCodeAndDesc = "">
	<cfset options = newConfigStyle.options>
	<cfloop index="j" from="1" to="#ArrayLen(options)#">
		<cfset option = options[j]>
		<cfif option.chromeOptionCode EQ originatingOptionCode>
			<cfset originatingManuCodeAndDesc = option.oemOptionCode & ";;" & getPrimaryOptionDescription(option)>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif toggleOptionResponse.originatingOptionAnAddition EQ "YES">
		<cfset result = "yesConflict" & "~~" & originatingManuCodeAndDesc & "~~add~~" & conflictingOptionsAndDescs>
	<cfelse>
		<cfset result = "yesConflict" & "~~" & originatingManuCodeAndDesc & "~~delete~~" & conflictingOptionsAndDescs>
	</cfif>
<cfelse>
	<!--- no conflict.  get all option codes and states --->
	<cfset options = newConfigStyle.options>
	<cfset allOptions = "">
	<cfloop index="i" from="1" to="#ArrayLen(options)#">
		<cfset option = options[i]>
		<cfset optionString = option.chromeOptionCode & "::" & option.selectionState>
		<cfif i GT 1 AND i LTE #ArrayLen(options)#>
			<cfset allOptions = allOptions & ";;">
		</cfif>

		<cfset allOptions = allOptions & optionString>
	</cfloop>

	<!--- get new pricing --->
	<cfset baseInvoice = newConfigStyle.style.baseInvoice>
	<cfset baseMsrp = newConfigStyle.style.baseMsrp>
	<cfset destCharge = newConfigStyle.style.destination>

	<cfset totalOptionInvoice = newConfigStyle.configuredOptionsInvoice>
	<cfset totalOptionMsrp = newConfigStyle.configuredOptionsMsrp>

	<cfset totalInvoice = newConfigStyle.configuredTotalInvoice>
	<cfset totalMsrp = newConfigStyle.configuredTotalMsrp>

	<cfset result = "noConflict" & "~~" & allOptions & "~~" & baseInvoice & "~~" & baseMsrp & "~~" & totalOptionInvoice & "~~" & totalOptionMsrp & "~~" & totalInvoice & "~~" & totalMsrp>
</cfif>

<cfoutput>#result#</cfoutput>