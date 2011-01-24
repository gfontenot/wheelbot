<?
require_once("ACCS_Sample_Util.php");

//===========Comparison Functions===================

//========getSideBySideComparisonStyles
function getSideBySideComparisonResult( $accountInfo, $scratchListIds ) {

	$compareService = getConfigCompareService();
	$proxy = $compareService->getProxy();

	//get style state for each style
	$ids = split( "~~", $scratchListIds );
	$chromeStyleStateArray = array();
	for ($i = 0; $i < count($ids); $i++ ) {
		$chromeStyleState = getConfigurationState( $ids[$i] );
		$chromeStyleStateArray[] = $chromeStyleState;
	}

    $categoryIds = getCategoryIds( $accountInfo, $compareService );
    $techSpecIds = getTechSpecIds( $accountInfo, $compareService );

    $returnParameters = getStyleReturnParametersNone();
    $returnParameters["includeConsumerInfo"] = true;

	$compareRequest = array(
		"accountInfo" => $accountInfo,
		"comparisonConfigurationStates" => $chromeStyleStateArray,
		"includeCategoryComparisons" => true,
		"filteredCategoryIds" => $categoryIds,
		"includeTechSpecComparisons" => true,
		"filteredTechSpecTitleIds" => $techSpecIds,
		"returnParameters" => $returnParameters
	);

    $sideBySideComparisonResult = $proxy->compareSideBySide($compareRequest);

	return $sideBySideComparisonResult;
}

//========getCategoryIds
function getCategoryIds( $accountInfo, $compareService ) {

	$proxy = $compareService->getProxy();
    $categories = $proxy->getCategoryDefinitions( array( "accountInfo" => $accountInfo ) );
	$categories = $categories["array"];

    $categoryIds = array();
	for( $i = 0; $i < count($categories); $i++ ){
	    $categoryIds[] = $categories[$i]["categoryId"];
	}

	return $categoryIds;
}

//========getTechSpecArray
function getTechSpecIds( $accountInfo, $compareService ) {

	$proxy = $compareService->getProxy();
    $techSpecs = $proxy->getTechnicalSpecificationDefinitions( array( "accountInfo" => $accountInfo ) );
	$techSpecs = $techSpecs["array"];

    $techSpecIds = array();
	for( $i = 0; $i < count($techSpecs); $i++ ){
		$techSpecIds[] = $techSpecs[$i]["titleId"];
	}

	return $techSpecIds;
}

//========getStyleWarranty
function getStyleWarranty( $accountInfo, $scratchListId ) {

	$configService = getConfigCompareService();
    $proxy = $configService->getProxy();

	$chromeStyleState = getConfigurationState( $scratchListId );
	$returnParams = getStyleReturnParametersNone();
	$returnParams["includeConsumerInfo"] = true;

	$styleRequest = array(
		"accountInfo" => $accountInfo,
        "configurationState" => $chromeStyleState,
		"returnParameters" => $returnParams
	);
	$configElement = $proxy->getConfiguration($styleRequest);

	$warranty = $configElement["configuration"]["consumerInformation"]["warranty"];

	return $warranty;
}

//===========Comparison Functions===================

//========getAdvantageComparison
function getAdvantageComparison( $accountInfo, $primaryScratchListId, $scratchListIds ) {

    $primaryStyleState = getConfigurationState( $primaryScratchListId );

    $comparedStyleStates = array();
    $ids = split( "~~", $scratchListIds );
    for( $i = 0; $i < count($ids); $i++ ) {
        $comparedStyleState = getConfigurationState( $ids[$i] );
        $comparedStyleStates[] = $comparedStyleState;
    }

	$compareRequest = array(
        "accountInfo" => $accountInfo,
        "ruleSetName" => "chromerules",
        "pivotConfigurationState" => $primaryStyleState,
        "comparisonConfigurationStates" => $comparedStyleStates,
        "returnParameters" => getStyleReturnParametersNone()
	);
	$compareService = getConfigCompareService();
	$proxy = $compareService->getProxy();
    $advantageComparisonResult = $proxy->compareAdvantages($compareRequest);

	return $advantageComparisonResult;
}


//========getConfigurationState
function getConfigurationState( $scratchListId ) {
    $configState = $_SESSION["scratchlist"][$scratchListId];
    if( !isset($configState["selectedColor"]) ){
        $configState["selectedColor"] = getColorSelectionState();
    }
    return $configState;
}

?>