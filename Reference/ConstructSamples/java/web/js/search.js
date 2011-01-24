var NUMERIC_REGEXP = /[^\-\d\.]/g;
var stringArray = new Array();
var booleanArray = new Array();
var numberRangeArray = new Array();
var moneyRangeArray = new Array();
var techSpecArray = new Array();
var selectArray = [ "locale", "mode", "criterion" ];
var currentRow = null;

var currentCriteria = new Array();
var currentCompositeCriteria = new Array();

var FORMAT_BOLD = 0;
var FORMAT_ITALIC = 1;

var ACTION_DELETE = 0;
var ACTION_GENERAL_CRITERIA = 1;
var ACTION_AND_CRITERIA = 2;
var ACTION_OR_CRITERIA = 3;

var CRIT_LIST_ROW    = "critListRow_";
var CRIT_LIST_CHECK  = "critListCheck_";
var CRIT_LIST_CHECKS  = "critListChecks";
var CRIT_EFFECT_ROW    = "critEffectRow_";
var CRIT_EFFECT_BTN    = "critEffectBtn_";

var TYPE_GENERAL_CRITERION = "general";
var TYPE_AND_CRITERION = "and";
var TYPE_OR_CRITERION = "or";

function getSearchCriteria()
{
    var request = getRequest();
    request.open("get", "SearchServlet?data=getSearchCriteria", false);
    request.send(null);

    // clear out old data
    currentCriteria.length = 0;
    currentCompositeCriteria.length = 0;
    deleteAllTableRows( "criteriaTable" );
    deleteAllTableRows( "criteriaEffectTable" );
    updateButtonStates();
    updateSearchButtonState();

    var select = document.getElementById( "criterion" );
    var childNodes = select.childNodes; // clear out old list of criteria
    for( var i = childNodes.length -1; i >= 0; --i )
        select.removeChild( childNodes[ i ] );

    // divide the criteria based on type
    stringArray.length = 0;
    booleanArray.length = 0;
    numberRangeArray.length = 0;
    moneyRangeArray.length = 0;
    techSpecArray.length = 0;

    // iterate through all search criteria
    var response = request.responseText.split(";;");
    for (var i = 0; i < response.length; i++)
    {
        var criterionParams = response[i].split("~~");
        var name = criterionParams[ 0 ];
        var type = criterionParams[ 1 ];
        var min = criterionParams[ 2 ];
        var max = criterionParams[ 3 ];
        var unit = criterionParams[ 4 ];

        var criterion = new SearchCriterion( name, type );
        criterion.min = min;
        criterion.max = max;
        criterion.unit = unit;

        // add the criterion to the appropriate array
        var array = null;
        switch( type )
        {
            case "String":
                array = stringArray;
                break;
            case "Boolean":
                array = booleanArray;
                break;
            case "NumberRange":
                array = numberRangeArray;
                break;
            case "MoneyRange":
                array = moneyRangeArray;
                break;
            case "TechnicalSpecificationRange":
                array = techSpecArray;
                break;
        }
        if( array != null )
            array.push( criterion );
    }

    // add the criteria to the select
    addCriteriaToSelect( select, "Boolean Criteria", booleanArray );
    addCriteriaToSelect( select, "String Criteria", stringArray );
    addCriteriaToSelect( select, "Number Range Criteria", numberRangeArray );
    addCriteriaToSelect( select, "Money Range Criteria", moneyRangeArray );
    addCriteriaToSelect( select, "Technical Specification Criteria", techSpecArray );

    // enable the select and select first element by default
    select.disabled = false;
    if( select.options.length > 0 )
    {
        select.options.selectedIndex = 0;
        criterionSelected();
    }
    toggleElementDisabledState( "addCriterionBtn", select.options.length > 0 );
}

function toggleSelectStates( enabled )
{
    for( var i = 0; i < selectArray.length; ++i )
    {
        toggleElementDisabledState( selectArray[ i ], enabled );
    }
}

function toggleElementDisabledState( elementName, enabled )
{
    var element = document.getElementById( elementName );
    if( element )
        element.disabled = !enabled;
}

function selectLocale()
{
	//get locale
    var localeElm = document.getElementById("locale");
    var locale = localeElm.options[localeElm.selectedIndex].value;

    //do request
    var request = getRequest();
    request.open("get", "SearchServlet?data=locale&locale=" + locale, false);
    request.send(null);

    modeString = "Fleet~~Fleet;;Retail~~Retail" ;
    fillSelect(document.getElementById("mode"), modeString);

    setEnabledState("searchButton", false);

    getSearchCriteria();
    selectMode();
}

