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

fieldset
    {
        border: 1px solid blue;
        padding: 5px 5px 5px 5px;
    }
</style>
<script type="text/javascript" src="js/request.js"></script>
<script type="text/javascript" src="js/search.js"></script>
<script type="text/javascript" src="js/compare.js"></script>
<script type="text/javascript" src="js/configure.js"></script>
<script type="text/javascript" src="js/dialog.js"></script>
</head>

<body onLoad="selectLocale()">

<table width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center">
		<h1><img border="0" alt="Chrome" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Configuration/Comparison Service&trade;</h1>
		<!-- <h2>VIN Decoding Made Easy</h2> -->
	</td></tr>
</table>

<fieldset>
    <legend><b>Search Parameters:</b></legend>
    <div >
        <table border="0" cellspacing="0" cellpadding="5">
            <tr>
                <td><b>Search Type:</b></td>
                <td><input type="radio" name="searchType" checked value="searchStyles">Styles&nbsp;<input type="radio" name="searchType" value="searchModels">Models</td>
            </tr>
            <tr>
                <td><b>Filters:</b></td>
                <td><input type="checkbox" id="filterTBD" checked >Filter TBD Results&nbsp;&nbsp;
                    <input type="checkbox" onclick="postalFilterClicked()" id="filterPostalCode" >Filter By Postal Code&nbsp;<input style="width: 75px" type="text" disabled id="postalCode" >&nbsp;&nbsp;
                    Max Number of Results&nbsp;<input style="width:75px" type="text" id="maxNumResults" value="200" >
                </td>
            </tr>
            <tr>
                <td><b>Locale:</b></td>
                <td>
                    <select id="locale" onChange="selectLocale()">
                        <option value="enUS" selected>US (English)</option>
                        <option value="enCA">Canada (English)</option>
                        <option value="frCA">Canada (French)</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td><b>Mode:</b></td>
                <td>
                    <select id="mode" disabled onChange="selectMode()">
                    </select>
                </td>
            </tr>
        </table>
    </div>
</fieldset>

<br>
<fieldset>
    <legend><b>Search Criteria Work List:</b></legend>
    <div >
        <b>Step 1:&nbsp;&nbsp;</b>Use this area to add criteria to your working list.  You can then use the criteria
        in this working list as building blocks for constructing your final search criteria
        that will appear in the "Search Criteria in Effect" box below.  You must have at least one
        search criterion in effect to perform a search.
        <br>
        <br>
        <table border="0" cellspacing="0" cellpadding="5" width="100%" >
            <tr width="100%" >
                <td nowrap width="150px" ><b>Criterion Name:</b></td>
                <td width="300px" >
                    <select id="criterion" disabled onChange="criterionSelected()">
                        <option value="" selected></option>
                    </select>
                </td>
                <td width="500px" >
                    <b>Criterion Type:</b>&nbsp;&nbsp;<span id="criterionType" ></span>
                </td>
            </tr>
            <tr>
                <td colspan="100" >
                    <b>Importance:</b>&nbsp;&nbsp;<input type="radio" name="mustHave" checked value="true" >Must Have&nbsp;&nbsp;<input type="radio" name="mustHave" value="false" >Must Not Have
                </td>
            </tr>
            <tr id="BooleanRow" style="display:none" >
                <td colspan="100" >
                    <b>Value:</b>&nbsp;&nbsp;<input type="radio" name="booleanValue" checked value="true" >true&nbsp;&nbsp;<input type="radio" name="booleanValue" value="false" >false
                </td>
            </tr>
            <tr id="StringRow" style="display:none" >
                <td colspan="100" >
                    <b>Value:</b>&nbsp;&nbsp;<input type="text" value="" id="stringValue" >
                </td>
            </tr>
            <tr id="StringRowWithOptions" style="display:none" >
                <td colspan="100" >
                    <b>Value:</b>&nbsp;&nbsp;<select id="stringOptionValues"></select>
                </td>
            </tr>
            <tr id="NumberRangeRow" style="display:none" >
                <td colspan="100" >
                    <b>Minimum (<span id="numMin" ></span>):</b>&nbsp;&nbsp;<input type="text" value="" id="numMinValue" >&nbsp;&nbsp;<b>Maximum (<span id="numMax" ></span>):</b>&nbsp;&nbsp;<input type="text" value="" id="numMaxValue" >
                </td>
            </tr>
            <tr id="MoneyRangeRow" style="display:none" >
                <td colspan="100" >
                    <b>Minimum ($<span id="moneyMin" ></span>):</b>&nbsp;&nbsp;<input type="text" value="" id="moneyMinValue" >&nbsp;&nbsp;<b>Maximum ($<span id="moneyMax" ></span>):</b>&nbsp;&nbsp;<input type="text" value="" id="moneyMaxValue" >
                </td>
            </tr>
            <tr id="TechnicalSpecificationRangeRow" style="display:none" >
                <td colspan="100" >
                    <b>Minimum (<span id="techSpecMin" ></span>):</b>&nbsp;&nbsp;<input type="text" value="" id="techSpecMinValue" >&nbsp;&nbsp;<b>Maximum (<span id="techSpecMax" ></span>):</b>&nbsp;&nbsp;<input type="text" value="" id="techSpecMaxValue" >
                </td>
            </tr>
            <tr >
                <td align="left" colspan="100" >
                    <input type="button" id="addCriterionBtn" disabled value="Add Criterion to List" onclick="addCriterion()" >&nbsp;&nbsp;
                </td>
            </tr>

            <tr>
                <td colspan="100" >
                    <hr>
                </td>
            </tr>
            <tr>
                <td colspan="100" >
                    <table id="criteriaTable" width="100%" >

                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="100" >
                    <input type="button" id="delCriteriaBtn" disabled value="Delete" onclick="processCriteriaList( ACTION_DELETE )" >&nbsp;&nbsp;
                    <input type="button" id="genCriteriaBtn" disabled value="Add as Stand-Alone Criterion" onclick="processCriteriaList( ACTION_GENERAL_CRITERIA )" >&nbsp;&nbsp;
                    <input type="button" id="andCriteriaBtn" disabled value="Add as Grouped AND Criterion" onclick="processCriteriaList( ACTION_AND_CRITERIA )" >&nbsp;&nbsp;
                    <input type="button" id="orCriteriaBtn" disabled value="Add as Grouped OR Criterion" onclick="processCriteriaList( ACTION_OR_CRITERIA )" >&nbsp;&nbsp;
                </td>
            </tr>
        </table>
    </div>
