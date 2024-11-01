<?php
    include("./config.php");

    $schedule_id = $_POST['schedule_id'];
    
    $query = "SELECT *, FORMAT(cs.price, 0, 'id_ID') AS formatted_price
            FROM court_schedule cs
            JOIN court c ON cs.court_id = c.court_id
            JOIN venue v ON v.venue_id = c.venue_id
            WHERE cs.schedule_id = '$schedule_id'";
    $result = mysqli_query($connect, $query);
    $final = mysqli_fetch_assoc($result);
    
    echo json_encode($final);
    mysqli_close($connect);
?>