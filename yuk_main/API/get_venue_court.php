<?php
    include("./config.php");

    $venue_id = $_POST['venue_id'];
    
    $query = "SELECT *             
            FROM venue_sports vs
            JOIN sport s ON vs.sport_id = s.sport_id
            WHERE vs.venue_id = '$venue_id'   
            ORDER BY s.sport_id ASC";
    $result = mysqli_query($connect, $query);
    $final = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $final[] = $row;
    }

    echo json_encode($final);
    mysqli_close($connect);
?>