<cfset configStyle = #Session.configurationStyle#>

<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

	<html xmlns="http://www.w3.org/1999/xhtml" >
	<head runat="server">
	    <title>Available Colors</title>
	</head>
	<body>
	<label style="color:##326BAD; font-size:large">Available Color Combinations</label><br/><br/>
	<!--- for each color combination, get same exterior color combo and store in struct --->
	<cfset colorsStruct= StructNew()>
	<cfset colorCombinations = configStyle.colorCombinations>

	<cfloop index="i" from="1" to="#ArrayLen(colorCombinations)#">
		<cfset colorCombination = colorCombinations[i]>

		<cfset exteriorColorKey = colorCombination.primaryExteriorColor.name & " (" & colorCombination.primaryExteriorColor.manufacturersCode & ")~" & colorCombination.primaryExteriorColor.swatchUrl>
		<cfset exteriorColorKey = exteriorColorKey & "~" & colorCombination.primaryExteriorColor.rgbHexCode>
		<cfset interiorColorName = colorCombination.interiorColor.name>

	    <cfset interiorColorsList = ArrayNew(1)>
	    <cfif structKeyExists( colorsStruct, exteriorColorKey )>
	    	<cfset interiorColorsList = colorsStruct[exteriorColorKey]>
		</cfif>

		<cfset ArrayAppend(interiorColorsList, interiorColorName)>
		<cfset insert = StructInsert(colorsStruct, exteriorColorKey, interiorColorsList, 1)>
	</cfloop>

	<!--- now show colors --->
	<cfloop collection="#colorsStruct#" item="key">
		<cfset exteriorColorItems = ListToArray(key, "~")>
		<cfset interiorColorGroup = colorsStruct[key]>

		<table width="100%" border="1" cellspacing="0" cellpadding="2">
    		<tr><td align="center" style="width:30%"><b>Exterior Color</b></td><td align="center"><b>Interior Colors</b></td></tr>
   			<tr>
       	        <td>
           			<table width="100%" border="0" cellspacing="0" cellpadding="2">
               			<tr><td align="center">#exteriorColorItems[1]# <img alt="#exteriorColorItems[1]#" width="10px" height="10px" src="#exteriorColorItems[2]#"/></td></tr>
               			<tr><td align="center" bgcolor="#chr(35) & exteriorColorItems[3]#">&nbsp;</td></tr>
           			</table>
       			</td>
       			<td>
           			<table width="100%" border="1" cellspacing="0" cellpadding="2">
               			<tr>
			                <cfloop index="i" from="1" to="#ArrayLen(interiorColorGroup)#">
								<cfset interiorColor = interiorColorGroup[i]>
			                    <td align="center">#interiorColor#</td>
			                </cfloop>
		                </tr>
	    	        </table>
	        	</td>
	    	</tr>
		</table>
		<br>
	</cfloop>
	<br>
	<input type="button" value="Close Window" onclick="window.close()">
	</body>
	</html>
</cfoutput>