</fieldset>

<br>
<fieldset>
    <legend><b>Search Criteria in Effect:</b></legend>
    <div >
        <b>Step 2:&nbsp;&nbsp;</b>All the criteria listed in this section will be used to conduct the search.
        Click the "Delete" button next to any criterion you wish to be removed from the search request.  When you are ready
        to perform the search, press the "Search" button.
        <br>
        <br>
        <table border="0" cellspacing="0" cellpadding="5" id="criteriaEffectTable" width="100%" >
        </table>
        <br>
        <div style="padding-left: 5px; padding-bottom: 5px" >
            <input type="button" id="searchButton" disabled value="Search" onClick="doSearch()">
        </div>
    </div>
</fieldset>

<br>
<fieldset>
    <legend><b>Search Results:</b></legend>

    <div id="statusDiv" style="font-weight: bold" ></div>

    <br>

    <div id="resultDiv" style="display:none; border: 1px solid">
        <table id="resultHeaderTable" border="0" cellspacing="0" cellpadding="5" width="100%" style="border-bottom: 1px solid black" >
        </table>
        <div style="overflow:auto; height: 300px" >
            <table id="resultTable" border="1" cellspacing="0" cellpadding="5" width="100%" ></table>
        </div>
    </div>

</fieldset>

<br>
<fieldset>
    <legend><b>Vehicle List</b></legend>
    <div id="pleaseWaitMsgDiv" style="display:none">
        <table width="100%"><tr><td width="100%" align="center">Retrieving Data...Please Wait</td></tr></table>
    </div>
    <div id="scratchListDiv" style="display:none"><b>Configure and Compare Styles:</b>
        <table id="scratchListTable" border="1" cellspacing="0" cellpadding="5" width="100%"></table>
        <table id="buttonsTable" border="0" cellspacing="0" cellpadding="5" width="100%">
            <tr>
                <td align="center">
                    <input type="button" style="width: 150px" id="comparableButton" value="Find Comparable" onClick="findComparable()">
                </td>
                <td align="center">
                    <input type="button" style="width: 100px" id="configureButton" value="Configure" onClick="doConfigure()">
                </td>
                <td align="center">
                    <input type="button" style="width: 150px" id="compareSBSButton" value="Compare Side By Side" onClick="doCompareSBS()">
                </td>
                <td align="center">
                    <input type="button" style="width: 250px" id="compareABCButton" value="Compare Advantages/Disadvantages" onClick="doCompareABC()">
                </td>
                <td align="center">
                    <input type="button" style="width: 100px" id="removeButton" value="Remove" onClick="removeScratchListRow()">
                </td>
                <td align="center">
                    <input type="button" style="width: 100px" id="removeAllButton" value="Remove All" onClick="removeScratchListAll()">
                </td>
                <td colspan="100" >
                    &nbsp;
                </td>
            </tr>
        </table>
    </div>
</fieldset>
</body>
</html>