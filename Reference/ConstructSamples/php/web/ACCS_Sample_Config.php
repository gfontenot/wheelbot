<?
session_start();

require_once("ACCS_Sample_Config_NewStyle.php");

$scratchListId = $_GET["scratchListId"];
$filePathAndName = $_GET["filePathAndName"];

if( $scratchListId == "" )
	$configStyle = loadSavedStyle( $filePathAndName );
else
	$configStyle = getConfigStyle( $scratchListId );

//save config style
$_SESSION["configStyle"] = $configStyle;

?>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<title>Chrome Automative Configuration Service&trade;</title>
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
<script type="text/javascript" src="js/request.js"></script>
<script type="text/javascript" src="js/configure.js"></script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td align="center">
		<h1><img border="0" src="http://login.carbook.com/ChromeCentral/common/images/chrome-logo.gif">Automotive Configuration Service&trade;</h1>
	</td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<!-- show description -->
<?
	$photoUrl = $configStyle["style"]["stockPhotoUrl"];
	$description = $configStyle["style"]["modelYear"] . " " . $configStyle["style"]["divisionName"] . " " . $configStyle["style"]["modelName"] . " " . $configStyle["style"]["styleName"];
	$description2 = addslashes( $description );
?>
	<tr><td align="center"><img src="<?=$photoUrl?>"></td></tr>
	<tr><td align="center"><h1 class="label"><?=$description?></h1></td></tr>
</table>
	<!-- links -->
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr><td><a href="#generalInfoHref" id="General Info" onClick='showOrHideGroup(this.id)'><b>Show General Info</b></a></td></tr>
	<tr><td><a href="#techSpecHref" id="Technical Specifications" onClick='showOrHideGroup(this.id)'><b>Show Technical_Specifications</b></a></td></tr>
	<tr><td><a href="#standardsHref" id="Standards" onClick='showOrHideGroup(this.id)'><b>Show Standards</b></a></td></tr>
	<tr><td><a href="#optionsHref" id="Options" onClick='showOrHideGroup(this.id)'><b>Show Options</b></a></td></tr>
	<tr><td><a href="#checklistHref" id="Configuration Checklist" onClick='showOrHideGroup(this.id)'><b>Show Configuration Checklist</b></a></td></tr>
	<tr><td><a href="#" id="Colors" onclick="showColorWindow()"><b>Show Colors</b></a></td></tr>
</table>

<div id="General Info Div" style="display:none;visibility:hidden">
<!-- show General Info -->
<a name="generalInfoHref"/><h3 class="label">GENERAL INFORMATION</h3>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<?
	$consumerInformation = $configStyle["consumerInformation"];
	$crashTestRating = $consumerInformation["crashTestRating"];
	if( $crashTestRating != null ) {
?>
		<tr><td valign="top" align="center" width="40%"  ><b>Crash Test Rating</b></td><td><?=$crashTestRating?></td></tr>
<?
	}
	$rebate = $consumerInformation["rebate"];
	if( $rebate != null ) {
?>
		<tr><td valign="top" align="center" width="40%"  ><b>Rebate</b></td><td><?=$rebate?></td></tr>
<?
	}
	$recall = $consumerInformation["recall"];
	if( $recall != null ) {
?>
		<tr><td valign="top" align="center" width="40%"  ><b>Recall</b></td><td><?=$recall?></td></tr>
<?
	}
	$warranty = $consumerInformation["warranty"];
	if( $warranty != null ) {
?>
		<tr><td valign="top" align="center" width="40%"  ><b>Warranty</b></td><td><?=$warranty?></td></tr>
<?
	}
?>
</table>
</div>
<div id="Technical Specifications Div" style="display:none;visibility:hidden">
<a name="techSpecHref"/><h3 class="label">TECHNICAL SPECIFICATIONS</h3>
<?
	//store tech specs
	$arrayTS = array();
	for( $i = 0; $i < count($configStyle["technicalSpecifications"]); $i++ ) {
		$techSpec =  $configStyle["technicalSpecifications"][$i];
		$headerName = $techSpec["headerName"];
		if (  !array_key_exists ( $headerName, $arrayTS ) ) {
			$arrayTS[$headerName] = array();
		}
		array_push( $arrayTS[$headerName], $techSpec );
	}

	//show tech specs
	foreach( $arrayTS as $techSpecHeader => $techSpecs ) {
?>
<a name="<?=$techSpecHeader?>"/><h4 class="label"><?=strtoupper($techSpecHeader)?></h4>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<?
		for( $j = 0; $j < count($techSpecs); $j++ ) {
			$techSpec = $techSpecs[$j];
			$title = $techSpec["titleName"];
			$value = $techSpec["value"];
			if ( $value == "" )
				$value = "&nbsp;";
			$unit  = $techSpec["measurementUnit"];
			if ($unit != null)
				$unit = " (" . $unit . ")";
?>
			<tr><td width="40%"  align="center"><b><?=$title?><?=$unit?></b></td><td align="center"><?=$value?></td></tr>
<?
		}
?>
</table>
<?
	}