function selectMode()
{
	//get mode
    var modeElm = document.getElementById("mode");
    var mode = modeElm.options[modeElm.selectedIndex].value;

    //do request
    var request = getRequest();
    request.open("get", "SearchServlet?data=orderAvailability&orderAvailability=" + mode, false);
    request.send(null);

    setEnabledState("searchButton", false);
}

function fillSelect(selectElm, responseText)
{
    selectElm.options.length = 0;
    var response = responseText.split(";;");
    for (var i = 0; i < response.length; i++)
    {
        var style = response[i].split("~~");
       	selectElm.options[selectElm.options.length] = new Option(style[1], style[0], false, false);
    }
    selectElm.disabled = false;
}

function setEnabledState(target, state)
{
	var element = document.getElementById( target );
    if( element )
        element.style.disabled = state;
}

// represents a search criterion object which is used to build a search request
SearchCriterion.index = 0;
function SearchCriterion( name, type )
{
    this.name = name;
    this.type = type;
    this.mustHave = true;
    this.value = null;
    this.min = null;
    this.max = null;
    this.id = SearchCriterion.index++;
    this.unit = null;
}

SearchCriterion.prototype.getSummary = function()
{
    var valueDesc = "";

    switch( this.type )
    {
        case "Boolean":
            valueDesc = " = " + getFormattedString( this.value, FORMAT_BOLD );
            break;
        case "String":
            valueDesc = " = " + getFormattedString( this.value, FORMAT_BOLD );
            break;
        // fall through for all these cases
        case "NumberRange":
        case "MoneyRange":
        case "TechnicalSpecificationRange":
            valueDesc = (this.min.length > 0 ? " >= " + getFormattedString( this.min, FORMAT_BOLD ) : "" )
            valueDesc += (this.max.length > 0 ? (valueDesc.length > 0 ? " and " : "" ) + " <= " + getFormattedString( this.max, FORMAT_BOLD ) : "" );
            break;
        default:
            break;
    }

    return (this.mustHave ? "Must have " : "Must not have ") + getFormattedString( this.name, FORMAT_BOLD ) + valueDesc;
}

SearchCriterion.prototype.getSearchString = function()
{
    // construct search string based on params
    var searchString = "&name=" + this.name;
    searchString += "&type=" + this.type;
    searchString += "&mustHave=" + this.mustHave;
    searchString += "&value=" + (this.value != null ? this.value : "" );
    searchString += "&min=" + (this.min != null ? this.min : "" );
    searchString += "&max=" + (this.max != null ? this.max : "" );

    return searchString;
}

// represents a compound search criterion object (AND or OR) which is used to build a search request
CompositeSearchCriterion.index = 0;
function CompositeSearchCriterion( name, type )
{
    this.name = name;
    this.type = type;
    this.mustHave = true;
    this.subCriteria = new Array(); // should be array of SearchCriterion objects
    this.id = CompositeSearchCriterion.index++;
}

CompositeSearchCriterion.prototype.getSummary = function()
{
    var valueDesc = "";

    switch( this.type )
    {
        case TYPE_GENERAL_CRITERION:
            valueDesc = this.subCriteria[ 0 ].getSummary();
            break;
        case TYPE_AND_CRITERION:
            for( var i = 0; i < this.subCriteria.length; ++i )
            {
                if( i > 0 )
                    valueDesc += "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + getFormattedString( "AND", FORMAT_BOLD ) + "<br>";
                valueDesc += this.subCriteria[ i ].getSummary();
            }
            break;
        case TYPE_OR_CRITERION:
            for( var i = 0; i < this.subCriteria.length; ++i )
            {
                if( i > 0 )
                    valueDesc += "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + getFormattedString( "OR", FORMAT_BOLD ) + "<br>";
                valueDesc += this.subCriteria[ i ].getSummary();
            }
            break;
        default:
            break;
    }

    return valueDesc;
}

CompositeSearchCriterion.prototype.getSearchString = function()
{
    // construct search string based on concatenation of subcriteria
    var searchString = "compositeName=" + this.name;
    searchString += "&compositeType=" + this.type;
    searchString += "&compositeMustHave=" + this.mustHave;

    for( var i = 0; i < this.subCriteria.length; ++i )
    {
        if( i > 0 )
            searchString += ";;"; // separator between subcriteria
        searchString += this.subCriteria[ i ].getSearchString();
    }

    return searchString;
}

