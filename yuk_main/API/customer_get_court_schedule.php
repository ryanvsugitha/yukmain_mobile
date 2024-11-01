<?php
    include("./config.php");

    $date = $_POST['date'];
    $court_id = $_POST['court_id'];
    
    $query = "SELECT *, 
                    cs.schedule_id, 
                    cs.court_id, 
                    FORMAT(cs.price, 0, 'id_ID') as formatted_price,
                    CASE
                        WHEN CONCAT('$date ', TIME(REPLACE(start_time, '.', ':'))) < NOW() THEN 0
                        WHEN b.booking_id IS NOT NULL THEN 0
                        ELSE 1
                    END AS 'status'
                FROM court_schedule cs
                LEFT JOIN booking b ON cs.schedule_id = b.schedule_id AND b.booking_date = '$date'
                WHERE cs.court_id = '$court_id'
                ORDER BY cs.schedule_id ASC";
    $result = mysqli_query($connect, $query);
    $final = array();
    while($row = mysqli_fetch_assoc($result)){
        $final[] = $row;
    }
    
    echo json_encode($final);
    mysqli_close($connect);
?>