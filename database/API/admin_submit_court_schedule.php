<?php
    include("./config.php");

    $court_id = $_POST['court_id'];
    $price = $_POST['price'];
    $start = $_POST['start'];
    $end = $_POST['end'];
    
    $query = "INSERT INTO court_schedule VALUES (NULL, '$court_id', '$start', '$end', '$price')";
    if(mysqli_query($connect, $query)){
        echo json_encode(["status" => "1", "message" => "Schedule Submitted!"]);
    } else {
        echo json_encode(["status" => "0", "message" => "Failed to Submit Schedule!"]);
    }

    mysqli_close($connect);
?>