function addCriteriaToSelect( select, groupName, array )
{
    if( array.length > 0 )
    {
        array.sort
        (
            function( a, b )
            {
                var aLower = a.name.toLowerCase();
                var bLower = b.name.toLowerCase();

                if( aLower < bLower )
                    return -1;
                else if( aLower > bLower )
                    return 1;
                else
                    return 0;
            }
        );

        var optGroup = document.createElement( "OPTGROUP" );
        optGroup.label = groupName;
        for( var i = 0; i < array.length; ++i )
        {
            var option = document.createElement( "OPTION" );
            option.value = array[ i ].name;
            option.innerHTML = array[ i ].name;
            option.setAttribute( "criterion", array[ i ].type + "~~" + i );
            optGroup.appendChild( option );
        }
        select.appendChild( optGroup );
    }
}

function criterionSelected(){

    var descriptor = findCriterion();

    var select = document.getElementById( "criterion" );
    var tokenName = select.options[ select.options.selectedIndex ].value;

    if( descriptor )
    {
        var type = descriptor.type;
        setElementText( "criterionType", type );
        var targetRow = type + "Row";

        var minField = "";
        var maxField = "";
        var minValueField = "";
        var maxValueField = "";

        switch( type )
        {
            case "String":
                document.getElementById( "stringValue" ).value = "";
                break;
            case "NumberRange":
                minField = "numMin";
                maxField = "numMax";
                minValueField = "numMinValue";
                maxValueField = "numMaxValue";
                break;
            case "MoneyRange":
                minField = "moneyMin";
                maxField = "moneyMax";
                minValueField = "moneyMinValue";
                maxValueField = "moneyMaxValue";
                break;
            case "TechnicalSpecificationRange":
                minField = "techSpecMin";
                maxField = "techSpecMax";
                minValueField = "techSpecMinValue";
                maxValueField = "techSpecMaxValue";
                break;
            default:
                break;
        }

        if( type == "NumberRange" || type == "MoneyRange" || type == "TechnicalSpecificationRange" ){
            setElementText( minField, descriptor.min + (descriptor.unit != null ? " " + descriptor.unit : "" ) );
            setElementText( maxField, descriptor.max + (descriptor.unit != null ? " " + descriptor.unit : "" ) );
            document.getElementById( minValueField ).value = "";
            document.getElementById( maxValueField ).value = "";
        } else if ( type == "String" ){
	     	var optionalValues = getOptionalValues( tokenName );
	     	if( optionalValues.length > 0 ){
		     	targetRow = "StringRowWithOptions";
		     	var optionsSelect = document.getElementById("stringOptionValues");
		     	optionsSelect.length = 0;
		     	for( var i=0; i < optionalValues.length; i++ ){
                     var optionalValue = optionalValues[i].split("~~");
                     var option = document.createElement( "OPTION" );
		             option.value = optionalValue[0];
		             option.innerHTML = optionalValue[1];
		             optionsSelect.appendChild( option );
			    }
		    }
	    }

        if( currentRow ){ // hide previous row
	        currentRow.style.display = "none";
	    }
        currentRow = document.getElementById( targetRow );
        currentRow.style.display = "";
    }
}

function getOptionalValues( stringTokenName ){

	var values = new Array();

    var request = getRequest();
    request.open("get", "SearchServlet?data=getOptionalValues&tokenName=" + stringTokenName, false);
    request.send(null);

    if( request.responseText.length > 0 ){
	    var optionalValues = request.responseText.split(";;");
	    for( var i=0; i < optionalValues.length; i++ ){
            if( optionalValues[i].length > 0 ){
			    values[values.length] = optionalValues[i];
			}
		}
	}

	return values;

}

function findCriterion(){
    var descriptor = null;

    var select = document.getElementById( "criterion" );
    var item = select.options[ select.options.selectedIndex ].getAttribute( "criterion" );
    var params = item.split( "~~" );

    var array = null;
    switch( params[0] )
    {
        case "String":
            array = stringArray;
            break;
        case "Boolean":
            array = booleanArray;
            break;
        case "NumberRange":
            array = numberRangeArray;
            break;
        case "MoneyRange":
            array = moneyRangeArray;
            break;
        case "TechnicalSpecificationRange":
            array = techSpecArray;
            break;
    }

    var index = parseInt( params[ 1 ] );
    if( array != null && index < array.length )
        descriptor = array[ index ];

    return descriptor;
}

