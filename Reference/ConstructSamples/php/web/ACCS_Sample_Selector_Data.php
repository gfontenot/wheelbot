<?
require_once("ACCS_Sample_Util.php");
session_start( );

$configService = getConfigCompareService();
$proxy = $configService->getProxy();

//============================================get new locale
if ($_GET["data"] == "locale") {

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
}

//============================================get new orderAvailability
if ($_GET["data"] == "orderAvailability") {
	$orderAvailability = $_GET["orderAvailability"];
	$_SESSION["orderAvailability"] = $orderAvailability;
}

//============================================getModelYears
if ($_GET["data"] == "years") {

	$accountInfo = $_SESSION["accountInfo"];
	$orderAvailability = $_SESSION["orderAvailability"];

	//get model years
	$modelYearsRequest = array(
		"accountInfo" => $accountInfo,
		"filterRules" => getFilterRules( $orderAvailability )
	);

	$modelYears = $proxy->getModelYears($modelYearsRequest);
	$modelYears = $modelYears["i"];

	for ($i = 0; $i < count($modelYears); $i++ ) {
		$year = $modelYears[$i];
		if ($i > 0) {
			print ";;";
		}
		print $year . "~~" . $year;
	}
	return;
}

//============================================getDivisions
else if ($_GET["data"] == "divisions") {
	$accountInfo = $_SESSION["accountInfo"];
	$orderAvailability = $_SESSION["orderAvailability"];

	$year = $_GET["modelYear"];

	$divisionsRequest = array(
		"accountInfo" => $accountInfo,
		"filterRules" => getFilterRules( $orderAvailability ),
		"modelYear" => $year
	);

	$divisions = $proxy->getDivisions($divisionsRequest);
	$divisions = fixArray($divisions["division"]);

	for ($i = 0; $i < count($divisions); $i++ ) {
		$division = $divisions[$i];
		if ($i > 0) {
			print ";;";
		}
		print $division["divisionId"] . "~~" . $division["divisionName"];
	}
	return;
}

//============================================getModels
else if ($_GET["data"] == "models") {
	$accountInfo = $_SESSION["accountInfo"];
	$orderAvailability = $_SESSION["orderAvailability"];

	$year = $_GET["modelYear"];
	$divisionId = $_GET["divisionId"];

	$modelsRequest = array(
		"accountInfo" => $accountInfo,
		"modelYear" => $year,
		"divisionId" => $divisionId,
		"filterRules" => getFilterRules( $orderAvailability )
	);

	$models = $proxy->getModelsByDivision($modelsRequest);
	$models = fixArray($models["model"]);

	for ($i = 0; $i < count($models); $i++ ) {
		$model = $models[$i];
		if ($i > 0) {
			print ";;";
		}
		print $model["modelName"] . "~~" . $model["modelId"];
	}
	return;
}

//============================================getStyles
else if ($_GET["data"] == "styles") {
	$accountInfo = $_SESSION["accountInfo"];
	$orderAvailability = $_SESSION["orderAvailability"];

	$year = $_GET["modelYear"];
	$divisionName = $_GET["divisionName"];
	$modelId = $_GET["modelId"];
	$modelName = $_GET["modelName"];

	$stylesRequest = array(
		"accountInfo" => $accountInfo,
		"modelId" => $modelId,
		"filterRules" => getFilterRules( $orderAvailability )
	);

	$styles = $proxy->getStyles($stylesRequest);
	$styles = fixArray($styles["style"]);

	for ($i = 0; $i < count($styles); $i++ ) {
		$style = $styles[$i];
		$invoice = "";
		$msrp = "";
		$invoice = "$" . $style["baseInvoice"];
		$msrp = "$" . $style["baseMsrp"];
		if ($i > 0) {
			print ";;";
		}
		print $year . "~~" . $divisionName . "~~" . $modelName . "~~" . $style["styleName"] . "~~" . $invoice . "~~". $msrp . "~~" . $style["styleId"];
	}
}
?>