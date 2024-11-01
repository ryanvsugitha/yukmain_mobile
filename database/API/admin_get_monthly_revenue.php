<?php
    include("./config.php");

    $username = $_POST['username'];
    
    $query = "SELECT *, FORMAT(SUM(cs.price), 0, 'id_ID') AS formatted_revenue
            FROM booking b
            JOIN court_schedule cs ON b.schedule_id = cs.schedule_id
            JOIN court c ON b.court_id = c.court_id
            JOIN venue v ON c.venue_id = v.venue_id
            WHERE v.venue_admin = '$username' AND b.payment_status = '1'";

    $result = mysqli_query($connect, $query);
    $final = mysqli_fetch_assoc($result);

    echo json_encode($final);
    mysqli_close($connect);
?>