function validateValue( type, control, min, max, allowBlank )
{
    if( control )
    {
        switch( type )
        {
            case "String":
            if( !allowBlank && control.value.length == 0 )
            {
                toggleSelectStates( false );   // special function must be called for IE to disable selects
                showMessageDialog( "Please specify a non-empty value for this field.", function(){ highlightInvalidField( control ) } );
                return false;
            }
            break;

            // fall through for all these fields
            case "NumberRange":
            case "MoneyRange":
            case "TechnicalSpecificationRange":
            {
                if( allowBlank && control.value.length == 0 )
                    return true;
                var value = getFloatValue( control.value );
                if( value == null )
                {
                    toggleSelectStates( false );   // special function must be called for IE to disable selects
                    showMessageDialog( "Please specify a valid number for this field.", function(){ highlightInvalidField( control ) } );
                    return false;
                }
                else
                {
                    if( min != null && min.length > 0 && value < min )
                    {
                        toggleSelectStates( false );   // special function must be called for IE to disable selects
                        showMessageDialog( "The value specified is below the minimum value for this field (" + min + ").  Please try again.", function(){ highlightInvalidField( control ) } );
                        return false;
                    }
                    else if( max != null && max.length > 0 && value > max )
                    {
                        toggleSelectStates( false );   // special function must be called for IE to disable selects
                        showMessageDialog( "The value specified is above the maximum value for this field (" + max + ").  Please try again.", function(){ highlightInvalidField( control ) } );
                        return false;
                    }
                }
            }
                break;
        }
    }

    return true;
}

function addCriterion() {

    var descriptor = findCriterion();

    if( descriptor != null ){
        var type = descriptor.type;

        var minField = "";
        var maxField = "";
        var minValueField = "";
        var maxValueField = "";

        var value;
        var min;
        var max;
        var mustHave = document.getElementsByName( "mustHave" )[0].checked;

        switch( type )
        {
            case "Boolean":
                value = document.getElementsByName( "booleanValue" )[0].checked;
                break;
            case "String":
            	if( document.getElementById( "StringRow" ).style.display == "" ){
		            var textBox = document.getElementById( "stringValue" );
	                if( !validateValue( type, textBox, null, null, false ) ) return;
	                value = textBox.value;
	            } else {
					value = document.getElementById( "stringOptionValues" ).value;
		        }
                break;
            case "NumberRange":
                minValueField = "numMinValue";
                maxValueField = "numMaxValue";
                break;
            case "MoneyRange":
                minValueField = "moneyMinValue";
                maxValueField = "moneyMaxValue";
                break;
            case "TechnicalSpecificationRange":
                minValueField = "techSpecMinValue";
                maxValueField = "techSpecMaxValue";
                break;
            default:
                break;
        }

        if( type == "NumberRange" || type == "MoneyRange" || type == "TechnicalSpecificationRange" )
        {
            if( document.getElementById( minValueField ).value.length == 0 && document.getElementById( maxValueField ).value.length == 0 )
            {
                toggleSelectStates( false );   // special function must be called for IE to disable selects
                showMessageDialog( "At least one field must be non-empty.  Please try again.", function(){ highlightInvalidField( document.getElementById( minValueField ) ) } );
                return;
            }
            if( !validateValue( type, document.getElementById( minValueField ), descriptor.min, descriptor.max, true ) )
                return;
            if( !validateValue( type, document.getElementById( maxValueField ), descriptor.min, descriptor.max, true ) )
                return;
            min = document.getElementById( minValueField ).value;
            max = document.getElementById( maxValueField ).value;
        }

        // if control reaches this point, it is ok to add the field to the list
        var searchCriterion = new SearchCriterion( descriptor.name, type );
        searchCriterion.mustHave = mustHave;
        searchCriterion.value = value;
        searchCriterion.min = min;
        searchCriterion.max = max;

        currentCriteria.push( searchCriterion );

        var criteriaTable = document.getElementById( "criteriaTable" );
        var tr = criteriaTable.insertRow( -1 );
        tr.id = CRIT_LIST_ROW + searchCriterion.id;

        var td = tr.insertCell( -1 );
        td.innerHTML = "<input name='" + CRIT_LIST_CHECKS + "' id='" + CRIT_LIST_CHECK + searchCriterion.id + "' onclick='updateButtonStates()' type='checkbox' >";
        td.colSpan = 100;
        td.innerHTML += "&nbsp;" + searchCriterion.getSummary();
    }
}

function getCheckedCriteria()
{
    var checkedArray = new Array();

    var checkboxes = document.getElementsByName( CRIT_LIST_CHECKS );
    for( var i = 0; i < checkboxes.length; ++i )
    {
        if( checkboxes[ i ].checked )
        {
            var criterion = processCriteriaById( checkboxes[ i ].id.substring( CRIT_LIST_CHECK.length ), ACTION_GENERAL_CRITERIA, currentCriteria );
            checkedArray.push( criterion );
        }
    }

    return checkedArray;
}

