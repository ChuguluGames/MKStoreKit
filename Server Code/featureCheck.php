<?php
	$dbname = "mugunth1_udid";
	$user = "mugunth1_udid";
	$password = "wrong password";
	
	header('Content-Type: application/json'); 
	$product_id	= $_POST['productID'];
	$unique_id	= $_POST['uniqueID'];
	
    // Connect to database server
    $hd = mysql_connect("localhost", $user, $password)
          or die ("Unable to connect");

    // Select database

    mysql_select_db ($dbname, $hd)
          or die ("Unable to select database");

    // Execute sample query (insert it into mksync all data in customer table)

    $res = mysql_query("SELECT * FROM `mugunth1_udid`.`requests` WHERE `unique_id`='".mysql_real_escape_string($unique_id, $hd)."' AND `product_id`='".mysql_real_escape_string($product_id, $hd)."' AND `status` = 1", $hd) or die ("Unable to fetch :-(");

	
	$num = mysql_num_rows($res);
	if($num == 0)
		$returnString = "epic fail";
	else
		$returnString = '{"product_id":"'.$product_id.'"}';
 	mysql_close($hd);

	echo $returnString;
?>
