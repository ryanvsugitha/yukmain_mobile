<?php
    include("./config.php");
    
    $query = "SELECT * 
                FROM sport 
                ORDER BY sport_id ASC";
    $result = mysqli_query($connect, $query);
    $final = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $final[] = $row;
    }

    echo json_encode($final);
    mysqli_close($connect);
?>