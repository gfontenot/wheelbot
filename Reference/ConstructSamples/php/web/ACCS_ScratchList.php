<?
session_start( );
require_once("ACCS_Sample_Util.php");

//============================================ init scratchlist
if( ! isset($_SESSION["scratchlist"]) ){
    $_SESSION["scratchlist"] = array();
}

//============================================ add to scratchlist
if ($_GET["cmd"] == "add") {

    $accountInfo = $_SESSION["accountInfo"];
    $orderAvailability = $_SESSION["orderAvailability"];
    $styleId = $_GET["styleId"];

    $styleRequest = array(
        "accountInfo" => $accountInfo,
        "orderAvailability" => $orderAvailability,
        "styleId" => $styleId,
        "returnParameters" => getStyleReturnParametersNone()
    );
    $configService = getConfigCompareService();
    $proxy = $configService->getProxy();

    $response = $proxy->getConfigurationByStyleId($styleRequest);

    if( is_null($response["faultstring"]) ){
        $dotspace = array("."," ");
        $scratchListId = $styleId . "-" . str_replace($dotspace,"",microtime());
        $_SESSION["scratchlist"][$scratchListId] = $response["configuration"]["style"]["configurationState"];
        $result = "success" . "~~" . $scratchListId;
    } else {
		$result = "fail" . "~~" . $response["faultstring"];
	}

	print $result;

}

//============================================ remove from scratchlist
if ($_GET["cmd"] == "remove") {

    $result = "fail";
    $scratchListId = $_GET["scratchListId"];
    unset($_SESSION["scratchlist"][$scratchListId]);
    $result = "success";

    print $result;
}

//============================================ clear scratchlist
if ($_GET["cmd"] == "clear") {

    $result = "fail";
    unset($_SESSION["scratchlist"]);
    $result = "success";

    print $result;
}

?>