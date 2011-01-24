<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ACCS_Sample_Selector.aspx.cs" Inherits="ACCS_Sample_Selector" %>
<%@ Import Namespace = "System.IO" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<title>Chrome Automotive Configuration/Comparison Service&trade;</title>
<style type="text/css">
body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	margin-top: 0px;
	margin-right: 5%;
	margin-bottom: 0px;
	margin-left: 5%;
}
</style>
<script type="text/javascript" src="request.js"></script>
<script type="text/javascript" src="selector.js"></script>
<script type="text/javascript" src="configure.js"></script>
<script type="text/javascript" src="compare.js"></script>
</head>
<body>
<table style="width:100%;" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center">
		<h1><img alt="Chrome" style="border:0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif"/>Automotive Configuration/Comparison Service&trade;</h1>
	</td></tr>
</table>
<b>Select Styles:</b>
<table border="0" cellspacing="0" cellpadding="5">
<tr>
	<td>Locale:</td>
	<td>
		<select id="locale" onchange="selectLocale()">
			<option value="" selected="selected"></option>
			<option value="enUS">US (English)</option>
    		<option value="enCA">Canada (English)</option>
    		<option value="frCA">Canada (French)</option>
		</select>
	</td>
</tr>
<tr>
	<td>Mode:</td>
	<td>
		<select id="mode" onchange="selectMode()">
		</select>
	</td>
</tr>
<tr>
	<td>Year:</td>
	<td>
		<select id="year" onchange="selectYear(this.options[this.selectedIndex].value)">
		</select>
	</td>
</tr>
<tr>
	<td>Make:</td>
	<td>
		<select id="division" onchange="selectDivision(this.options[this.selectedIndex].value);">
		</select>
	</td>
</tr>
<tr>
	<td>Model:</td>
	<td>
		<select id="model" onchange="getStyles()">
		</select>
	</td>
</tr>
</table>
<br/>
<div id="styleDiv" style="visibility:hidden">
	<table id="styleTableHeader" border="0" cellspacing="0" cellpadding="5" style="width:100%;">
		<tr><td style="width:10%;">&nbsp;</td><td align="center" style="width:70%;"><b>Styles</b></td><td align="center" style="width:10%"><b>Invoice</b></td><td align="center" style="width:10%"><b>MSRP</b></td></tr>
	</table>
	<table id="styleTable" border="1" cellspacing="0" cellpadding="5" style="width:100%;"></table>
</div>
<br/>
<%
		//get saved styles		
        String path = @"C:\tmp\savedStyles\";
        DirectoryInfo dir = new DirectoryInfo( path );

        FileInfo[] styleFiles = null;
        try
        {
		    styleFiles = dir.GetFiles();
        }
        catch( IOException ){}
    
		if (styleFiles != null && styleFiles.Length > 0)
		{
%>
            <div id="savedStyleDiv" >
			    <span><b>Saved Styles</b></span><br/>
			    <table id="savedStyleTable" border="1" cellspacing="0" cellpadding="5" width="100%">
    <%
			    foreach( FileInfo styleFile in styleFiles ) {

				    String savedStylePathAndName = styleFile.FullName;
				    String savedStyleFileName = styleFile.Name.Substring(0, styleFile.Name.Length - 4);
    %>
				    <tr id="row_<%=savedStylePathAndName%>" >
                        <td align="center" width="10%"><input type="button" id="con_<%=savedStylePathAndName%>" value="Configure" onClick="doConfigure(this.id.substring( 4 ) )"></td>
                        <td align="center" width="10%"><input type="button" id="del_<%=savedStylePathAndName%>" value="Delete" onClick="deleteSavedStyle(this.id.substring( 4 ) )"></td>
                        <td align="center"><%=savedStyleFileName%></td>
                    </tr>
    <%
			    }
    %>
			    </table>
			</div>
<%
		}
%>			
<br/>
<div id="scratchListDiv" style="visibility:hidden"><b>Configure and Compare Styles:</b>
	<table id="scratchListTable" border="1" cellspacing="0" cellpadding="5" style="width:100%;"></table>
	<table id="buttonsTable" border="0" cellspacing="0" cellpadding="5" style="width:100%;">
		<tr>
			<td style="width:20%;" align="center">
				<input type="button" id="configureButton" value="Configure" onclick="doConfigure()"/>
			</td>
			<td style="width:20%;" align="center">
				<input type="button" id="compareSBSButton" value="Compare Side By Side" onclick="doCompareSBS()"/>
			</td>
			<td style="width:20%;" align="center">
				<input type="button" id="compareABCButton" value="Compare Advantages/Disadvantages" onclick="doCompareABC()"/>
			</td>
			<td style="width:20%;" align="center">
				<input type="button" id="removeButton" value="Remove" onclick="removeScratchListRow()"/>
			</td>
			<td style="width:20%;" align="center">
				<input type="button" id="removeAllButton" value="Remove All" onclick="removeScratchListAll()"/>
			</td>
		</tr>
	</table>
</div>
<div id="pleaseWaitMsgDiv" style="visibility:hidden">
	<table width="100%"><tr><td style="width:100%;" align="center">Retrieving Data...Please Wait</td></tr></table>
</div>
</body>
</html>