function updateButtonStates()
{
    var checkedArray = getCheckedCriteria();

    var enableAndBtn = true;
    for( var i = 0; i < checkedArray.length; ++i )
    {
        // AND criterion must be strings or number ranges
        if( checkedArray[ i ].type != "String" && checkedArray[ i ].type != "NumberRange" )
        {
            enableAndBtn = false;
            break;
        }
        else if( i > 0 )
        {
            // all subcriteria of an AND must have the same search token
            if( checkedArray[ i ].name != checkedArray[ i - 1 ].name )
            {
                enableAndBtn = false;
                break;
            }
        }
    }

    toggleElementDisabledState( "delCriteriaBtn", checkedArray.length > 0 );
    toggleElementDisabledState( "genCriteriaBtn", checkedArray.length > 0 );
    toggleElementDisabledState( "orCriteriaBtn", checkedArray.length > 1 );
    toggleElementDisabledState( "andCriteriaBtn", checkedArray.length > 1 && enableAndBtn );
}

function updateSearchButtonState()
{
    var table = document.getElementById( "criteriaEffectTable" );
    toggleElementDisabledState( "searchButton", table.rows.length > 0 );
}

function processCriteriaList( type )
{
    var checkedCriteriaArray = getCheckedCriteria();

    var array = new Array();

    switch( type )
    {
        case ACTION_DELETE:
        {
            for( var i = checkedCriteriaArray.length - 1; i >= 0; --i )
            {
               var critId = checkedCriteriaArray[ i ].id;
               processCriteriaById( critId, ACTION_DELETE, currentCriteria );
               deleteTableRowById( "criteriaTable", CRIT_LIST_ROW, critId );
            }
            break;
        }
        case ACTION_GENERAL_CRITERIA:
        {
            for( var i = checkedCriteriaArray.length - 1; i >= 0; --i )
            {
                var compositeCriterion = new CompositeSearchCriterion( checkedCriteriaArray[ i ].name, TYPE_GENERAL_CRITERION );
                compositeCriterion.subCriteria.push( checkedCriteriaArray[ i ] );
                array.push( compositeCriterion );
            }

            break;
        }
        case ACTION_AND_CRITERIA:
            var compositeCriterion = new CompositeSearchCriterion( checkedCriteriaArray[ 0 ].name, TYPE_AND_CRITERION );
            for( var i = checkedCriteriaArray.length - 1; i >= 0; --i )
            {
                compositeCriterion.subCriteria.push( checkedCriteriaArray[ i ] );
            }
            array.push( compositeCriterion );
            break;
        case ACTION_OR_CRITERIA:
            var compositeCriterion = new CompositeSearchCriterion( checkedCriteriaArray[ 0 ].name, TYPE_OR_CRITERION );
            for( var i = checkedCriteriaArray.length - 1; i >= 0; --i )
            {
                compositeCriterion.subCriteria.push( checkedCriteriaArray[ i ] );
            }
            array.push( compositeCriterion );
            break;
    }

    if( array.length > 0 )
    {
        var effectTable = document.getElementById( "criteriaEffectTable" );
        for( var i = 0; i < array.length; ++i )
        {
            var compositeCriterion = array[ i ];
            currentCompositeCriteria.push( compositeCriterion );

            var tr = effectTable.insertRow( -1 );
            tr.id = CRIT_EFFECT_ROW + compositeCriterion.id;

            var td = tr.insertCell( -1 );
            td.innerHTML = "<input name='" + CRIT_EFFECT_BTN + "' type='button' value='Delete' id='" + CRIT_EFFECT_BTN + compositeCriterion.id + "' onclick=\"deleteTableRowById('criteriaEffectTable','" + CRIT_EFFECT_ROW + "','" + compositeCriterion.id + "'); updateSearchButtonState();\" >";
            td.width = "50px";
            td.style.borderBottom = "1px solid black";
            td = tr.insertCell( -1 );
            td.colSpan = 100;
            td.innerHTML += compositeCriterion.getSummary();
            td.style.borderBottom = "1px solid black";
        }

        // clear all checkboxes
        var checkboxes = document.getElementsByName( CRIT_LIST_CHECKS );
        for( var t = 0; t < checkboxes.length; ++t )
            checkboxes[ t ].checked = false;
    }

    updateButtonStates();
    updateSearchButtonState();
}

function getFormattedString( value, type )
{
    var formattedString = value;

    switch( type )
    {
        case FORMAT_BOLD:
            formattedString = "<b>" + formattedString + "</b>";
            break;
        case FORMAT_ITALIC:
            formattedString = "<i>" + formattedString + "</i>";
            break;
    }

    return formattedString;
}

function highlightInvalidField( element )
{
    if( element )
    {
        element.focus();
        element.select();
        toggleSelectStates( true );   // special function must be called for IE to enable selects
    }
}

