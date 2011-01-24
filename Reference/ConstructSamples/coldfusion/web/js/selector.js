function selectLocale() {
	//get locale
    var localeElm = document.getElementById("locale");
    var locale = localeElm.options[localeElm.selectedIndex].value;

    //do request
    var request = getRequest();
    request.open("get", "ACCS_Sample_Selector_Data.cfm?data=locale&locale=" + locale, false);
    request.send(null);

    var modeString = "Fleet~~Fleet;;Retail~~Retail" ;
    fillSelect(document.getElementById("mode"), modeString);

    //disable year, division and model
    clearSelect(document.getElementById("year"));
    clearSelect(document.getElementById("division"));
    clearSelect(document.getElementById("model"));

}

function selectMode() {
	//get mode
    var modeElm = document.getElementById("mode");
    var mode = modeElm.options[modeElm.selectedIndex].value;

    //do request
    var request = getRequest();
    request.open("get", "ACCS_Sample_Selector_Data.cfm?data=orderAvailability&orderAvailability=" + mode, false);
    request.send(null);

    //clear dropdowns
    clearSelect(document.getElementById("division"));
    clearSelect(document.getElementById("model"));

    loadYears();
}

function loadYears() {
	//do request
    var request = getRequest();
    request.open("get", "ACCS_Sample_Selector_Data.cfm?data=years", false);
    request.send(null);

    //populate year dropdown and disable division and model
    fillSelect(document.getElementById("year"), request.responseText);
    clearSelect(document.getElementById("division"));
    clearSelect(document.getElementById("model"));

}

function selectYear(modelYear) {
	//do request
    var request = getRequest();
    request.open("get", "ACCS_Sample_Selector_Data.cfm?data=divisions&modelYear=" + modelYear, false);
    request.send(null);

    //populate division dropdown and clear model dropdown
    fillSelect(document.getElementById("division"), request.responseText);
    clearSelect(document.getElementById("model"));

}

function selectDivision(divisionId) {
	//get year
    var modelYear = document.getElementById("year").value;

    //do request
    var request = getRequest();
    request.open("get", "ACCS_Sample_Selector_Data.cfm?data=models&modelYear=" + modelYear + "&divisionId=" + divisionId, false);
    request.send(null);

    //sort models
    var models = request.responseText.split(";;");
    var modelsArray = [];
    for (var i = 0; i < models.length; i++) {
   		modelsArray[i] = models[i];
	}
	modelsArray.sort();

    //populate model dropdown
    fillModelsSelect(document.getElementById("model"), modelsArray);

}

function getStyles() {

	//get year, divisionId, and divisionName, and model
	var modelYear = document.getElementById("year").value;

	var divisionId = document.getElementById("division").value;
	var divisionSelectElement = document.getElementById("division");
	var divisionName = divisionSelectElement.options[divisionSelectElement.selectedIndex].text;

	var modelSelectElement = document.getElementById("model");
	var modelName = modelSelectElement.options[modelSelectElement.selectedIndex].text;
	var modelId = modelSelectElement.options[modelSelectElement.selectedIndex].value;

	//do request
	var request = getRequest();
	request.open("get", "ACCS_Sample_Selector_Data.cfm?data=styles&modelYear=" + modelYear + "&divisionId=" + divisionId + "&divisionName=" + divisionName + "&modelId=" + modelId + "&modelName=" + modelName, false);
  	request.send(null);

	//populate style table
  	fillStyleTable(document.getElementById("styleTable"), request.responseText);

  	//show style table
  	var div = document.getElementById("styleDiv");
	div.style.visibility = "visible";
}

function fillStyleTable(styleTable, responseText) {
 	var table = document.getElementById( "styleTable" );

 	//delete previous styles
 	clearTable( table );

 	//populate table with new styles
 	var allStyles = responseText.split(";;");
	for (var i = 0; i < allStyles.length; i++) {
		var eachStyle = allStyles[i];
		var styleParams = eachStyle.split("~~");
		var year = styleParams[0];
		var division = styleParams[1];
		var model = styleParams[2];
		var styleName = styleParams[3];
		var invoice = styleParams[4];
		var msrp = styleParams[5];

		var row = table.insertRow(-1);
		var td = row.insertCell(-1);
		td.setAttribute("width","10%");
		td.setAttribute("align","center");
		td.innerHTML = "<input type='button' value='Add to List' onClick='addToScratchList(this.name)' name='" + eachStyle + "'></>";

		var td2 = row.insertCell(-1);
		td2.setAttribute("width","70%");
		td2.setAttribute("align","center");
		td2.innerHTML = year + " " + division + " " + model + " " + styleName;

		var td3 = row.insertCell(-1);
		td3.setAttribute("width","10%");
		td3.setAttribute("align","center");
		td3.innerHTML = invoice;

		var td4 = row.insertCell(-1);
		td4.setAttribute("width","10%");
		td4.setAttribute("align","center");
		td4.innerHTML = msrp;
	}
}

