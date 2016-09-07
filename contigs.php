<?php
$servername = "localhost";
$username = "hack";
$password = "HackCVR16";
$dbname = "Hack";

$id=$argv[1];

// Create connection
$conn = mysqli_connect($servername, $username, $password, $dbname);
// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$sql = "SELECT ContigID , Seq  FROM MergeTable WHERE ContigID = '$id'";
$result = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) > 0) {
    // output data of each row
    while($row = mysqli_fetch_assoc($result)) {
        echo ">" . $row["ContigID"]. "\n" . $row["Seq"].  "\n";
    }
} else {
    echo "0 results\n";
}

mysqli_close($conn);

?>
