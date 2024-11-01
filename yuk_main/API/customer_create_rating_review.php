<?php
    include("./config.php");

    $booking_id = $_POST['booking_id'];
    $rating = $_POST['rating'];
    $review = $_POST['review'];

    $curr_date = date('Y-m-d H:i:s');
    
    $query = "UPDATE booking 
            SET rating = '$rating', review = '$review', rating_submit_date = '$curr_date'
            WHERE booking_id = '$booking_id'";

    if(mysqli_query($connect, $query)){
        echo json_encode(["status"=>"1", "message"=>"Successfully Submit Rate and Review!"]);
    } else {
        echo json_encode(["status"=>"0", "message"=>"Failed to Submit Rate and Review!"]);
    }

    mysqli_close($connect);
?>