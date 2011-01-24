<?
require_once("ACCS_Sample_Compare_Data.php");

session_start( );

//get session variables
$accountInfo = $_SESSION["accountInfo"];

//get $scratchListIds
$scratchListIds = $_GET["scratchListIds"];

$sideBySideComparisonResult = getSideBySideComparisonResult( $accountInfo, $scratchListIds );
$sideBySideComparisonConfigurations = $sideBySideComparisonResult["comparisonConfigurations"];
$sideBySideComparisonGroups = $sideBySideComparisonResult["comparisonGroups"];
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
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td align="center">
		<h1><img border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Comparison Service&trade;</h1>
	</td></tr>
	<tr><td align="center"><h1 class="label">Side By Side Comparison</h1></td></tr>
</table>
<!-- show links -->
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<?
	for( $i = 0; $i < count($sideBySideComparisonGroups); $i++ ) {
		$groupName = $sideBySideComparisonGroups[$i]["groupName"];
		$href = "#" . $groupName . "Href";
?>
	<tr><td><a href="<?=$href?>" id="<?=$groupName?>" onClick="showOrHideGroup(this.id)"><b>Show <?=$groupName?></b></a></td></tr>
<?
	}
?>
</table>
<br>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
<!-- show stock photos -->
	<tr><td width="250px">&nbsp;</td>
<?
	for( $i = 0; $i < count($sideBySideComparisonConfigurations); $i++ ) {
		$compareStyle = $sideBySideComparisonConfigurations[$i]["style"];
		$photoUrl = $compareStyle["stockPhotoUrl"];
?>
		<td align="center" width="350px"><img height="75px" width="150px" src="<?=$photoUrl?>"></td>
<?
	}
?>
	</tr>

<!-- show style descriptions -->
	<tr><td align="center"><b>Description</b></td>
<?
	for( $i = 0; $i < count($sideBySideComparisonConfigurations); $i++ ) {
		$compareStyle = $sideBySideComparisonConfigurations[$i]["style"];
		$description = $compareStyle["modelYear"] . " " . $compareStyle["divisionName"] . " " . $compareStyle["modelName"] . " " . $compareStyle["styleName"];
?>
		<td align="center"><?=$description?></td>
<?
	}
?>
	</tr>

<!-- show invoice/msrp -->
	<tr><td align="center"><b>Invoice/MSRP</b></td>
<?
	for( $i = 0; $i < count($sideBySideComparisonConfigurations); $i++ ) {
		$compareStyle = $sideBySideComparisonConfigurations[$i]["style"];
		$prices = "$" . $compareStyle["baseInvoice"] . " / " . "$" . $compareStyle["baseMsrp"] ;
?>
		<td align="center"><?=$prices?></td>
<?
	}
?>
	</tr>

<!-- show destination -->
	<tr><td align="center"><b>Destination Charge</b></td>
<?
	for( $i = 0; $i < count($sideBySideComparisonConfigurations); $i++ ) {
		$compareStyle = $sideBySideComparisonConfigurations[$i]["style"];
		$destinationCharge = "$" . $compareStyle["destination"];
?>
		<td align="center"><?=$destinationCharge?></td>
<?
	}
?>
	</tr>
</table>
<br>
<!-- show Categories  -->
<?
	for( $i = 0; $i < count($sideBySideComparisonGroups); $i++ ) {
		$groupName = $sideBySideComparisonGroups[$i]["groupName"];
		$divName = $groupName . "Div";
		$href = $groupName . "Href";
?>
<div id="<?=$divName?>" style="display:none;visibility:hidden">
<a name="<?=$href?>"/>
<h3 class="label"><?=strtoupper($groupName)?></h3>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<?
		$comparisonItems = $sideBySideComparisonGroups[$i]["comparisonItems"];
		for( $j = 0; $j< count($comparisonItems); $j++ ) {
			$featureDescription = $comparisonItems[$j]["featureDescription"];
			$comparisonValues = $comparisonItems[$j]["comparisonValues"];
?>
	<tr>
		<td align="center" width="250px"><b><?=$featureDescription?></b></td>
<?
			for( $k = 0; $k < count($comparisonValues); $k++ ) {
				if ( $comparisonValues[$k] == "" )
					$comparisonValues[$k] = "&nbsp;";
?>
				<td align="center" width="350px"><?=$comparisonValues[$k]?></td>
<?
			}
?>
	</tr>
<?
		}
?>
</table>
</div>
<?
	}
?>
<!-- warranty -->
<h3 class="label">WARRANTY</h3>
<table width="100%" border="1" cellspacing="0" cellpadding="5">
	<tr>
		<td align="center" width="250px"><b>Warranty</b></td>
<?
	$ids = split( "~~", $scratchListIds );
	for( $i = 0; $i < count( $sideBySideComparisonConfigurations ); $i++ ) {
	    $warranty = $sideBySideComparisonConfigurations[$i]["consumerInformation"]["warranty"];
?>
		<td align="center" width="350px"><?=$warranty?></td>
<?
	}
?>
	</tr>
</table>
<br>
<a href="ACCS_Sample_Selector.php"><b>Return to Selector</b></a>
<br>
</body>
</html>