function addToScratchList( styleName ) {
	//break down style parameters
	var styleParams = styleName.split("~~");
	var year = styleParams[0];
	var division = styleParams[1];
	var model = styleParams[2];
	var trim = styleParams[3];
	var styleId = styleParams[6];
	var optionCodes = styleParams[7];

    var request = getRequest();
    request.open("get", "ACCS_ScratchList.cfm?cmd=add&styleId=" + styleId, false);
    request.send(null);

	var response = trimString( request.responseText );
    var result = response.split("~~")[0];
    var resultValue = response.split("~~")[1];

    if( result == "success" ){

        var scratchListId = resultValue;

        //add style to scratchlist table
        var table = document.getElementById( "scratchListTable" );
        var row = table.insertRow(-1);
        var td = row.insertCell(-1);
        td.setAttribute("width","5%");
        td.setAttribute("align","center");
        td.innerHTML = "<input type='checkbox' onClick='updateScratchListButtons()' name='scratchListCheckboxes' value='" + scratchListId + "'></>";
        var td2 = row.insertCell(-1);
        td2.innerHTML = year + " " + division + " " + model + " " + trim;

        //show scratchlist table
        var div = document.getElementById("scratchListDiv");
        div.style.visibility = "visible";

        updateScratchListButtons();
    } else {
	    alert( "Error during add to scratchlist. " +  resultValue );
	}
}

function updateScratchListButtons() {
	var numChecked = 0;

	var checkBoxes = document.getElementsByName("scratchListCheckboxes");
	for (var i = 0; i < checkBoxes.length; i++) {
	  if ( checkBoxes[i].checked )
	      ++numChecked;

      if ( numChecked == 2 )
      	break;
	}

	if( numChecked == 0 ) {
		document.getElementById("configureButton").disabled = true;
		document.getElementById("compareSBSButton").disabled = true;
		document.getElementById("compareABCButton").disabled = true;
		document.getElementById("removeButton").disabled = true;
		document.getElementById("removeAllButton").disabled = false;
	}
	else if( numChecked == 1 ) {
		document.getElementById("configureButton").disabled = false;
		document.getElementById("compareSBSButton").disabled = true;
		document.getElementById("compareABCButton").disabled = true;
		document.getElementById("removeButton").disabled = false;
		document.getElementById("removeAllButton").disabled = false;
	}
	else {
		document.getElementById("configureButton").disabled = true;
		document.getElementById("compareSBSButton").disabled = false;
		document.getElementById("compareABCButton").disabled = false;
		document.getElementById("removeButton").disabled = false;
		document.getElementById("removeAllButton").disabled = false;
	}
}

function removeScratchListRow() {

    var checkBoxes = document.getElementsByName("scratchListCheckboxes");
	var table = document.getElementById("scratchListTable");
	var rows = table.rows;
    var request = getRequest();

    for( var i = rows.length - 1; i >= 0; --i )	{
		if( checkBoxes[i].checked ){
            request.open("get", "ACCS_ScratchList.cfm?cmd=remove&scratchListId=" + checkBoxes[i].value, false);
            request.send(null);
            var result = trimString( request.responseText );
            if( result ==  "success" ){
                table.deleteRow( i );
            }
        }
	}

	//hide table if no more rows
	table = document.getElementById("scratchListTable");
	rows = table.rows;
	var div = document.getElementById("scratchListDiv");
	if ( rows.length < 1 ) {
		div.style.visibility = "hidden";
	}
	else {
		div.style.visibility = "visible";
		updateScratchListButtons();
	}
}

function removeScratchListAll() {

    var request = getRequest();
    request.open("get", "ACCS_ScratchList.cfm?cmd=clear", false);
    request.send(null);
    var result = trimString( request.responseText );
    if( result ==  "success" ){
        var table = document.getElementById("scratchListTable");
        clearTable( table );
        //hide table
        var div = document.getElementById("scratchListDiv");
        div.style.visibility = "hidden";
    }
}

function clearTable(tableElm) {
	var rows = tableElm.rows;
	for( var i = rows.length - 1; i >= 0; --i )
  		tableElm.deleteRow( i );
}

function clearSelect(selectElm) {
    if (selectElm.options != null) {
        selectElm.options.length = 0;
    }
    selectElm.disabled = true;
}

function fillSelect(selectElm, responseText) {
    selectElm.options.length = 0;
    selectElm.options[0] = new Option("", "0", true, true);
    var response = responseText.split(";;");
    for (var i = 0; i < response.length; i++) {
        var style = response[i].split("~~");
       	selectElm.options[selectElm.options.length] = new Option(style[1], style[0], false, false);
    }
    selectElm.disabled = false;
}

function fillModelsSelect(selectElm, modelsArray) {
    selectElm.options.length = 0;
    selectElm.options[0] = new Option("", "0", true, true);
    for (var i = 0; i < modelsArray.length; i++) {
        var style = modelsArray[i].split("~~");
       	selectElm.options[selectElm.options.length] = new Option(style[0], style[1], false, false);
    }
    selectElm.disabled = false;
}

function trimString(stringToTrim) {
	return stringToTrim.replace(/^\s+|\s+$/g,"");
}
// -->