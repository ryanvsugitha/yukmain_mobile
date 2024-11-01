<?php
    function distance($lat1, $lon1, $lat2, $lon2, $unit) {
        $theta = $lon1 - $lon2;
        $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
        $dist = acos($dist);
        $dist = rad2deg($dist);
        $miles = $dist * 60 * 1.1515;
        $unit = strtoupper($unit);

        if ($unit == "K") {
            return ($miles * 1.609344);
        } else if ($unit == "N") {
            return ($miles * 0.8684);
        } else {
            return $miles;
        }
    }

    include("./config.php");

    $longitude = $_POST['longitude'];
    $latitude = $_POST['latitude'];

    $query = "SELECT * 
            FROM venue v
            JOIN (
                    SELECT * 
                    FROM venue_image
                    GROUP BY venue_id
                ) xd ON v.venue_id = xd.venue_id
            LIMIT 10";
    
    $result = mysqli_query($connect, $query);
    $final = array();
    while ($row = mysqli_fetch_assoc($result)) {
        if(distance($latitude, $longitude, $row['venue_latitude'], $row['venue_longitude'], "K") <= 5){
            $final[] = $row;
        }
    }

    echo json_encode($final);
    mysqli_close($connect);
?>