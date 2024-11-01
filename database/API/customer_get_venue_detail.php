<?php
    include("./config.php");

    $venue_id = $_POST['venue_id'];
    
    $query = "SELECT * 
                FROM venue
                WHERE venue_id = '$venue_id'";
    $result_detail = mysqli_query($connect, $query);
    $final_detail = mysqli_fetch_assoc($result_detail);

    $venue_image_query = "SELECT * 
                        FROM venue_image 
                        WHERE venue_id = '$venue_id' 
                        ORDER BY image_name ASC";
    $result_image = mysqli_query($connect, $venue_image_query);
    $final_image = array();
    while ($row = mysqli_fetch_assoc($result_image)) {
        $final_image[] = $row;
    }

    $get_court = "SELECT *, c.court_id
                FROM court c
                JOIN sport s ON c.sport_id = s.sport_id
                LEFT JOIN (
                        SELECT *,
                            CASE
                                WHEN FORMAT(MIN(price), 0, 'id_ID') IS NULL THEN NULL
                                ELSE FORMAT(MIN(price), 0, 'id_ID')
                            END AS min_price,
                            CASE
                                WHEN FORMAT(MAX(price), 0, 'id_ID') IS NULL THEN NULL
                                ELSE FORMAT(MAX(price), 0, 'id_ID')
                            END AS max_price
                        FROM court_schedule
                        GROUP BY court_id
                ) dt ON c.court_id = dt.court_id
                WHERE venue_id = '$venue_id' 
                ORDER BY c.court_id ASC";
    $result_court = mysqli_query($connect, $get_court);
    $final_court = array();
    while ($row = mysqli_fetch_assoc($result_court)) {
        $final_court[] = $row;
    }

    $get_facility = "SELECT *
                FROM venue v
                JOIN venue_facility vf ON v.venue_id = vf.venue_id
                JOIN facility f ON vf.facility_id = f.facility_id
                WHERE v.venue_id = '$venue_id' 
                ORDER BY v.venue_id ASC";
    $result_facility = mysqli_query($connect, $get_facility);
    $final_facility = array();
    while ($row = mysqli_fetch_assoc($result_facility)) {
        $final_facility[] = $row;
    }

    $get_sport = "SELECT *
                FROM venue_sports vs
                JOIN sport s ON vs.sport_id = s.sport_id
                WHERE venue_id = '$venue_id' 
                ORDER BY s.sport_id ASC";
    $result_sport = mysqli_query($connect, $get_sport);
    $final_sport = array();
    while ($row = mysqli_fetch_assoc($result_sport)) {
        $final_sport[] = $row;
    }

    $final = $final_detail;
    $final += ['venue_images' => $final_image];
    $final += ['venue_courts' => $final_court];
    $final += ['venue_sports' => $final_sport];
    $final += ['venue_facility' => $final_facility];

    echo json_encode($final);
    mysqli_close($connect);
?>