function setElementText( elementName, value )
{
    var element = document.getElementById( elementName );
    if( element )
        element.innerHTML = value;
}

function getFloatValue( floatValue )
{
    var value;
    if( floatValue.length > 0 )
    {
        // strip out non-numeric characters
        floatValue = floatValue.replace( NUMERIC_REGEXP, "" );

        value = parseFloat( floatValue );
        if( isNaN( value ) )
            value = null;
    }
    return value;
}

function deleteAllTableRows( tableName )
{
    var table = document.getElementById( tableName );
    if( table )
    {
        var rows = table.rows;
        for( var i = rows.length - 1; i >= 0; --i )
            table.deleteRow( i );
    }
}

function deleteTableRowById( tableName, suffix, rowId )
{
    var table = document.getElementById( tableName );
    if( table )
    {
        var rows = table.rows;
        var targetRow = suffix + rowId;
        for( var i = rows.length - 1; i >= 0; --i )
        {
            if( rows[i].id == targetRow )
            {
                table.deleteRow( i );
                break;
            }
        }
    }
}

function processCriteriaById( id, type, array )
{
    for( var i = array.length - 1; i >=0; --i )
    {
        if( array[ i ].id == id )
        {
            switch( type )
            {
                case ACTION_DELETE:
                    array.splice( i, 1 );
                    break;
                default:
                    return array[ i ];
            }
        }
    }

    return null;
}

function doSearch()
{
    var searchString = "";
    var searchType = "";
    var searchTypes = document.getElementsByName( "searchType" );
    for( var j = 0; j < searchTypes.length; ++j )
    {
        if( searchTypes[ j ].checked )
        {
            searchType = searchTypes[ j ].value;
        }
    }

    // construct search param string
    var criteriaBtns = document.getElementsByName( CRIT_EFFECT_BTN );
    for( var i = 0; i < criteriaBtns.length; ++i )
    {
        var criterion = processCriteriaById( criteriaBtns[ i ].id.substring( CRIT_EFFECT_BTN.length ), ACTION_GENERAL_CRITERIA, currentCompositeCriteria );
        searchString += "&searchParam" + i + "=" + escape( criterion.getSearchString() );
    }

    var filterTBD = document.getElementById( "filterTBD" ).checked;
    var filterPostalCode = document.getElementById( "filterPostalCode" ).checked;
    var postalCode = document.getElementById( "filterPostalCode" ).checked ? document.getElementById( "postalCode" ).value : "";
    if( filterPostalCode && postalCode.length == 0 )
    {
        toggleSelectStates( false );   // special function must be called for IE to disable selects
        showMessageDialog( "If filtering by postal code is desired, please enter a postal code.", function(){ highlightInvalidField( document.getElementById( "postalCode" ) ) } );
        return;
    }
    if( !validateValue( "NumberRange", document.getElementById( "maxNumResults" ), "0", "300", false ) )
        return;

    var maxNumResults = document.getElementById( "maxNumResults" ).value;

    var requestString = "SearchServlet?data=getSearchResults";
    requestString += "&searchType=" + searchType;
    requestString += "&filterTBD=" + filterTBD;
    requestString += "&filterPostalCode=" + filterPostalCode;
    requestString += "&postalCode=" + postalCode;
    requestString += "&maxNumResults=" + maxNumResults;

    toggleElementVisibility( "resultDiv", false );

    // disable search button until search returns
    updateStatusMessage( "Running search...", "green" );
    toggleElementDisabledState( "searchButton", false );

    //delete previous results
 	deleteAllTableRows( "resultHeaderTable" );
 	deleteAllTableRows( "resultTable" );

    //do search request asynchronously so UI doesn't lock up
	var request = getRequest();
	request.open("get", requestString + searchString, true);
    request.onreadystatechange = function(aEvt)
    {
      if (request.readyState == 4)  // loaded state
      {
         // enable search button since search is complete
         toggleElementDisabledState( "searchButton", true );

         if(request.status == 200)  // OK
         {
            var numResults = 0;
            // populate results table
            switch( searchType )
            {
                case "searchStyles":
                {
                    numResults = fillStyleTable( request.responseText );
                    break;
                }
                case "searchModels":
                {
                    numResults = fillResultTable( [ "Model Id", "Model Name", "Release Date" ],
                            [ "20%", "40%", "40%" ], request.responseText );
                    break;
                }
            }

            //show results table
            toggleElementVisibility( "resultDiv", true );
            updateStatusMessage( "Search Complete - " + numResults + " Results", "green" );
         }
         else
            updateStatusMessage( "An error occurred during the search: <br><br>" + request.responseText, "red" );
      }
    };
    request.send(null);
}

