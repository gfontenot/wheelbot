<?
session_start();
$configStyle = $_SESSION["configStyle"];

?>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
<title>Available Colors</title>
</head>
<body>
<label style="color:#326BAD; font-size:large">Available Color Combinations</label><br/><br/>
<?
	//for each color combination, get same exterior color combo and store in hash
	$colorCombinations = array();
	for( $i = 0; $i < count($configStyle["colorCombinations"]); $i++ ) {
		$colorCombination = $configStyle["colorCombinations"][$i];
		$exteriorColorKey = $colorCombination["primaryExteriorColor"]["name"] . " (" . $colorCombination["primaryExteriorColor"]["manufacturersCode"] . ")~" . $colorCombination["primaryExteriorColor"]["swatchUrl"];
		$exteriorColorKey = $exteriorColorKey . "~" . $colorCombination["primaryExteriorColor"]["rgbHexCode"];
		$interiorColorName = $colorCombination["interiorColor"]["name"];
		if (  !array_key_exists ( $exteriorColorKey, $colorCombinations ) ) {
			$colorCombinations[$exteriorColorKey] = array();
		}
		array_push( $colorCombinations[$exteriorColorKey], $interiorColorName );
	}

	//now show colors
	if( count($colorCombinations) > 0 ) {
		foreach( $colorCombinations as $exteriorColor => $interiorColors ) {
			$exteriorColorString = split( "~", $exteriorColor );
			$exteriorColorName = $exteriorColorString[0];
			$exteriorColorMedia = $exteriorColorString[1];
			$exteriorColorRgb = $exteriorColorString[2];

?>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
    <tr><td align="center" style="width:30%"><b>Exterior Color</b></td><td align="center"><b>Interior Colors</b></td></tr>
    <tr>

        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="2">
                <tr><td align="center"><?=$exteriorColorName?> <img alt="<?=$exteriorColorName?>" width="10px" height="10px" src="<?=$exteriorColorMedia?>"/></td></tr>
                <tr><td align="center" style="border: 1px solid black; background-color: #<?=$exteriorColorRgb?>;">&nbsp;</td></tr>
            </table>
        </td>
        <td>
            <table width="100%" border="1" cellspacing="0" cellpadding="2">
                <tr>
<?
                for( $i = 0; $i < count($interiorColors); $i++ ) {
?>
                    <td align="center"><?=$interiorColors[$i]?></td>
<?
                }
?>
                </tr>
            </table>
        </td>
    </tr>
</table>
<br />
<?
		}
    }
?>
<input type="button" value="Close Window" onclick="window.close()">
</body>
</html>