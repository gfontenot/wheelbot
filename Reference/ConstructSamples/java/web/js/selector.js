function selectLocale() {
	//get locale
    var localeElm = document.getElementById("locale");
    var locale = localeElm.options[localeElm.selectedIndex].value;

    //do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=locale&locale=" + locale, false);
    request.send(null);

    var modeString = "Fleet~~Fleet;;Retail~~Retail" ;
    fillSelect(document.getElementById("mode"), modeString);

    //disable year, division and model
    clearSelect(document.getElementById("year"));
    clearSelect(document.getElementById("division"));
    clearSelect(document.getElementById("model"));
    clearSelect(document.getElementById("cfmodelname"));

}

function selectMode() {
	//get mode
    var modeElm = document.getElementById("mode");
    var mode = modeElm.options[modeElm.selectedIndex].value;

    //do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=orderAvailability&orderAvailability=" + mode, false);
    request.send(null);

    //clear dropdowns
    clearSelect(document.getElementById("division"));
    clearSelect(document.getElementById("model"));
    clearSelect(document.getElementById("cfmodelname"));

    loadYears();
}

function loadYears() {
	//do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=years", false);
    request.send(null);

    //populate year dropdown and disable division and model
    fillSelect(document.getElementById("year"), request.responseText);
    clearSelect(document.getElementById("division"));
    clearSelect(document.getElementById("model"));
    clearSelect(document.getElementById("cfmodelname"));

}

function selectYear(modelYear) {
	//do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=divisions&modelYear=" + modelYear, false);
    request.send(null);

    //populate division dropdown and clear model dropdown
    fillSelect(document.getElementById("division"), request.responseText);
    clearSelect(document.getElementById("model"));
    clearSelect(document.getElementById("cfmodelname"));

}

