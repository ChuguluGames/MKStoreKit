	
<?php

	$user = "mugunth1_udid";
	$password = "wrong password";
	$dbname = "mugunth1_udid";
	
	$product_id = $_POST['product_id'];
	$unique_id	= $_POST['unique_id'];
	$email		= $_POST['email'];
	$message	= $_POST['message'];
    // Connect to database server

    $hd = mysql_connect("localhost", $user, $password)
          or die ("Unable to connect");

    // Select database

    mysql_select_db ($dbname, $hd)
          or die ("Unable to select database");

    // Execute sample query (insert it into mksync all data in customer table)

    $res = mysql_query("INSERT INTO `mugunth1_udid`.`requests`(`unique_id`, `productid`, `email`, `message`) VALUES ('".mysql_real_escape_string($unique_id, $hd)."', '".mysql_real_escape_string($product_id, $hd)."', '".mysql_real_escape_string($email, $hd)."', '".mysql_real_escape_string($message, $hd)."')",$hd)
          or die ("Unable to insert :-(");
	
 	mysql_close($hd);
 	
 	echo "Done!";
?>
