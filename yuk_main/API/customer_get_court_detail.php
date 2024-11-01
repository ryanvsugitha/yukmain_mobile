<?php
    include("./config.php");

    $court_id = $_POST['court_id'];
    
    $query_detail = "SELECT * 
                FROM court c
                JOIN sport s ON c.sport_id = s.sport_id
                WHERE c.court_id = '$court_id'";
    $result_detail = mysqli_query($connect, $query_detail);
    $final_detail = mysqli_fetch_assoc($result_detail);

    $final = $final_detail;
    
    echo json_encode($final);
    mysqli_close($connect);
?>