?>
</div>
<div id="Standards Div" style="display:none;visibility:hidden">
<a name="standardsHref"/><h3 class="label">STANDARDS</h3>
<?
	//store standards
	$arrayStandards = array();
	for( $i = 0; $i < count($configStyle["standardEquipment"]); $i++ ) {
		$standard =  $configStyle["standardEquipment"][$i];
		$headerName = $standard["headerName"];
		if (  !array_key_exists ( $headerName, $arrayStandards ) ) {
			$arrayStandards[$headerName] = array();
		}
		array_push( $arrayStandards[$headerName], $standard );
	}

	//show standards
	foreach( $arrayStandards as $header => $standards ) {
?>
<a name="<?=header?>"/><h4 class="label"><?=$header?></h4>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
<?
		for( $j = 0; $j < count($standards); $j++ ) {
			$standardDesc =  $standards[$j]["description"];
?>
			<tr><td align="left"><?=$standardDesc?></td></tr>
<?
		}
?>
</table>
<?
	}
?>
</div>
<div id="Options Div" style="display:none;visibility:hidden">
<a name="optionsHref"/><h3 class="label">OPTIONS</h3>
<?
	//store options
	$arrayOptions = array();
	//if no options array.  i.e. honda vehicles
	if ( !is_array( $configStyle["options"] ) ) {
		$option =  $configStyle["options"];
		$optionHeader = $option["headerName"];
		$arrayOptions[$optionHeader] = array();
		array_push( $arrayOptions[$optionHeader], $option );
	} else {
		for( $i = 0; $i < count($configStyle["options"]); $i++ ) {
			$option =  $configStyle["options"][$i];
			$optionHeader = $option["headerName"];
			if (  !array_key_exists ( $optionHeader, $arrayOptions ) ) {
				$arrayOptions[$optionHeader] = array();
			}
			array_push( $arrayOptions[$optionHeader], $option );
		}
	}

	//show options
	foreach( $arrayOptions as $header => $options ) {
?>
<a name="<?=$header?>"/><h4 class="label"><?=$header?></h4>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
	<tr>
		<td width="5%"  align="center"><b>State</b></>
		<td width="45%" align="center"><b>Description</b></td>
		<td width="10%" align="center"><b>Code</b></td>
		<td width="20%" align="center"><b>Invoice</b></td>
		<td width="20%" align="center"><b>MSRP</b></td>
	</tr>
<?
		for( $j = 0; $j < count($options); $j++ ) {
			$option = $options[$j];
			$oemOptionCode = $option["oemOptionCode"];
			$chromeOptionCode = $option["chromeOptionCode"];
            $optionDesc = getFullOptionDescription( $option );
			$optionInvc = $option["invoice"];
			$optionMsrp = $option["msrp"];
?>
	<tr>
<?
			if ( $option["selectionState"] == "Excluded" ) {
?>
				<td width="5%" align="center"><img id="img<?=$chromeOptionCode?>" src="images/excluded.gif" title="Excluded" onClick='toggleOption("<?=$chromeOptionCode?>")'></td>
<?
			} else if ( $option["selectionState"] == "Included" ) {
?>				<td width="5%" align="center"><img id="img<?=$chromeOptionCode?>" src="images/included.gif" title="Included" onClick='toggleOption("<?=$chromeOptionCode?>")'></td>
<?
			} else if ( $option["selectionState"] == "Required" ) {
?>				<td width="5%" align="center"><img id="img<?=$chromeOptionCode?>" src="images/required.gif" title="Required" onClick='toggleOption("<?=$chromeOptionCode?>")'></td>
<?
			} else if ( $option["selectionState"] == "Selected" ) {
?>				<td width="5%" align="center"><img id="img<?=$chromeOptionCode?>" src="images/selected.gif" title="Selected" onClick='toggleOption("<?=$chromeOptionCode?>")'></td>
<?
			} else if ( $option["selectionState"] == "Unselected" ) {
?>				<td width="5%" align="center"><img id="img<?=$chromeOptionCode?>" src="images/unselected.gif" title="Unselected" onClick='toggleOption("<?=$chromeOptionCode?>")'></td>
<?
			} else if ( $option["selectionState"] == "Upgraded" ) {
?>				<td width="5%" align="center"><img id="img<?=$chromeOptionCode?>" src="images/upgraded.gif" title="Upgraded" onClick='toggleOption("<?=$chromeOptionCode?>")'></td>
<?
			}
?>
			<td width="40%" align="left"><?=$optionDesc?></td>
			<td width="10%" align="center"><?=$oemOptionCode?></td>
			<td width="20%" align="center">$<?=$optionInvc?></td>
			<td width="20%" align="center">$<?=$optionMsrp?></td>
	</tr>
<?
		}
?>
</table>
<?
	}
?>
</div>
<a name="pricing"/><h3 class="label">PRICING SUMMARY</h3>
<?
	$baseInvoice = $configStyle["style"]["baseInvoice"];
	$baseMsrp = $configStyle["style"]["baseMsrp"];
	$destCharge = $configStyle["style"]["destination"];

	$totalOptionInvoice = $configStyle["configuredOptionsInvoice"];
	$totalOptionMsrp = $configStyle["configuredOptionsMsrp"];

	$totalInvoice = $configStyle["configuredTotalInvoice"];
	$totalMsrp = $configStyle["configuredTotalMsrp"];