function selectDivision(divisionId) {
	//get year
    var modelYear = document.getElementById("year").value;

    //do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=models&modelYear=" + modelYear + "&divisionId=" + divisionId, false);
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

function getConsumerFriendlyModelNames(){

	//get year and divisionid
    var modelYear = document.getElementById("year").value;
    var divisionId = document.getElementById("division").value;

    //do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=cfmodelnames&modelYear=" + modelYear + "&divisionId=" + divisionId, false);
    request.send(null);

    //sort models
    var cfModelNameData = request.responseText;

    //populate model dropdown
    fillCfModelsSelect( document.getElementById("cfmodelname"), cfModelNameData );

}

function getStylesByCfModelName( consumerFriendlyModelName ){

    var modelYear = document.getElementById("year").value;
    var divisionId = document.getElementById("division").value;

    //do request
    var request = getRequest();
    request.open("get", "SelectorServlet?data=stylesbycfmodelname&modelYear=" + modelYear
            + "&divisionId=" + divisionId + "&cfModelName=" + consumerFriendlyModelName, false);
    request.send(null);

    var styleData = request.responseText;

    var styleObjects = new Array();
    var allStyles = styleData.split(";;");
    for (var i = 0; i < allStyles.length; i++) {

        var eachStyle = allStyles[i];
		var styleParams = eachStyle.split("~~");

        var style = new Object();
        style.year = styleParams[0];
        style.division = styleParams[1];
        style.model = styleParams[2];
        style.styleName = styleParams[3];
        style.invoice = styleParams[4];
        style.msrp = styleParams[5];
		style.styleId = styleParams[6];
        style.cfModelName = styleParams[7];
        style.cfStyleName = styleParams[8];
        style.cfBodyStyle = styleParams[9];
        style.cfDrivetrain = styleParams[10];
        style.data = eachStyle;

        styleObjects[i] = style;
    }

    addStylesToTable( styleObjects );

}

function addStylesToTable( styleObjects ){

	var table = document.getElementById( "styleTable" );
	clearTable( table );

	var cfBodyStyles = getUniqueObjectValues( styleObjects, "cfBodyStyle" );
	var cfDrivetrains = getUniqueObjectValues( styleObjects, "cfDrivetrain" );

	if( getListLength( cfBodyStyles ) > 1 ){
	    for( var bodyStyle in cfBodyStyles ){
			var row = table.insertRow(-1);
			var td = row.insertCell(-1);
			td.setAttribute( "colspan", "100%" );
			td.innerHTML = bodyStyle;
			td.style.fontWeight = "bold";
			td.style.textAlign = "center";
			var foundOne = false;
			for( var i=0; i < styleObjects.length; i++ ){
				if( isFilterMatch( styleObjects[i], bodyStyle, "" ) ){
					addStyleToRow( table.insertRow(-1), styleObjects[i] );
					foundOne = true;
				}
			}
			if( !foundOne ){
				table.deleteRow(-1);
			}
		}
    } else if( getListLength( cfDrivetrains ) > 1 ){
	    for( var drivetrain in cfDrivetrains ){
			var row = table.insertRow(-1);
			var td = row.insertCell(-1);
			td.setAttribute( "colspan", "100%" );
			td.innerHTML = drivetrain;
			td.style.fontWeight = "bold";
			td.style.textAlign = "center";
			var foundOne = false;
			for( var i=0; i < styleObjects.length; i++ ){
				if( isFilterMatch( styleObjects[i], "", drivetrain ) ){
					addStyleToRow( table.insertRow(-1), styleObjects[i] );
					foundOne = true;
				}
			}
			if( !foundOne ){
				table.deleteRow(-1);
			}
		}
	} else {
		for( var i=0; i < styleObjects.length; i++ ){
			if( isFilterMatch( styleObjects[i], "", "" ) ){
				addStyleToRow( table.insertRow(-1), styleObjects[i] );
			}
		}
	}

	var div = document.getElementById("styleDiv");
	div.style.visibility = "visible";

}

function isFilterMatch( styleObject, filteredCfBodyStyle, filteredCfDrivetrain ){
	var isMatch = true;
	if( filteredCfBodyStyle.length > 0 && filteredCfBodyStyle != styleObject["cfBodyStyle"] ) {
		isMatch = false;
	}
	if( filteredCfDrivetrain.length > 0 && filteredCfDrivetrain != styleObject["cfDrivetrain"] ) {
		isMatch = false;
	}
	return isMatch;
}

function addStyleToRow( styleRow, styleObject ){

	var styleName = styleObject["cfStyleName"]

	var bttnCell = styleRow.insertCell(-1);
	var descCell = styleRow.insertCell(-1);
	var invoCell = styleRow.insertCell(-1);
	var msrpCell = styleRow.insertCell(-1);

	bttnCell.innerHTML = "<input type='button' value='Add to List' onClick='addToScratchList(this.name)' name='" + styleObject.data + "'></>";
	descCell.innerHTML = styleObject.year + " " + styleObject.division + " " + styleObject.model + " " + styleName;
	invoCell.innerHTML = styleObject.invoice;
	msrpCell.innerHTML = styleObject.msrp;
}

function getListLength( list ){
	var lengthValue = 0;
    for( var i in list ){
	    lengthValue++;
	}
	return lengthValue;
}

function getUniqueObjectValues( objectArray, propertyName ){
    var valueList = new Array();
    for( var i=0; i < objectArray.length; i++ ){
	    var thisObject = objectArray[i];
	    var propertyValue = thisObject[propertyName];
	    if( propertyValue && propertyValue.length > 0 ){
			valueList[propertyValue] = propertyValue;
		}
    }
    return valueList;
}

function getStyleData(){

	var modelSelectElement = document.getElementById("model");
	var modelId = modelSelectElement.options[modelSelectElement.selectedIndex].value;

	//do request
	var request = getRequest();
	request.open("get", "SelectorServlet?data=styles&modelId=" + modelId, false);
  	request.send(null);

    return request.responseText;

}

function getStyles() {

    var styleData = getStyleData();

    //populate style table
  	fillStyleTable( document.getElementById("styleTable"), styleData );

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

    var request = getRequest();
    request.open("get", "ScratchListServlet?cmd=add&styleId=" + styleId, false);
    request.send(null);

    //get response
	var scratchListId = request.responseText;
    if( scratchListId != "fail" ){
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
            request.open("get", "ScratchListServlet?cmd=remove&scratchListId=" + checkBoxes[i].value, false);
            request.send(null);
            var result = request.responseText;
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
	var table = document.getElementById("scratchListTable");
	clearTable( table );

	//hide table
	var div = document.getElementById("scratchListDiv");
	div.style.visibility = "hidden";
}

function clearTable(tableElm) {
	var rows = tableElm.rows;
	for( var i = rows.length - 1; i >= 0; --i )
  		tableElm.deleteRow( i );
}

function clearSelect(selectElm) {
	if( selectElm ){
	    if (selectElm.options != null) {
	        selectElm.options.length = 0;
	    }
	    selectElm.disabled = true;
	}
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

function fillCfModelsSelect(selectElm, cfModelNameData) {
    selectElm.options.length = 0;
    selectElm.options[0] = new Option("", "0", true, true);
    var cfModelnames = cfModelNameData.split("~~");
    for( var i = 0; i < cfModelnames.length; i++ ){
        var cfModelName = cfModelnames[i];
       	selectElm.options[selectElm.options.length] = new Option(cfModelName, cfModelName, false, false);
    }
    selectElm.selectedIndex = -1;
    selectElm.disabled = false;
}
// -->