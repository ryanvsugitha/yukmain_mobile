<?php
    include("./config.php");

    $venue_id = $_POST['venue_id'];
    $venue_name = $_POST['venue_name'];
    
    $query = "UPDATE venue SET venue_name = '$venue_name' WHERE venue_id = '$venue_id'";

    if(mysqli_query($connect, $query)){
        echo json_encode(["status"=>"1", "message"=>"Successfully Update Venue Name!"]);
    } else {
        echo json_encode(["status"=>"0", "message"=>"Failed to Update Venue Name!"]);
    }

    mysqli_close($connect);
?>