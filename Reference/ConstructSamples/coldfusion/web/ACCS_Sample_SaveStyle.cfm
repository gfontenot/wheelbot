<!--- get serialized State --->
<cfset configStyle = #Session.configurationStyle#>
<cfset serializedValue = configStyle.style.configurationState.serializedValue>
<cfset path = "C:/tmp/savedStyles/">

<!---create saved styles dir if it doesn't exist --->
<cfif DirectoryExists(path) EQ FALSE>
	<cfdirectory action = "create" directory = "#path#" >
</cfif>

<!--- delete old file --->
<cfset fileName = url.styleName>
<cfset filePathAndName = "#path#" & "#fileName#" & ".xml">
<cfif FileExists("#filePathAndName#") is "Yes"> 
   <cffile action="delete"  file="#filePathAndName#">
</cfif> 

<!--- create new file --->
<cffile action="write" file="#filePathAndName#" output="#serializedValue#">

<cfset result = "">
<cfoutput>#result#</cfoutput>