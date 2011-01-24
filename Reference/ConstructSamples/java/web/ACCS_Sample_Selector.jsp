<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.File" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<title>Chrome Automotive Configuration/Comparison Service&trade;</title>
<style type="text/css">
body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	margin-right: 5%;
	margin-left: 5%;
}
</style>
<script type="text/javascript" src="js/request.js"></script>
<script type="text/javascript" src="js/selector.js"></script>
<script type="text/javascript" src="js/compare.js"></script>
<script type="text/javascript" src="js/configure.js"></script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center">
		<h1><img border="0" alt="Chrome" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Configuration/Comparison Service&trade;</h1>
		<!-- <h2>VIN Decoding Made Easy</h2> -->
	</td></tr>
</table>
<b>Select Styles:</b>
<table border="0" cellspacing="0" cellpadding="5">
<tr>
	<td>Locale:</td>
	<td>
		<select id="locale" onChange="selectLocale()">
			<option value="" selected></option>
			<option value="enUS">US (English)</option>
    		<option value="enCA">Canada (English)</option>
    		<option value="frCA">Canada (French)</option>
		</select>
	</td>
</tr>
<tr>
	<td>Mode:</td>
	<td>
		<select id="mode" onChange="selectMode()">
		</select>
	</td>
</tr>
<tr>
	<td>Year:</td>
	<td>
		<select id="year" onChange="selectYear(this.options[this.selectedIndex].value)">
		</select>
	</td>
</tr>
<tr>
	<td>Make:</td>
	<td>
		<select id="division" onChange="selectDivision(this.options[this.selectedIndex].value);">
		</select>
	</td>
</tr>
<tr>
	<td>Model:</td>
	<td>
		<select id="model" onChange="getStyles();">
		</select>
	</td>
</tr>
</table><br>
<form name="getStylesForm">
</form>
<br>
<div id="styleDiv" style="visibility:hidden">
	<table id="styleTableHeader" border="0" cellspacing="0" cellpadding="5" width="100%">
		<tr><td width="10%">&nbsp;</td><td align="center" width="70%"><b>Styles</b></td><td align="center" width="10%"><b>Invoice</b></td><td align="center" width="10%"><b>MSRP</b></td></tr>
	</table>
	<table id="styleTable" border="1" cellspacing="0" cellpadding="5" width="100%"></table>
</div>
<br>
<%
    //get all files in savedStyles directory
    String savedStylesDir = ".." + File.separator + "webapps" + File.separator +
		    request.getContextPath().substring( 1 ) + File.separator + "savedStyles" + File.separator;

    ArrayList savedStyles = new ArrayList();

    String[] fileList = new File(savedStylesDir).list();
    if (fileList != null && fileList.length > 0)
    {
        for (int i = 0; i < fileList.length; i++)
        {
            String fileName = fileList[i];
            savedStyles.add(fileName);
        }

%>
        <div id="savedStyleDiv" >
            <span><b>Saved Styles</b></span><br>
            <table id="savedStyleTable" border="1" cellspacing="0" cellpadding="5" width="100%">
    <%
                for( int i = 0; i < savedStyles.size(); i++ )
                {
                    String savedStylePathAndName = savedStylesDir + savedStyles.get( i );
                    String savedStyleFileName = savedStyles.get( i ).toString().substring( 0,  savedStyles.get( i ).toString().length() - 4 );
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
<br>
<div id="scratchListDiv" style="visibility:hidden"><b>Configure and Compare Styles:</b>
	<table id="scratchListTable" border="1" cellspacing="0" cellpadding="5" width="100%"></table>
	<table id="buttonsTable" border="0" cellspacing="0" cellpadding="5" width="100%">
		<tr>
			<td width="20%" align="center">
				<input type="button" id="configureButton" value="Configure" onClick="doConfigure()">
			</td>
			<td width="20%" align="center">
				<input type="button" id="compareSBSButton" value="Compare Side By Side" onClick="doCompareSBS()">
			</td>
			<td width="20%" align="center">
				<input type="button" id="compareABCButton" value="Compare Advantages/Disadvantages" onClick="doCompareABC()">
			</td>
			<td width="20%" align="center">
				<input type="button" id="removeButton" value="Remove" onClick="removeScratchListRow()">
			</td>
			<td width="20%" align="center">
				<input type="button" id="removeAllButton" value="Remove All" onClick="removeScratchListAll()">
			</td>
		</tr>
	</table>
</div>
<div id="pleaseWaitMsgDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%" align="center">Retrieving Data...Please Wait</td></tr></table>
</div>
</body>
</html>