function fillStyleTable(responseText)
{
    // create table header
    var headerTable = document.getElementById( "resultHeaderTable" );
    var headerRow = headerTable.insertRow( -1 );
    var td = headerRow.insertCell( -1 );
    td.align = "center";
    td.style.width = "10%";
    td.innerHTML = "&nbsp;";
    td = headerRow.insertCell( -1 );
    td.style.width = "70%";
    td.align = "center";
    td.innerHTML = getFormattedString( "Style", FORMAT_BOLD );
    td = headerRow.insertCell( -1 );
    td.align = "center";
    td.style.width = "10%";
    td.innerHTML = getFormattedString( "Invoice", FORMAT_BOLD );
    td = headerRow.insertCell( -1 );
    td.align = "center";
    td.style.width = "10%";
    td.innerHTML = getFormattedString( "MSRP", FORMAT_BOLD );

    var table = document.getElementById( "resultTable" );

    var numResults = 0;

    if( responseText.length > 0 )
    {
         //populate table with new styles
        var allStyles = responseText.split(";;");
        for (var i = 0; i < allStyles.length; i++)
        {
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

        numResults = allStyles.length;
    }

    return numResults;
}

function fillResultTable(headers, widths, responseText)
{
    // create table header
    var headerTable = document.getElementById( "resultHeaderTable" );
    var headerRow = headerTable.insertRow( -1 );
    for( var i = 0; i < headers.length; ++i )
    {
        var td = headerRow.insertCell( -1 );
        td.style.width = widths[ i ];
        td.align = "center";
        td.innerHTML = getFormattedString( headers[ i ], FORMAT_BOLD );
    }

    var table = document.getElementById( "resultTable" );

    var numResults = 0;

    if( responseText.length > 0 )
    {
         //populate table with new data
        var results = responseText.split(";;");
        for (var i = 0; i < results.length; i++)
        {
            var result = results[i];
            var resultParams = result.split("~~");

            var row = table.insertRow(-1);
            for( var j = 0; j < headers.length; ++j )
            {
                var paramValue = resultParams[ j ];

                var td = row.insertCell(-1);
                td.style.width = widths[ j ];
                td.align = "center";
                td.innerHTML = paramValue;
            }
        }
        numResults = results.length;
    }

    return numResults;
}

function updateStatusMessage( message, color )
{
   setElementText( "statusDiv", message );
   if( color != null )
       document.getElementById( "statusDiv" ).style.color = color;
}

function postalFilterClicked()
 {
    toggleElementDisabledState( "postalCode", document.getElementById( "filterPostalCode" ).checked );
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
     request.open("get", "ScratchListServlet?cmd=add&styleId=" + styleId, false);
     request.send(null);

     //get response
     var scratchListId = request.responseText;
     if( scratchListId != "fail" ){

         var display = year + " " + division + " " + model + " " + trim;

         //add style to scratchlist table
         var table = document.getElementById( "scratchListTable" );
         var row = table.insertRow(-1);
         var td = row.insertCell(-1);
         td.setAttribute("width","5%");
         td.setAttribute("align","center");
         td.innerHTML = "<input type='checkbox' onClick='updateScratchListButtons()' name='scratchListCheckboxes' value='" + scratchListId + "' modelyear='" + year + "' stylename='" + display +"' ></>";
         var td2 = row.insertCell(-1);
         td2.innerHTML = display;

         //show scratchlist table
         toggleElementVisibility("scratchListDiv", true);

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
         document.getElementById("comparableButton").disabled = true;
         document.getElementById("configureButton").disabled = true;
         document.getElementById("compareSBSButton").disabled = true;
         document.getElementById("compareABCButton").disabled = true;
         document.getElementById("removeButton").disabled = true;
         document.getElementById("removeAllButton").disabled = false;
     }
     else if( numChecked == 1 ) {
         document.getElementById("comparableButton").disabled = false;
         document.getElementById("configureButton").disabled = false;
         document.getElementById("compareSBSButton").disabled = true;
         document.getElementById("compareABCButton").disabled = true;
         document.getElementById("removeButton").disabled = false;
         document.getElementById("removeAllButton").disabled = false;
     }
     else {
         document.getElementById("comparableButton").disabled = true;
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
             request.open("get", "ScratchListServlet?cmd=remove&sratchListId=" + checkBoxes[i].value, false);
             request.send(null);
             var result = request.responseText;
             if( result !=  "fail" ){
                 table.deleteRow( i );
             }
         }
     }

     //hide table if no more rows
     table = document.getElementById("scratchListTable");
     rows = table.rows;
     toggleElementVisibility( "scratchListDiv", rows.length > 0 );

    updateScratchListButtons();
 }

