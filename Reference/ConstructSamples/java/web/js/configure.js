function doConfigure( filePathAndName ) {
	//show msg
	var msgDiv = document.getElementById( "pleaseWaitMsgDiv" );
	msgDiv.style.display = "";
	msgDiv.style.visibility = "visible";

	//get id to configure
   	var checkBoxes = document.getElementsByName("scratchListCheckboxes");
	var scratchListId = "";
	if( filePathAndName != null && filePathAndName.length > 0 )
		scratchListId = "none";
	else {
		for (var i = 0; i < checkBoxes.length; i++) {
			if( checkBoxes[i].checked ) {
				scratchListId = checkBoxes[i].value;
				break;
			}
		}
	}
	document.location = "ConfigServlet?scratchListId=" + scratchListId + "&filePathAndName=" + filePathAndName;
}

function showOrHideGroup( groupName ) {
	//get link element and div
	var link = document.getElementById( groupName );
	var div = document.getElementById( groupName + " Div" );

	//shor or hide div
	if( div.style.visibility == "hidden" ) {
		link.innerHTML = "<b>Hide " + groupName + "</b>";
		div.style.display = "";
		div.style.visibility = "visible";
	}
	else {
		link.innerHTML = "<b>Show " + groupName + "</b>";
		div.style.display = "none";
		div.style.visibility = "hidden";
	}
}

function toggleOption(optionCode) {
	var modalWinMaskDiv = document.getElementById("modalWinMask");

	//do toggle request - don't want IE to cache so use random=new Date()
	var request = getRequest();
    request.open("get", "ToggleOptionServlet?optionCode=" + optionCode + "&random=" + new Date(), false);
    request.send(null);

    //get response
	var returnParams = request.responseText.split("~~");

	//get toggle conflict
	var isConflict = returnParams[0];
	if ( isConflict == "yesConflict" ) {

		//show mask
	    modalWinMaskDiv.style.display = "";
	    modalWinMaskDiv.style.height = document.body.offsetHeight;
	    modalWinMaskDiv.style.width = "100%";
	    modalWinMaskDiv.style.visibility = "visible";

		//get originating option code and description
		var originatingOptionCode = returnParams[1].split(";;")[0];
		var originatingOptionDesc = returnParams[1].split(";;")[1];

		var addOrDelete = returnParams[2];

		//set conflict div table content
		var conflictingOptionCodesAndDescs = returnParams[3].split(";;")

		var content = "<table border=\"0\" cellspacing=\"0\" cellpadding=\"2\" style=\"font-size:14px;\">";
		if ( addOrDelete == "add" )
			content += "<tr><td colspan=\"2\">The addition of option code: ";
		else
			content += "<tr><td colspan=\"2\">The removal of option code: ";
        content += "<br><b>" + originatingOptionCode + " (" + originatingOptionDesc + ")</b><br>";
        content += "</td></tr><tr><td colspan=\"2\">requires selecting one of these options:</td></tr><tr><td colspan=\"2\"><hr></td></tr>";

		for (var i = 0; i < conflictingOptionCodesAndDescs.length; i++) {
	        var conflictOptionCode = conflictingOptionCodesAndDescs[i].split("::")[0];
	        var conflictOptionDesc = conflictingOptionCodesAndDescs[i].split("::")[1];
            content += "<tr><td><input type=\"checkbox\" onclick=\"resolveConflict('";
            content += conflictOptionCode;
            content += "');\"></td><td><b>";
            content += conflictOptionCode + " (" + conflictOptionDesc + ")";
            content += "</b></td></tr>";
        }
        content += "</table>";

	    //show conflict dialog and content
	    document.getElementById("conflictContent").innerHTML = content;
	    var conflictDiv = document.getElementById("conflictDialog");

		conflictDiv.style.top = document.body.scrollTop + 200;
        conflictDiv.style.left = 200;
		conflictDiv.style.display = "";
		conflictDiv.style.visibility = "visible";
	}
	else {
		//show new option images for each option
		var optionCodes = returnParams[1].split(";;");
		for (var i = 0; i < optionCodes.length; i++) {
			var optionString = optionCodes[i].split("::");
			var optionCode2 = optionString[0];
			var optionState = optionString[1];

			//sometimes we get no option code; i.e. Honda vehicles
			if ( optionCode2.length > 0 ) {
				var optionImage = document.getElementById("img" + optionCode2);
				optionImage.src = "images/" + optionState.toLowerCase() + ".gif";
				optionImage.title = optionState;

				var checklistStatus =  document.getElementById("checklistStatus" + optionCode2);
				if( checklistStatus ){
					if( optionState.toLowerCase() == "selected" || optionState.toLowerCase() == "included" || optionState.toLowerCase() == "required" ){
						checklistStatus.innerHTML = "-->";
					} else {
						checklistStatus.innerHTML = "&nbsp;";
					}
				}
			}

		}

		var checklistTables = document.getElementsByName( "checklistTable" );
		for( var i=0; i < checklistTables.length; i++ ){
			if( checklistTables[i].innerHTML.indexOf("-->") > -1 || checklistTables[i].innerHTML.indexOf("--&gt;") > -1 ){
				checklistTables[i].style.backgroundColor = "White";
			} else {
				checklistTables[i].style.backgroundColor = "Red";
			}
		}

		//show new prices
		document.getElementById("totalOptionInvoice").innerHTML = "$" + returnParams[2];
		document.getElementById("totalOptionMsrp").innerHTML = "$" + returnParams[3];
		document.getElementById("totalInvoice").innerHTML = "<b>$" + returnParams[4] + "</b>";
		document.getElementById("totalMsrp").innerHTML = "<b>$" + returnParams[5] + "</b>";
	}

	//hide mask
	if ( isConflict != "yesConflict" )
		modalWinMaskDiv.style.visibility = "hidden";
}

function resolveConflict(optionCode) {
	//hide conflict dialog
    document.getElementById("conflictDialog").style.visibility = "hidden";
    document.getElementById("conflictDialog").style.display = "none";

    //toggle selected conflict option
    toggleOption(optionCode);
}

function saveStyle( styleName ) {
	var request = getRequest();
    request.open("get", "SaveStyleServlet?actionType=add&styleName=" + styleName, false);
    request.send(null);

    if( request.responseText == "success" )
    {
       //show msg
        var msgDiv = document.getElementById( "styleSaveDiv" );
        msgDiv.style.display = "";
        msgDiv.style.visibility = "visible";
    }
}

function deleteSavedStyle( styleName )
{
    var request = getRequest();
    request.open("get", "SaveStyleServlet?actionType=delete&styleName=" + styleName, false);
    request.send(null);

    if( request.responseText == "success" )
    {
        var table = document.getElementById( "savedStyleTable" );
        if( table )
        {
            var rows = table.rows;
            var targetRow = "row_" + styleName;
            for( var i = rows.length - 1; i >= 0; --i )
            {
                if( rows[i].id == targetRow )
                {
                    table.deleteRow( i );
                    break;
                }
            }
        }

        document.getElementById( "savedStyleDiv" ).style.display = table.rows.length > 0 ? "" : "none";
    }
}

function showColorWindow() {
    window.open( "ACCS_Sample_Config_Colors.jsp", "colorWindow", "width=500px, height=600px, toolbar=no, menubar=no,scrollbars=yes,resizable=yes");
}

// -->