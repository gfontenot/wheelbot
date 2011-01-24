<?
require_once("ACCS_Sample_Util.php");
session_start( );

$configService = getConfigCompareService();
$proxy = $configService->getProxy();
$searchDescriptorMap = NULL;

//============================================get new locale
if( $_GET["data"] == "locale" ){

	$country = "US";
	$language = "en";

	$localeString = $_GET["locale"];
	if ( $localeString == "enCA" ) {
		$country = "CA";
		$language = "en";
	}
	else if ( $localeString == "frCA" ) {
		$country = "CA";
		$language = "fr";
	}

	$locale = array(
			"country" => $country,
			"language" => $language
	);

	$accountInfo = array(
			"accountNumber" => "0",
			"accountSecret" => "accountSecret",
			"locale" => $locale,
			"sessionId" => "0"
	);

	$_SESSION["accountInfo"] = $accountInfo;

} else if( $_GET["data"] == "orderAvailability" ){

	$orderAvailability = $_GET["orderAvailability"];
	$_SESSION["orderAvailability"] = $orderAvailability;

} else if( $_GET["data"] == "getSearchCriteria" ){

    $accountInfo = $_SESSION["accountInfo"];

    // construct the request to retrieve all available search criteria
    $request = array(
        "accountInfo" => $accountInfo,
    );
    $descriptors = $proxy->getSearchCriterionDescriptors($request);
    $descriptors = $descriptors["array"];

    $returnString = "";
    for( $i = 0; $i < count($descriptors); $i++ ){
        if( $i > 0 ){
            $returnString .= ";;"; // separator between descriptors
        }
        $returnString .= $descriptors[$i]["name"] . "~~"; // name
        $returnString .= $descriptors[$i]["type"] . "~~"; // type
        $returnString .= ( isset($descriptors[$i]["min"]) ? $descriptors[$i]["min"] : "" ) . "~~"; // min
        $returnString .= ( isset($descriptors[$i]["max"]) ? $descriptors[$i]["max"] : "" ) . "~~"; // max
        $returnString .= ( isset($descriptors[$i]["unit"]) ? $descriptors[$i]["unit"]["value"] : "" ); // unit
    }

    print $returnString;

} else if( $_GET["data"] == "getSearchResults" ) {

    $accountInfo = $_SESSION["accountInfo"];
    $orderAvailability = $_SESSION["orderAvailability"];

    $searchType = $_GET["searchType"];
    $postalCode = $_GET["postalCode"];

    $filterTBD = false;
    if( isset( $_GET["filterTBD"] ) ){
        $filterTBD = $_GET["filterTBD"];
    }

    $filterPostalCode = false;
    if( isset( $_GET["filterPostalCode"] ) ){
        $filterPostalCode = $_GET["filterPostalCode"];
    }

    $maxNumResults = 0;
    if( isset( $_GET["maxNumResults"] ) ){
        $maxNumResults = $_GET["maxNumResults"];
    }

    $generalCriteria = array();
    $andCriteria = array();
    $orCriteria = array();

    // extract all the search params from the request
    // each param will be similar in form to:
    // compositeName=division&compositeType=general&compositeMustHave=true&name=division&type=String&mustHave=true&value=ford&min=&max=
    $searchParamIndex = 0;
    $searchParamKey = "searchParam" . $searchParamIndex;
    while( isset( $_GET[$searchParamKey] ) ){
        $paramString = $_GET[$searchParamKey];
        $searchParamKey = "searchParam" . (++$searchParamIndex);
        $compositeCriterion = parseCompositeSearchCriterion( $paramString );
        if( !is_null($compositeCriterion) ){
            if( $compositeCriterion["type"] == "general" ){
                $generalCriteria[] = $compositeCriterion["subCriteria"][0];
            } else if( $compositeCriterion["type"] == "and" ) {
                $subCriteria = $compositeCriterion["subCriteria"];
                $andCriterion = array(
                    "name" => $compositeCriterion["name"],
                    "criteriaArray" => $subCriteria
                );
                $andCriteria[] = $andCriterion;
            } else if( $compositeCriterion["type"] == "or" ) {
                $subCriteria = $compositeCriterion["subCriteria"];
                $orCriterion = array(
                    "importance" => $compositeCriterion["mustHave"],
                    "criteriaArray" => $subCriteria
                );
                $orCriteria[] = $orCriterion;
            }
        }
    }

    $searchCriteria = array(
        "criteriaArray" => $generalCriteria,
        "orCriteriaArray" => $orCriteria,
        "andCriteriaArray" => $andCriteria,
        "filterTBD" => $filterTBD,
        "filterByPostalCode" => $filterPostalCode,
        "postalCode" => $postalCode,
        "maxNumResults" => $maxNumResults
    );
    $request = array(
        "accountInfo" => $accountInfo,
        "orderAvailability" => $orderAvailability,
        "searchRequest" => $searchCriteria
    );

    if( $searchType == "searchStyles" ){

        $styles = $proxy->searchStyles($request);
        $styles = fixArray( $styles["style"] );
        for( $i = 0; $i < count($styles); $i++ ){
            $style = $styles[$i];
            $invoice = "$" . $style["baseInvoice"];
            $msrp = "$" .  $style["baseMsrp"];
            if( $i > 0 ){
                $returnString .= ";;";
            }
            $returnString .= $style["modelYear"] . "~~" . $style["divisionName"] . "~~" . $style["modelName"] . "~~" . $style["styleName"] . "~~" . $invoice . "~~" . $msrp . "~~" . $style["styleId"];
        }

    } else if( $searchType == "searchModels" ) {

        $searchResults = $proxy->searchModels($request);
        $searchResults = fixArray( $searchResults["result"] );
        for( $i = 0; $i < count($searchResults); $i++ ){
            if( $i > 0 ){
                $returnString .= ";;";
            }
            $dateString = "";
            $model = $searchResults[$i]["model"];
            if( isset($model["lastModifiedDate"] ) ){
                $dateString = $model["lastModifiedDate"];
            }
            $returnString .= $model["modelId"] . "~~" . $model["modelName"] . "~~" . $dateString;
        }

    }

    print $returnString;

} else if( $_GET["data"] == "findComparable" ){

    // This search is designed to find similar vehicles to the target vehicle based on the vehicle's
    // model year, market class, body style, etc.

    $accountInfo = $_SESSION["accountInfo"];
    $postalCode = $_GET["postalCode"];

    $filterTBD = false;
    if( isset( $_GET["filterTBD"] ) ){
        $filterTBD = $_GET["filterTBD"];
    }

    $filterPostalCode = false;
    if( isset( $_GET["filterPostalCode"] ) ){
        $filterPostalCode = $_GET["filterPostalCode"];
    }

    $maxNumResults = 0;
    if( isset( $_GET["maxNumResults"] ) ){
        $maxNumResults = $_GET["maxNumResults"];
    }

    $scratchListId = $_GET["scratchListId"];
    $configState = $_SESSION["scratchlist"][$scratchListId];
    if( !isset($configState["selectedColor"]) ){
	    $configState["selectedColor"] = getColorSelectionState();
	}

    // Retrieve target vehicle info so we know what to base comparable search on
    $orderAvailability = $configState["orderAvailability"];
    $styleRequest = array(
		"accountInfo" => $accountInfo,
		"configurationState" => $configState,
		"returnParameters" => getStyleReturnParameters()
	);
    $toggleResponse = $proxy->getStyleFullyConfigured($styleRequest);
    $configStyle = $toggleResponse["configuration"];

    // now build up the search criteria
    $generalCriteria = array();
    $andCriteria = array();
    $orCriteria = array();

    // only search for model year of target vehicle or newer
    $yearCriterion = array(
        "name" => "year",
        "importance" => "MustHave",
        "type" => "NumberRange",
        "min" => $configStyle["style"]["modelYear"]
    );
    $generalCriteria[] = $yearCriterion;

    // only search for selected makes
    $chosenMakes = split( ";;", $_GET["makes"] );
    if( count($chosenMakes) > 0 ){
        $makeCriteriaList = array();
        for( $i = 0; $i < count($chosenMakes); $i++ ){
            $makeCriterion = array(
                "name" => "divisionId",
                "importance" => "MustHave",
                "type" => "String",
                "value" => $chosenMakes[$i]
            );
            $makeCriteriaList[] = $makeCriterion;
        }
        // make an OrCriterion that includes all of the passed in makes (e.g. This vehicle make must = Ford or Chevy or Honda, etc.)
        $makeListCriterion = array(
            "importance" => "MustHave",
            "criteriaArray" => $makeCriteriaList
        );
        $orCriteria[] = $makeListCriterion;
    }

    // only search for vehicles with the same market class as this target vehicle
    $marketClassCriterion = array(
        "name" => "marketClassId",
        "importance" => "MustHave",
        "type" => "String",
        "value" => $configStyle["style"]["marketClassId"]
    );
    $generalCriteria[] = $marketClassCriterion;

    // only search for selected vehicles with same body type as target vehicle
    $bodyTypeList = array();
    $bodyTypes = fixArray( $configStyle["style"]["bodyTypes"] );
    for( $i = 0; $i < count($bodyTypes); $i++ ){
        $bodyType = $bodyTypes[$i];
        $bodyTypeCriterion = array(
            "name" => "bodyType",
            "importance" => "MustHave",
            "type" => "String",
            "value" => $bodyType["bodyTypeId"]
        );
        $bodyTypeList[] = $bodyTypeCriterion;
    }

    // make an OrCriterion that includes all of the body types (e.g. This vehicle body type must = Short Bed or Crew Cab Pickup, etc.)
    $bodyTypeCriterion = array(
        "importance" => "MustHave",
        "criteriaArray" => $bodyTypeList
    );
    $orCriteria[] = $bodyTypeCriterion;

    // only search for vehicles with the same number of passenger doors on target vehicle
    $passengerDoorsCriterion = array(
        "name" => "numberOfDoors",
        "importance" => "MustHave",
        "type" => "String",
        "value" => $configStyle["style"]["passengerDoors"]
    );
    $generalCriteria[] = $passengerDoorsCriterion;

    $passengerCapacityTechSpecId = 8;
    $wheelbaseTechSpecId = 301;
    $variancePercentage = 0.05;

    // match on certain tech specs (passenger capacity, wheelbase - if truck or suv)
    $techSpecs = $configStyle["technicalSpecifications"];
    for( $i = 0; $i < count($techSpecs); $i++ ){

        // passenger capacity
        if( $techSpecs[$i]["titleId"] == $passengerCapacityTechSpecId ){
            $passengerCapacity = $techSpecs[$i]["value"];
            $passengerCapacityCriterion = array(
                "name" => "passengerCapacity",
                "importance" => "MustHave",
                "type" => "TechnicalSpecificationRange",
                "min" => $passengerCapacity,
                "max" => $passengerCapacity
            );
            $generalCriteria[] = $passengerCapacityCriterion;
        }

        // if this vehicle has a meaningful wheelbase, then add this to the search criteria
        if( doesWheelbaseMatter( $configStyle["style"]["marketClassName"] ) && $techSpecs[$i]["titleId"] == $wheelbaseTechSpecId ){
            $value = $techSpecs[$i]["value"];
            $wheelbase = doubleval( value );
            // create a range that the wheelbase of search vehicles can fall within
            if( $wheelbase > 0 ){
                $min = $wheelbase * (1 - $variancePercentage);
                $max = $wheelbase * (1 + $variancePercentage);
                $wheelbaseCriterion = array(
                    "name" => "wheelbase",
                    "importance" => "MustHave",
                    "type" => "TechnicalSpecificationRange",
                    "min" => $min,
                    "max" => $max
                );
                $generalCriteria[] = $wheelbaseCriterion;
            }
        }
    }

    // only search for vehicles that fall within a certain msrp price range (if it has a price)
    $priceState = $configStyle["configuredPriceState"];
    if( $priceState == "Actual" || $priceState == "Estimated" ){
        // create a range that the msrp of search vehicles can fall within
        $min = $configStyle["configuredTotalMsrp"] * (1 - $variancePercentage);
        $max = $configStyle["configuredTotalMsrp"] * (1 + $variancePercentage);
        $priceCriterion = array(
            "name" => "msrp",
            "importance" => "MustHave",
            "type" => "MoneyRange",
            "min" => $min,
            "max" => $max
        );
        $generalCriteria[] = $priceCriterion;
    }

    // now create a criteria to exclude vehicles with the same model as the target vehicle
    $modelCriterion = array(
        "name" => "modelId",
        "importance" => "MustNotHave",
        "type" => "String",
        "value" => $configStyle["style"]["modelId"]
    );
    $generalCriteria[] = $modelCriterion;

    // Create the search service request
    $searchCriteria = array(
        "criteriaArray" => $generalCriteria,
        "orCriteriaArray" => $orCriteria,
        "andCriteriaArray" => $andCriteria,
        "filterTBD" => $filterTBD,
        "filterByPostalCode" => $filterPostalCode,
        "postalCode" => $postalCode,
        "maxNumResults" => $maxNumResults
    );
    $request = array(
        "accountInfo" => $accountInfo,
        "orderAvailability" => $orderAvailability,
        "searchRequest" => $searchCriteria
    );

    $styles = $proxy->searchStyles($request);
    $styles = fixArray( $styles["style"] );
    for( $i = 0; $i < count($styles); $i++ ){
        $style = $styles[$i];
        $invoice = "$" . $style["baseInvoice"];
        $msrp = "$" .  $style["baseMsrp"];
        if( $i > 0 ){
            $returnString .= ";;";
        }
        $returnString .= $style["modelYear"] . "~~" . $style["divisionName"] . "~~" . $style["modelName"] . "~~" . $style["styleName"] . "~~" . $invoice . "~~" . $msrp . "~~" . $style["styleId"];
    }

    print $returnString;

} else if( $_GET["data"] == "getAvailableMakes" ){

    $accountInfo = $_SESSION["accountInfo"];
    $scratchListId = $_GET["scratchListId"];
    $modelYear = $_GET["year"];
    $configState = $_SESSION["scratchlist"][$scratchListId];
    $orderAvailability = $configState["orderAvailability"];

    $request = array(
        "accountInfo" => $accountInfo,
        "filterRules" => getFilterRules( $orderAvailability ),
        "modelYear" => $modelYear
    );

    $divisions = $proxy->getDivisions($request);
    $divisions = fixArray($divisions["division"]);

    for( $i = 0; $i < count($divisions); $i++ ){
        $division = $divisions[$i];
        if( $i > 0 ){
            $returnString .= ";;";
        }
        $returnString .= $division["divisionId"] . "~~" . $division["divisionName"];
    }

    print $returnString;

} else if ( $_GET["data"] == "getOptionalValues" ){
    initSearchDescriptorMap( $configService, $_SESSION["accountInfo"] );
    $tokenName = $_GET["tokenName"];
    $returnString = getOptionalValues( $tokenName );
    print $returnString;
}

