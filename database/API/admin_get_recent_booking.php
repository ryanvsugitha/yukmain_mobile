<?php
    include("./config.php");

    $username = $_POST['username'];
    
    $query_detail = "SELECT *, FORMAT(cs.price, 0, 'id_ID') AS formatted_price, DATE_FORMAT(b.booking_date, '%a, %d %b %Y') AS formatted_date
                    FROM booking b
                    JOIN court_schedule cs ON b.schedule_id = cs.schedule_id
                    JOIN court c ON b.court_id = c.court_id
                    JOIN venue v ON v.venue_id = c.court_id
                    WHERE venue_admin = '$username'
                    ORDER BY b.booking_created_date DESC
                    LIMIT 5";

    $result_detail = mysqli_query($connect, $query_detail);
    $final = array();
    while($row = mysqli_fetch_assoc($result_detail)){
        $final[] = $row;
    }
    
    echo json_encode($final);
    mysqli_close($connect);
?>