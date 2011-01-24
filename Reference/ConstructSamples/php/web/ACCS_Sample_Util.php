<?
require_once("nusoap.php");
require_once("class.wsdlcache.php");

//========getConfigCompareService
function getConfigCompareService() {
	$wsdlURL = "http://platform.chrome.com/AutomotiveConfigCompareService/AutomotiveConfigCompareService3?WSDL";

	$cache = new wsdlcache();
	$wsdl = $cache->get($wsdlURL);
	if ($wsdl == null) {
		$wsdl = new wsdl($wsdlURL);
		$cache->put($wsdl);
	}
	$configService = new soapclient($wsdl, true);
	return $configService;
}

//========fixArray
function fixArray( $possibleArray ) {
	if (!is_array($possibleArray[0])) {
		// make single element array
		$possibleArray = array($possibleArray);
	}
	return $possibleArray;
}

function getPrimaryOptionDescription( $option ){
    $optionDesc = "";
    $descriptions = fixArray($option["descriptions"]);
    for( $i = 0; $i < count($descriptions); $i++ ) {
        if( $descriptions[$i]["type"] == "PrimaryName" ){
            $optionDesc = $optionDesc . $descriptions[$i]["description"];
        }
    }
    return $optionDesc;
}

function getExtendedOptionDescription( $option ){
    $optionDesc = "";
    $descriptions = fixArray($option["descriptions"]);
    for( $i = 0; $i < count($descriptions); $i++ ) {
        if( $descriptions[$i]["type"] == "Extended" ){
            $optionDesc = $optionDesc . $descriptions[$i]["description"];
        }
    }
    return $optionDesc;
}

function getFullOptionDescription( $option ){
    $fullDescription = "";
    $primaryDescription = getPrimaryOptionDescription( $option );
    $extendedDescription = getExtendedOptionDescription( $option );
    if( strlen($extendedDescription) > 0 ){
        $fullDescription = $primaryDescription . " " . $extendedDescription;
    } else {
        $fullDescription = $primaryDescription;
    }
    return $fullDescription;
}

//==========getStyleReturnParameters
function getStyleReturnParameters() {

	$returnParams = array(
		"includeStandards" => true,
		"includeOptions" => true,
		"includeOptionDescriptions" => true,
		"includeSpecialEquipmentOptions" => true,
		"includeColors" => true,
		"includeInvalidColors" => true,
		"includeEditorialContent" => true,
		"includeConsumerInfo" => true,
		"includeStructuredConsumerInfo" => true,
		"includeConfigurationChecklist" => true,
		"includeAdditionalImages" => true,
		"includeTechSpecs" => true,
		"filteredTechSpecTitleIds" => array()
	);

    return $returnParams;
}

//============================================getStyleReturnParametersNone
function getStyleReturnParametersNone() {

	$returnParams = array(
		"includeStandards" => false,
		"includeOptions" => false,
		"includeOptionDescriptions" => false,
		"includeSpecialEquipmentOptions" => false,
		"includeColors" => false,
		"includeInvalidColors" => false,
		"includeEditorialContent" => false,
		"includeConsumerInfo" => false,
		"includeStructuredConsumerInfo" => false,
		"includeConfigurationChecklist" => false,
		"includeAdditionalImages" => false,
		"includeTechSpecs" => false,
		"filteredTechSpecTitleIds" => array()
	);

    return $returnParams;
}

//==========getColorSelectionState
function getColorSelectionState() {
	$colorSelectionState = array(
		"combinationColorId" => "",
		"secondaryColorId" => "",
		"auxiliaryChoiceColorId" => "",
		"validWithCurrentConfiguration" => false
	);

	return $colorSelectionState;
}

// param string should be of form:
// compositeName=orCrit&compositeType=or&compositeMustHave=true&name=airbagSideType&type=String&mustHave=true&value=sbs&min=&max=;;&name=hasMoonRoof&type=Boolean&mustHave=true&value=true&min=&max=
function parseCompositeSearchCriterion( $paramString ){

    $criterion = NULL;
    $compositeName = NULL;
    $compositeType = "";
    $mustHave = NULL;

    $criteria = split( ";;", $paramString ); // divide into subcriteria
    for( $i = 0; $i < count($criteria); $i++ ){    // process each subcriteria

        $attributeMap = parseAttributes( $criteria[$i] );

        if( $i == 0 ){
            $compositeType = $attributeMap["compositeType"];
            $compositeName = $attributeMap["compositeName"];
            $mustHave = (bool) $attributeMap["compositeMustHave"] ? "MustHave" : "MustNotHave";
            $criterion = array(
                "name" => $compositeName,
                "type" => $compositeType,
                "mustHave" => $mustHave,
                "subCriteria" => array()
            );
        }

        $subCriterion = createSearchCriterion( $attributeMap );
        if( !is_null($subCriterion) ){
            $criterion["subCriteria"][] = $subCriterion;
        }
    }

    return $criterion;
}

// takes a string of form key1=value1&key2=value2 and returns a map of the form: key1 -> value1, etc.
function parseAttributes( $attributeString ){

    $attributeMap = array();
    $attributes = split( "&", $attributeString );
    for( $i = 0; $i < count($attributes); $i++ ){
        $values = split( "=", $attributes[$i] );
        if( count($values) == 2 ){
            $attributeMap[$values[0]] = $values[1];
        }
    }

    return $attributeMap;
}

function createSearchCriterion( $attributes ){

    $criterion = NULL;

    $name = $attributes["name"];
    $type = $attributes["type"];
    $importance = (bool) $attributes["mustHave"] ? "MustHave" : "MustNotHave";
    $value = $attributes["value"];
    $min = $attributes["min"];
    $max = $attributes["max"];

    $criterion = array(
        "name" => $name,
        "importance" => $importance,
        "type" => $type,
        "value" => $value,
        "min" => $min,
        "max" => $max
    );

    return $criterion;
}

function getFilterRules( $orderAvailability ){
	$filterRules = array(
		"orderAvailability" => $orderAvailability,
		"marketClassIds" => array(),
		"vehicleTypes" => array(),
		"msrpRange" => array( "minimumPrice" => 0.0, "maximumPrice" => 999999999.0 )
	);
	return $filterRules;
}

?>