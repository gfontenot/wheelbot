function doCompareSBS() {

    //show message
	var msgDiv = document.getElementById( "pleaseWaitMsgDiv" );
	msgDiv.style.display = "";
	msgDiv.style.visibility = "visible";

	//get mode and locale
  	var modeElm = document.getElementById("mode");
	var mode = modeElm.options[modeElm.selectedIndex].value;
  	var localeElm = document.getElementById("locale");
	var locale = localeElm.options[localeElm.selectedIndex].value;

	//get selected ids
	var checkBoxes = document.getElementsByName("scratchListCheckboxes");
	var table = document.getElementById("scratchListTable");
	var rows = table.rows;

	var scratchListIds = "";
	for( var i = 0; i < rows.length; i++ )	{
		if( checkBoxes[i].checked ) {
			var scratchListId = checkBoxes[i].value.split( "~~" );
  			scratchListIds += scratchListId + "~~";
		}
  	}
  	scratchListIds = scratchListIds.substr( 0, scratchListIds.length - 2 );

  	document.location = "ACCS_Sample_CompareSBS.php?scratchListIds=" + scratchListIds;
}

function doCompareABC() {
	//show message
	var msgDiv = document.getElementById( "pleaseWaitMsgDiv" );
	msgDiv.style.display = "";
	msgDiv.style.visibility = "visible";

	//get mode and locale
	var modeElm = document.getElementById("mode");
	var mode = modeElm.options[modeElm.selectedIndex].value;
	var localeElm = document.getElementById("locale");
	var locale = localeElm.options[localeElm.selectedIndex].value;

	//get selected ids
	var checkBoxes = document.getElementsByName("scratchListCheckboxes");
	var table = document.getElementById("scratchListTable");
	var rows = table.rows;

	//get ids
	var primarySelected = false;
	var primaryScratchListId = "";
	var scratchListIds = "";
	for( var i = 0; i < rows.length; i++ )	{
		if( checkBoxes[i].checked ) {
			var scratchListId = checkBoxes[i].value;
			if( ! primarySelected ) {
				primaryScratchListId = scratchListId;
				primarySelected = true;
			} else {
                scratchListIds += scratchListId + "~~";
			}
		}
  	}

    scratchListIds = scratchListIds.substr( 0, scratchListIds.length - 2 );

    document.location = "ACCS_Sample_CompareABC.php?primaryScratchListId=" + primaryScratchListId + "&scratchListIds=" + scratchListIds;
}

function doNewABC_Compare( scratchListIds ){

	//show message
	var msgDiv = document.getElementById( "pleaseWaitMsgDiv" );
	msgDiv.style.display = "";
	msgDiv.style.visibility = "visible";

	//get primary id
	var primaryIndex = 0;
    var primaryButton = document.getElementsByName("primaryButton");
	for( var i=0; i < primaryButton.length; i++ ) {
		if ( primaryButton[i].checked ) {
			primaryIndex = i;
            break;
        }
	}

    var idArray = scratchListIds.split("~~");
    var primaryScratchListId = "";

    scratchListIds = "";
    for( var i=0; i < idArray.length; i++ ){
        if( i == primaryIndex ){
            primaryScratchListId = idArray[i];
        } else {
            scratchListIds += idArray[i] + "~~";
        }
    }

    scratchListIds = scratchListIds.substr( 0, scratchListIds.length - 2 );

    document.location = "ACCS_Sample_CompareABC.php?primaryScratchListId=" + primaryScratchListId + "&scratchListIds=" + scratchListIds;
}

function showOrHideGroup( groupName ) {
	//get link element and div
	var link = document.getElementById( groupName );
	var div = document.getElementById( groupName + "Div" );

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
// -->