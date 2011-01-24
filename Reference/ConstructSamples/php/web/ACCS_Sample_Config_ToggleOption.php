<?
session_start();

require_once("ACCS_Sample_Util.php");

//get service
$configService = getConfigCompareService();
$proxy = $configService->getProxy();

//get session variables
$accountInfo = $_SESSION["accountInfo"];
$configStyle = $_SESSION["configStyle"];

//get code to toggle
$originatingOptionCode = $_GET["optionCode"];

$chromeStyleState = $configStyle["style"]["configurationState"];
if( !isset($chromeStyleState["selectedColor"]) ){
    $chromeStyleState["selectedColor"] = getColorSelectionState();
}
$returnParams = getStyleReturnParameters();

$toggleOptionRequest = array(
	"accountInfo" => $accountInfo,
    "configurationState" => $chromeStyleState,
    "chromeOptionCode" => $originatingOptionCode,
    "returnParameters" => $returnParams,
    "returnDeltaConfiguration" => false
);

$optionToggleResponse = $proxy->toggleOption($toggleOptionRequest);
$newConfigStyle = $optionToggleResponse["configuration"];

//handle option conflict
if ( $optionToggleResponse["requiresToggleToResolve"] == "true" ) {

	//get conflicting option codes and descriptions
	$conflictingOptions = $optionToggleResponse["conflictResolvingChromeOptionCodes"];
	$conflictingOptionsAndDescs = "";
	for( $i = 0; $i < count($conflictingOptions); $i++ ) {
		$conflictingOptionCode = $conflictingOptions[$i];
		if( $i > 0 && $i < count($conflictingOptions ) )
			$conflictingOptionsAndDescs = $conflictingOptionsAndDescs . ";;";

		$conflictingOptionDesc = "";
		$options = $newConfigStyle["options"];
		for( $j = 0; $j < count($options); $j++ ) {
			$option = $options[$j];
			if( $option["chromeOptionCode"] == $conflictingOptionCode ) {
				$conflictingOptionsAndDescs = $conflictingOptionsAndDescs . $conflictingOptionCode . "::" . getPrimaryOptionDescription( $option );
				break;
			}
		}
	}

	//get manufacturer code and description for originating option code
	$originatingManuCodeAndDesc = "";
	$options = $newConfigStyle["options"];
	for( $i = 0; $i < count($options); $i++ ) {
		$option = $options[$i];
		if( $option["chromeOptionCode"] == $originatingOptionCode ) {
			$originatingManuCodeAndDesc = $option["oemOptionCode"] . ";;" . getPrimaryOptionDescription( $option );
			break;
		}
	}

	$returnString = "";
	if( $optionToggleResponse["originatingOptionAnAddition"] == "true" )
		$returnString = "yesConflict" . "~~" . $originatingManuCodeAndDesc . "~~add~~" . $conflictingOptionsAndDescs;
	else
		$returnString = "yesConflict" . "~~" . $originatingManuCodeAndDesc . "~~delete~~" . $conflictingOptionsAndDescs;

	//save style and return
	$_SESSION["configStyle"] = $newConfigStyle;
	print $returnString;
}
//no option conflict
else if ( $optionToggleResponse["requiresToggleToResolve"] == "false" ) {
	//get all option codes and states
	$options = $newConfigStyle["options"];
	$allOptions = "";
	for( $i = 0; $i < count($options); $i++ ) {
		$option =  $options[$i];
		$optionString = $option["chromeOptionCode"] . "::" . $option["selectionState"];
		if( $i > 0 && $i < count($options ) ) {
			$allOptions = $allOptions . ";;";
		}
		$allOptions = $allOptions . $optionString;
	}

	//get new pricing
	$baseInvoice = $newConfigStyle["style"]["baseInvoice"];
	$baseMsrp = $newConfigStyle["style"]["baseMsrp"];
	$destCharge = $newConfigStyle["style"]["destination"];

	$totalOptionInvoice = $newConfigStyle["configuredOptionsInvoice"];
	$totalOptionMsrp = $newConfigStyle["configuredOptionsMsrp"];

	$totalInvoice = $newConfigStyle["configuredTotalInvoice"];
	$totalMsrp = $newConfigStyle["configuredTotalMsrp"];

	//save style and return
	$_SESSION["configStyle"] = $newConfigStyle;
	print "noConflict" . "~~" . $allOptions . "~~" . $totalOptionInvoice . "~~" . $totalOptionMsrp . "~~" . $totalInvoice . "~~" . $totalMsrp;
}
else{
	echo "TOGGLE FAILED<br><br>"; var_dump($optionToggleResponse); echo "TOGGLE FAILED<br><br>";
}

?>