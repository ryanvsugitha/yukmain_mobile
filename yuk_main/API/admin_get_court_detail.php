<?php
    include("./config.php");

    $court_id = $_POST['court_id'];
    
    $query_detail = "SELECT * 
                FROM court  c
                JOIN sport s ON c.sport_id = s.sport_id
                WHERE court_id = '$court_id'";
    $result_detail = mysqli_query($connect, $query_detail);
    $final_detail = mysqli_fetch_assoc($result_detail);

    $query_schedule = "SELECT *, FORMAT(price, 0, 'id_ID') as formatted_price
                        FROM court_schedule 
                        WHERE court_id = '$court_id'";
    $result_schedule = mysqli_query($connect, $query_schedule);
    $final_schedule = array();
    while($row = mysqli_fetch_assoc($result_schedule)){
        $final_schedule[] = $row;
    }

    $final = $final_detail;
    $final += ['court_schedule' => $final_schedule];

    echo json_encode($final);
    mysqli_close($connect);
?>