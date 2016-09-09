<?php
ini_set('error_reporting', E_ALL|E_STRICT);
ini_set('display_errors', 1);


function GET($key) {
    return isset($_GET[$key]) ? $_GET[$key] : null;
}

$servername = "localhost";
$username = "hack";
$password = "HackCVR16";
$dbname = "Hack";

$idTrimmed=trim($_GET['id']);
//echo "contigID :" . $idTrimmed . "<br/>";

//$id ="midge1-0167e2:idba.genome1_contig-121_1027";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
//echo "Connected successfully <br> ";


//query database 
$query = "SELECT ContigID, Seq
          FROM MergeTable
          WHERE ContigID = '".$idTrimmed."'";          

$result = mysqli_query($conn, $query);

if(! $result )
{
  die('Could not get data: ' . mysql_error());
}

if (mysqli_num_rows($result) > 0) {
    // output data of each row
    while($row = mysqli_fetch_assoc($result)) {
        // format result as fasta format
        echo ">{$row['ContigID']}  <br> ".
         "{$row['Seq']} <br> ";
    }
} else {
    echo "0 results <br>";
}

mysqli_close($conn);

?>