function getOptionalValues( $searchTokenName ){
    $values = "";
    $searchDescriptorMap = $_SESSION["searchDescriptors"];
    if( isset( $searchDescriptorMap[$searchTokenName] ) ){
        $descriptor = $searchDescriptorMap[$searchTokenName];
        if( isset( $descriptor["values"] ) ){
            $choices = $descriptor["values"];
            for( $i = 0; $i < count($choices); $i++ ){
	            $choice = $choices[$i];
                $choiceText = $choice["id"] . "~~" . $choice["value"];
                $values .= ( strlen($values) == 0 ? $choiceText : ";;" . $choiceText);
            }
        }
    }
    return $values;
}

function initSearchDescriptorMap( $configService, $accountInfo ){
	if( ! isset($_SESSION["searchDescriptors"]) ){
        $request = array(
            "accountInfo" => $accountInfo,
        );
        $descriptors = $proxy->getSearchCriterionDescriptors($request);
        $descriptors = $descriptors["array"];
        $searchDescriptorMap = array();
        for( $i=0; $i < count($descriptors); $i++ ){
            $descriptor = $descriptors[$i];
            $searchDescriptorMap[$descriptor["name"]] = $descriptor;
        }
        $_SESSION["searchDescriptors"] = $searchDescriptorMap;
    }
}

function doesWheelbaseMatter( $marketClassName ) {

    $wheelbaseDoesMatter = false;

    if( strpos( $marketClassName, "Truck" ) ){
        $wheelbaseDoesMatter = true;
    } else if( strpos( $marketClassName, "Van" ) ){
        $wheelbaseDoesMatter = true;
    } else if( strpos( $marketClassName, "Special Purpose" ) ){
        $wheelbaseDoesMatter = true;
    } else if( strpos( $marketClassName, "Sport Utility" ) ){
        $wheelbaseDoesMatter = true;
    } else if( strpos( $marketClassName, "Commercial Vehicles" ) ){
        $wheelbaseDoesMatter = true;
    }

    return $wheelbaseDoesMatter;
}

?>