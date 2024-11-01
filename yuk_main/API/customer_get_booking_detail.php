<?php
    include("./config.php");

    $booking_id = $_POST['booking_id'];
    
    $query_detail = "SELECT *, FORMAT(cs.price, 0, 'id_ID') AS formatted_price, DATE_FORMAT(b.booking_date, '%a, %d %b %Y') AS formatted_date
                    FROM booking b
                    JOIN payment_type pt ON pt.payment_type_id = b.payment_type
                    JOIN court_schedule cs ON b.schedule_id = cs.schedule_id
                    JOIN court c ON b.court_id = c.court_id
                    JOIN venue v ON v.venue_id = c.venue_id
                    WHERE b.booking_id = '$booking_id'";
    $result_detail = mysqli_query($connect, $query_detail);
    $final = mysqli_fetch_assoc($result_detail);
    
    echo json_encode($final);
    mysqli_close($connect);
?>