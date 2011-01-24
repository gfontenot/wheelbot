<?
session_start();
$configStyle = $_SESSION["configStyle"];
$serializedValue = $configStyle["style"]["configurationState"]["serializedValue"];

$dir = ".\\savedStyles\\";
if( !is_dir( $dir ) )
	mkdir( $dir );

$fileName = $dir . $_GET["fileName"] . ".xml";

//delete old file
if( file_exists( $fileName ) ) {
	unlink( $fileName );
}

//save style in new file
$handle = fopen( $fileName, 'w' );
fwrite( $handle, $serializedValue );
fclose($handle);

print "Success";
?>