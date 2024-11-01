<?php
    include("./config.php");

    $admin_id = $_POST['admin_id'];
    $search = $_POST['search'];
    
    $query = "SELECT *
                FROM venue v
                JOIN (
                    SELECT * 
                    FROM venue_image
                    GROUP BY venue_id
                ) xd ON v.venue_id = xd.venue_id
                WHERE venue_admin = '$admin_id' AND 
                    (venue_name LIKE '%$search%' OR venue_address LIKE '%$search%' OR venue_desc LIKE '%$search%')
                ORDER BY v.venue_id ASC";
    $result = mysqli_query($connect, $query);
    $final = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $final[] = $row;
    }

    echo json_encode($final);
    mysqli_close($connect);
?>