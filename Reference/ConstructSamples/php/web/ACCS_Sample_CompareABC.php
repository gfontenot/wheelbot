<?
require_once("ACCS_Sample_Compare_Data.php");

session_start( );

//get session variables
$accountInfo = $_SESSION["accountInfo"];

//get scratchlist ids
$primaryScratchListId = $_GET["primaryScratchListId"];
$scratchListIds = $_GET["scratchListIds"];

$advantageComparison = getAdvantageComparison( $accountInfo, $primaryScratchListId, $scratchListIds );
$pivotStyle = $advantageComparison["pivotConfiguration"]["style"];
$styleComparisons = $advantageComparison["comparisons"];
$styleComparisons = fixArray($styleComparisons);

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<title>Chrome Automotive Configuration/Comparison Service&trade;</title>
<style>
body {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	margin-top: 0px;
	margin-right: 5%;
	margin-bottom: 0px;
	margin-left: 5%;
}
.label {
	color: #326BAD;
}
</style>
<script type="text/javascript" src="js/compare.js"></script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center">
		<h1><img border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Comparison Service&trade;</h1>
	</td></tr>
	<tr><td align="center"><h1 class="label">Advantage Based Comparison</h1></td></tr>
</table>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<!-- show stock photos -->
	<tr><td>&nbsp;</td>
	<td align="center"><img alt="photo" height="75px" width="150px" src="<?=$pivotStyle["stockPhotoUrl"]?>"></td>
<?
	for ($j = 0; $j < count($styleComparisons); $j++) {
		$compareStyle = $styleComparisons[$j]["comparisonConfiguration"]["style"];
?>
			<td align="center"><img height="75px" width="150px" src="<?=$compareStyle["stockPhotoUrl"]?>"></td>
<?
		}
?>
	</tr>

	<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<?
    $primaryDescription = $pivotStyle["modelYear"] . " " . $pivotStyle["divisionName"] . " " . $pivotStyle["modelName"] . " " . $pivotStyle["styleName"];
?>
    <td align="center"><?=$primaryDescription?></td>
<?
	for ($j = 0; $j < count($styleComparisons); $j++) {
		$compareStyle = $styleComparisons[$j]["comparisonConfiguration"]["style"];
		$description = $compareStyle["modelYear"] . " " . $compareStyle["divisionName"] . " " . $compareStyle["modelName"] . " " . $compareStyle["styleName"];
?>
			<td align="center"><?=$description?></td>
<?
		}
?>
	</tr>
<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
    <td align="center"><?="$" . $pivotStyle["baseInvoice"] . " / " . "$" . $pivotStyle["baseMsrp"]?></td>
<?
	for ($j = 0; $j < count($styleComparisons); $j++) {
		$compareStyle = $styleComparisons[$j]["comparisonConfiguration"]["style"];
		$prices = "$" . $compareStyle["baseInvoice"] . " / " . "$" . $compareStyle["baseMsrp"];
?>
		<td align="center"><?=$prices?></td>
<?
	}
?>
	</tr>
<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
	<td align="center"><?="$" . $pivotStyle["destination"]?></td>
<?
	for ($j = 0; $j < count($styleComparisons); $j++) {
		$compareStyle = $styleComparisons[$j]["comparisonConfiguration"]["style"];
		$destinationCharge = "$" . $compareStyle["destination"];
?>
		<td align="center"><?=$destinationCharge?></td>
<?
	}
?>
	</tr>
	<tr>
		<td align="center"><b>Select Primary</b></td>
		<td align="center"><input type="radio" name="primaryButton" checked></td>
<?
	for ($j = 0; $j < count($styleComparisons); $j++) {
?>
		<td align="center"><input type="radio" name="primaryButton"></td>
<?
	}
?>
	</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr><td align="center"><input type="button" name="newABC_Compare" value="Compare" onClick='doNewABC_Compare("<?=$primaryScratchListId . "~~" . $scratchListIds?>")'></tr>
</table>
<div id="pleaseWaitMsgDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%" align="center">Retrieving Data...Please Wait</td></tr></table>
</div>
<br>
<!-- show advantages -->
<a name="advantages"/><h3 class="label">Advantages</h3>
<?
    for ($compareIndex = 0; $compareIndex < count($styleComparisons); $compareIndex++) {
        $styleComparison = $styleComparisons[$compareIndex];
        $style = $styleComparison["comparisonConfiguration"]["style"];
        $compareDescription = $style["modelYear"] . " " . $style["divisionName"] . " " . $style["modelName"] . " " . $style["styleName"];
?>
<b>The <?=$primaryDescription?> has the following advantages over the <?=$compareDescription?>:</b>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<?
        $advantageComparisonItems = $styleComparison["comparisonItems"];
        for ($j = 0; $j < count($advantageComparisonItems); $j++) {
            $resultType = $advantageComparisonItems[$j]["comparisonResultType"];
            if( $resultType == "Advantage" ) {
                $naturalLanguage = $advantageComparisonItems[$j]["naturalLanguageDescription"];
?>
		<tr><td align="left"><?=$naturalLanguage?></td></tr>
<?
    		}
	    }
?>
</table>
<br>
<?
    }
?>
<br>
<!-- show disadvantages -->
<a name="disadvantages"/><h3 class="label">Disadvantages</h3>
<?
    for ($compareIndex = 0; $compareIndex < count($styleComparisons); $compareIndex++) {
        $styleComparison = $styleComparisons[$compareIndex];
        $style = $styleComparison["comparisonConfiguration"]["style"];
        $compareDescription = $style["modelYear"] . " " . $style["divisionName"] . " " . $style["modelName"] . " " . $style["styleName"];
?>
<b>The <?=$primaryDescription?> has the following disadvantages as compared to the <?=$compareDescription?></b>:
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<!-- show disadvantages -->
<?
        $advantageComparisonItems = $styleComparison["comparisonItems"];
        for ($j = 0; $j < count($advantageComparisonItems); $j++) {
            $resultType = $advantageComparisonItems[$j]["comparisonResultType"];
            if( $resultType == "Disadvantage" ) {
                $naturalLanguage = $advantageComparisonItems[$j]["naturalLanguageDescription"];
?>
		<tr><td align="left"><?=$naturalLanguage?></td></tr>
<?
		    }
	    }
?>
</table>
<br>
<?
    }
?>
<br>
<a href="ACCS_Sample_Selector.php"><b>Return to Selector</b></a>
<br><br>
<br>
</body>
</html>