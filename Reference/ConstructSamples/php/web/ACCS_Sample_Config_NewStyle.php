<?
require_once("ACCS_Sample_Util.php");

//=============getConfigStyle()
function getConfigStyle( $scratchListId ) {

	$accountInfo = $_SESSION["accountInfo"];
    $chromeStyleState = $_SESSION["scratchlist"][$scratchListId];
    if( !isset($chromeStyleState["selectedColor"]) ){
	    $chromeStyleState["selectedColor"] = getColorSelectionState();
	}
	$returnParams = getStyleReturnParameters();

	$styleRequest = array(
		"accountInfo" => $accountInfo,
		"configurationState" => $chromeStyleState,
		"returnParameters" => $returnParams
	);
	$configService = getConfigCompareService();
	$proxy = $configService->getProxy();

	$toggleResponse = $proxy->getStyleFullyConfigured($styleRequest);
	$configuration = $toggleResponse["configuration"];

	//store fully configured state
	$_SESSION["scratchlist"][$scratchListId] = $configuration["style"]["configurationState"];

	return $configuration;
}

function loadSavedStyle( $filePathAndName ) {

	//get session variables
	$accountInfo = $_SESSION["accountInfo"];

	if( $accountInfo == null ) {
		$locale = array(
			"country" => "US",
			"language" => "en"
		);

		$accountInfo = array(
				"accountNumber" => "0",
				"accountSecret" => "accountSecret",
				"locale" => $locale,
				"sessionId" => "0"
		);

		$_SESSION["accountInfo"] = $accountInfo;
	}

	//get service and namespace
	$configService = getConfigCompareService();
	$proxy = $configService->getProxy();

	//open file and get style state
	$handle = fopen( $filePathAndName, 'r' );
	$fileContents = fread($handle, filesize($filePathAndName));
	fclose($handle);


	$configurationStateRequest = array(
		"accountInfo" => $accountInfo,
		"serializedValue" => $fileContents
	);
	$chromeStyleState = $proxy->materializeConfigurationState($configurationStateRequest);
	$chromeStyleState = $chromeStyleState["configurationState"];
    if( !isset($chromeStyleState["selectedColor"]) ){
	    $chromeStyleState["selectedColor"] = getColorSelectionState();
	}

	$returnParams = getStyleReturnParameters();
	$styleRequest = array(
		"accountInfo" => $accountInfo,
		"configurationState" => $chromeStyleState,
		"returnParameters" => $returnParams
	);
	$configElement = $proxy->getConfiguration($styleRequest);
	$configuration = $configElement["configuration"];

	return $configuration;
}

?>