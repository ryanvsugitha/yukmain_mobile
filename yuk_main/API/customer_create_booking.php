<?php
    include("./config.php");

    $schedule_id = $_POST['schedule_id'];
    $date = $_POST['date'];
    $payment_type_id = $_POST['payment_type_id'];
    $booker_id = $_POST['booker_id'];
    $court_id = $_POST['court_id'];

    $curr_date = date('Y-m-d H:i:s');
    
    $query = "INSERT INTO booking 
            VALUES (NULL, '$schedule_id', '$payment_type_id', '$court_id', '$booker_id', '$date', '$curr_date', '0', NULL, NULL, NULL)";

    if(mysqli_query($connect, $query)){
        echo json_encode(["status"=>"1", "message"=>"Successfully created booking! Go to detail page!"]);
    } else {
        echo json_encode(["status"=>"0", "message"=>"Failed to create booking!"]);
    }

    mysqli_close($connect);
?>