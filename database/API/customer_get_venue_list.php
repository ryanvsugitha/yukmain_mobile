<?php
    include("./config.php");

    $search = $_POST['search'];
    $facility = json_decode($_POST['facility']);
    $sport = json_decode($_POST['sport']);
    
    // $query = "SELECT *
    //             FROM venue v
    //             JOIN (
    //                 SELECT * 
    //                 FROM venue_image
    //                 GROUP BY venue_id
    //             ) xd ON v.venue_id = xd.venue_id
    //             WHERE (venue_name LIKE '%$search%' OR venue_address LIKE '%$search%' OR venue_desc LIKE '%$search%')
    //             ORDER BY v.venue_id ASC";

    $query = "SELECT *
                FROM venue v
                JOIN (
                    SELECT * 
                    FROM venue_image
                    GROUP BY venue_id
                ) xd ON v.venue_id = xd.venue_id
                JOIN (
                        SELECT *, GROUP_CONCAT(facility_id ORDER BY facility_id ASC SEPARATOR ',') AS facility_list
                        FROM venue_facility
                        GROUP BY venue_id
                ) fd ON v.venue_id = fd.venue_id
                JOIN (
                        SELECT *, GROUP_CONCAT(sport_id ORDER BY sport_id ASC SEPARATOR ',') AS sport_list
                        FROM venue_sports
                        GROUP BY venue_id
                ) sd ON v.venue_id = sd.venue_id
                WHERE (venue_name LIKE '%%' OR venue_address LIKE '%%' OR venue_desc LIKE '%%')";
    for($i = 0; $i < count($facility); $i++){
        if($facility[$i] == true){
            $curr_id = $i+1;
            $query .= " AND fd.facility_list LIKE '%$curr_id%'";
        }
    }
    for($i = 0; $i < count($sport); $i++){
        if($sport[$i] == true){
            $curr_id = $i+1;
            $query .= " AND sd.sport_list LIKE '%$curr_id%'";
        }
    }
    $query .= " ORDER BY v.venue_id ASC";
    $result = mysqli_query($connect, $query);
    $final = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $final[] = $row;
    }

    echo json_encode($final);
    mysqli_close($connect);
?>