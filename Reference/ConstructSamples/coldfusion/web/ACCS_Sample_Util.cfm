<cffunction name="getStyleReturnParameters" returnType="struct">

	<cfset styleReturnParameters = StructNew()>
	<cfset styleReturnParameters.includeStandards = TRUE>
	<cfset styleReturnParameters.includeOptions = TRUE>
	<cfset styleReturnParameters.includeOptionDescriptions = TRUE>
	<cfset styleReturnParameters.includeSpecialEquipmentOptions = TRUE>
	<cfset styleReturnParameters.includeColors = TRUE>
	<cfset styleReturnParameters.includeInvalidColors = TRUE>
	<cfset styleReturnParameters.includeEditorialContent = TRUE>
	<cfset styleReturnParameters.includeConsumerInfo = TRUE>
	<cfset styleReturnParameters.includeStructuredConsumerInfo = TRUE>
	<cfset styleReturnParameters.includeConfigurationChecklist = TRUE>
	<cfset styleReturnParameters.includeAdditionalImages = TRUE>
	<cfset styleReturnParameters.includeTechSpecs = TRUE>

	<cfreturn styleReturnParameters>

</cffunction>

<cffunction name="getFilterRules" returnType="struct"><cfargument name="orderAvailability" required="true">
	<cfset filterRules = StructNew()>
	<cfset filterRules.orderAvailability = orderAvailability>
	<cfreturn filterRules>
</cffunction>

<cffunction name="getStyleReturnParametersNone" returnType="struct">

	<cfset styleReturnParameters = StructNew()>
	<cfset styleReturnParameters.includeStandards = FALSE>
	<cfset styleReturnParameters.includeOptions = FALSE>
	<cfset styleReturnParameters.includeOptionDescriptions = FALSE>
	<cfset styleReturnParameters.includeSpecialEquipmentOptions = FALSE>
	<cfset styleReturnParameters.includeColors = FALSE>
	<cfset styleReturnParameters.includeInvalidColors = FALSE>
	<cfset styleReturnParameters.includeEditorialContent = FALSE>
	<cfset styleReturnParameters.includeConsumerInfo = FALSE>
	<cfset styleReturnParameters.includeStructuredConsumerInfo = FALSE>
	<cfset styleReturnParameters.includeConfigurationChecklist = FALSE>
	<cfset styleReturnParameters.includeAdditionalImages = FALSE>
	<cfset styleReturnParameters.includeTechSpecs = FALSE>

	<cfreturn styleReturnParameters>

</cffunction>

<cffunction name="getPrimaryOptionDescription" returnType="string"><cfargument name="option" required="true">
    <cfset optionDesc = "">
    <cfset descriptions = option.descriptions>
    <cfloop index="i" from="1" to="#ArrayLen(descriptions)#">
        <cfif descriptions[i].type EQ "PrimaryName">
            <cfset optionDesc = optionDesc & descriptions[i].description>
        </cfif>
    </cfloop>
    <cfreturn optionDesc>
</cffunction>

<cffunction name="getExtendedOptionDescription" returnType="string"><cfargument name="option" required="true">
    <cfset optionDesc = "">
    <cfset descriptions = option.descriptions>
    <cfloop index="i" from="1" to="#ArrayLen(descriptions)#">
        <cfif descriptions[i].type EQ "Extended">
            <cfset optionDesc = optionDesc & descriptions[i].description>
        </cfif>
    </cfloop>
    <cfreturn optionDesc>
</cffunction>

<cffunction name="getFullOptionDescription" returnType="string"><cfargument name="option" required="true">
    <cfset fullDescription = "">
    <cfset primaryDescription = getPrimaryOptionDescription(option)>
    <cfset extendedDescription = getExtendedOptionDescription(option)>
    <cfif Len(fullDescription) GT 0>
        <cfset fullDescription = primaryDescription & " " & extendedDescription>
    <cfelse>
        <cfset fullDescription = primaryDescription>
    </cfif>
    <cfreturn fullDescription>
</cffunction>