function removeScratchListAll() {
     var table = document.getElementById("scratchListTable");
     deleteAllTableRows( "scratchListTable" );

     toggleElementVisibility( "scratchListDiv", false );

    updateScratchListButtons();
}

function findComparable()
{
    var filterTBD = document.getElementById( "filterTBD" ).checked;
    var filterPostalCode = document.getElementById( "filterPostalCode" ).checked;
    var postalCode = document.getElementById( "filterPostalCode" ).checked ? document.getElementById( "postalCode" ).value : "";
    if( filterPostalCode && postalCode.length == 0 )
    {
        toggleSelectStates( false );   // special function must be called for IE to disable selects
        showMessageDialog( "If filtering by postal code is desired, please enter a postal code.", function(){ highlightInvalidField( document.getElementById( "postalCode" ) ) } );
        return;
    }
    if( !validateValue( "NumberRange", document.getElementById( "maxNumResults" ), "0", "300", false ) )
        return;

    var maxNumResults = document.getElementById( "maxNumResults" ).value;

    var requestString = "SearchServlet?data=findComparable";
    requestString += "&filterTBD=" + filterTBD;
    requestString += "&filterPostalCode=" + filterPostalCode;
    requestString += "&postalCode=" + postalCode;
    requestString += "&maxNumResults=" + maxNumResults;

    var modelYear = "";
    var styleName = "";

    //get id to find comparable
   	var checkBoxes = document.getElementsByName("scratchListCheckboxes");
	var scratchListId = "";
    for (var i = 0; i < checkBoxes.length; i++) {
        if( checkBoxes[i].checked ) {
            scratchListId = checkBoxes[i].value;
            modelYear = checkBoxes[i].getAttribute( "modelyear" );
            styleName = checkBoxes[i].getAttribute( "stylename" );
            break;
        }
    }

    // retrieve available makes for the current model year of the selected vehicle
    // and show dialog to select makes
    var request = getRequest();
    request.open("get", "SearchServlet?data=getAvailableMakes&scratchListId=" + scratchListId + "&year=" + modelYear, false);
    request.send(null);

    var contentHTML = "";
    var response = request.responseText.split(";;");
    for (var i = 0; i < response.length; i++)
    {
        var makeValues = response[i].split("~~");
       	if( makeValues.length == 2 )
           contentHTML += "<input name='makeChecks' type='checkbox' checked value='" + makeValues[ 0 ] + "'>" + makeValues[ 1 ] + "&nbsp;";
        if( i > 0 && i % 5 == 0 )
            contentHTML += "<br>";  // put a break in after every 5 vehicles
    }

    toggleSelectStates( false );   // special function must be called for IE to disable selects

    // show makes dialog and then conduct search for comparable vehicles based on what makes were selected
    showContentDialog( "Please select which makes you would like included in the search to find comparable vehicles.", contentHTML, function()
            {
                toggleSelectStates( true );   // special function must be called for IE to enable selects

                var chosenMakes = "";

                var makeChecks = document.getElementsByName( "makeChecks" );
                for( var i = 0; i < makeChecks.length; ++i )
                {
                    if( makeChecks[ i ].checked )
                        chosenMakes += (chosenMakes.length == 0 ? makeChecks[ i ].value : ";;" + makeChecks[ i ].value);
                }

                if( chosenMakes.length == 0 )
                {
                    showMessageDialog( "No makes were selected for find comparable search.", null );
                    return;
                }

                //delete previous results
                deleteAllTableRows( "resultHeaderTable" );
                deleteAllTableRows( "resultTable" );

                updateStatusMessage( "Running search...", "green" );
                toggleElementDisabledState( "comparableButton", true );

                requestString += "&scratchListId=" + scratchListId;
                requestString += "&makes=" + chosenMakes;

                //do search request asynchronously so UI doesn't lock up
                var request = getRequest();
                request.open("get", requestString, true);
                request.onreadystatechange = function(aEvt)
                {
                  if (request.readyState == 4)  // loaded state
                  {
                     // enable search button since search is complete
                     toggleElementDisabledState( "comparableButton", true );

                     if(request.status == 200)  // OK
                     {
                        var numResults = 0;

                        numResults = fillStyleTable( request.responseText );

                        //show results table
                        toggleElementVisibility( "resultDiv", true );
                        updateStatusMessage( "Found " + numResults + " Vehicles comparable to " + styleName, "green" );
                     }
                     else
                        updateStatusMessage( "An error occurred during the search: <br><br>" + request.responseText, "red" );
                  }
                };
                request.send(null);
            }
    );
}