?>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
	<tr>
		<td align="center" width="70%">&nbsp;</td>
		<td align="center" width="15%"><b>Invoice</b></td>
		<td align="center" width="15%"><b>MSRP</b></td>
	</tr>
</table>
<table width="100%" border="1" cellspacing="0" cellpadding="2">
	<tr>
		<td align="center" width="70%"><b>Base Price</b></td>
		<td align="center" width="15%"><span id="baseInvoice">$<?=$baseInvoice?></span></td>
		<td align="center" width="15%"><span id="baseMsrp">$<?=$baseMsrp?></span></td>
	</tr>
	<tr>
		<td align="center" width="70%"><b>Destination Charge</b></td>
		<td align="center" width="15%"><span id="destChargeInvoice">$<?=$destCharge?></span></td>
		<td align="center" width="15%"><span id="destChargeMsrp">$<?=$destCharge?></span></td>
	</tr>
	<tr>
		<td align="center" width="70%"><b>Total Options Price</b></td>
		<td align="center" width="15%"><span id="totalOptionInvoice">$<?=$totalOptionInvoice?></span></td>
		<td align="center" width="15%"><span id="totalOptionMsrp">$<?=$totalOptionMsrp?></span></td>
	</tr>
	<tr>
		<td align="center" width="70%"><b>Total Price</b></td>
		<td align="center" width="15%"><span id="totalInvoice"><b>$<?=$totalInvoice?></b></span></td>
		<td align="center" width="15%"><span id="totalMsrp"><b>$<?=$totalMsrp?></b></span></td>
	</tr>
</table>
<div id="Configuration Checklist Div" style="display:none;visibility:hidden">
<a name="checklistHref"/><h3 class="label">CONFIGURATION CHECKLIST</h3>
<?
    $items = $configStyle["configurationCheckListItems"];
    for( $i = 0; $i < count($items); $i++ ){
        $item = $items[$i];
        $satisfiedStateColor = $item["satisfied"] ? "White" : "Red";
?>
<table name="checklistTable" style="background-color: <?=$satisfiedStateColor?>;" width="100%" border="1" cellspacing="0" cellpadding="2">
    <tr>
		<td colspan="100%" align="left" width="15%" style="background-color: Lime;"><b><?=$item["itemName"]?></b></td>
    </tr>
<?
		$chromeOptionCodes = $item["chromeOptionCodes"];
		if( count($item["chromeOptionCodes"]) == 1 ){
			$chromeOptionCodes = fixArray( $chromeOptionCodes );
		}
        for( $j=0; $j < count($chromeOptionCodes); $j++ ){
            $chromeOptionCode = $chromeOptionCodes[$j];
            for( $k=0; $k < count($configStyle["options"]); $k++ ){
                $option = $configStyle["options"][$k];
                if( $chromeOptionCode == $option["chromeOptionCode"] ){
	                $statusDescription = "&nbsp;";
                    if( $option["selectionState"] == "Selected" || $option["selectionState"] == "Included" || $option["selectionState"] == "Required" ){
                          $statusDescription = "-->";
                    }
                    $checklistOptionDescription = getPrimaryOptionDescription($option);
?>
    <tr style="background-color: <?=$satisfiedStateColor?>;">
    	<td align="right" width="10%" style="border-right: 1px solid black;"><b><span id="checklistStatus<?=$option["chromeOptionCode"]?>"><?=$statusDescription?></span></b></td>
		<td align="center" width="10%" style="border-right: 1px solid black;"><b><?=$option["oemOptionCode"]?></b></td>
		<td align="left" width="80%"><b><?=$checklistOptionDescription?></b></td>
    </tr>
<?
                    break;
                }
            }
        }
?>
</table><br>
<?
    }
?>
</div>
<div id="modalWinMask" style="position:absolute; width:100%; height:100%; top:0; left:0; padding:0; margin:0;background:black; Filter:Alpha(opacity=25); -moz-opacity:.25; opacity:.25; visibility:hidden; display:none; z-index:1;">&nbsp;</div>
<div align="center" id="conflictDialog" style="border-width:thin; border-top:1px solid; border-left:1px solid; border-right:1px solid; border-bottom:1px solid; position:absolute; width:600px; background:#FFFFFF; visibility:hidden; display:none; z-index:2;">
	<form name="conflictForm">
        <div id="conflictContent">
        </div>
    </form>
</div>
<br>
<input type="button" name="Save Style" value="Save Style" onClick='saveStyle("<?=$description2?>")'><span style="font-size:10px">&nbsp;( Saved Styles will appear in the Selector page )</span>
<div id="styleSaveDiv" style="visibility:hidden">
	<table width="100%"><tr><td width="100%">Style Saved</td></tr></table>
</div>
<br><br>
<a href="ACCS_Sample_Selector.php"><b>Return to Selector</b></a>
<br>
<a href="ACCS_Sample_Search.php"><b>Return to Search</b></a>
</body>
</html>