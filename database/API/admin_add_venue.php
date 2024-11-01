<?php
    include("./config.php");

    $venue_admin = $_POST["venue_admin"];
    $venue_name = $_POST["venue_name"];
    $venue_desc = $_POST["venue_desc"];
    $venue_address = $_POST["venue_address"];
    $venue_longitude = $_POST["venue_longitude"];
    $venue_latitude = $_POST["venue_latitude"];
    $venue_open = $_POST["venue_open"];
    $venue_close = $_POST["venue_close"];
    $venue_facility = json_decode($_POST["venue_facility"]);
    $venue_sport = json_decode($_POST["venue_sport"]);
    
    $query = "INSERT INTO venue VALUES 
                (NULL, '$venue_name', '$venue_address', 
                '$venue_desc', '$venue_open', '$venue_close', '$venue_longitude', '$venue_latitude', '$venue_admin');";

    $facility = "SELECT * FROM facility ORDER BY facility_id ASC";
    $facility = mysqli_query($connect, $facility);
    $facility_check = array();
    while ($row = mysqli_fetch_assoc($facility)) {
        $facility_check[] = $row;
    }

    $sport = "SELECT * FROM sport ORDER BY sport_id ASC";
    $sport = mysqli_query($connect, $sport);
    $sport_check = array();
    while ($row = mysqli_fetch_assoc($sport)) {
        $sport_check[] = $row;
    }
    
    if(mysqli_query($connect, $query)){
        $get_venue_id = "SELECT * 
                        FROM venue 
                        WHERE venue_admin = '$venue_admin' 
                        ORDER BY venue_id DESC 
                        LIMIT 1";
        $curr_venue_id = mysqli_query($connect, $get_venue_id);
        $curr_venue_id = mysqli_fetch_assoc($curr_venue_id);
        $curr_venue_id = $curr_venue_id['venue_id'];

        for($i = 0; $i<count($facility_check); $i++){
            if($venue_facility[$i] == true){
                $curr_facility = $facility_check[$i]['facility_id'];
                $facility_query = "INSERT INTO venue_facility VALUES ('$curr_venue_id', '$curr_facility');";
                mysqli_query($connect, $facility_query);
            }
        }

        for($i = 0; $i<count($sport_check); $i++){
            if($venue_sport[$i] == true){
                $curr_sport = $sport_check[$i]['sport_id'];
                $sport_query = "INSERT INTO venue_sports VALUES ('$curr_venue_id', '$curr_sport');";
                mysqli_query($connect, $sport_query);
            }
        }

        for ($i = 1; $i <= 10; $i++){
            if(isset($_FILES['image_'.$i])){
                $image_ext = explode('.', $_FILES['image_'.$i]['name']);
                $temp = count($image_ext)-1;

                $dest = '../venue_image/';

                $image_name = "VEN_".$curr_venue_id."_IMG_"."$i.".$image_ext[$temp];
                $insert_venue_image = "INSERT INTO venue_image VALUES ('$curr_venue_id', '$image_name', NULL)";
                if(mysqli_query($connect, $insert_venue_image)){
                    move_uploaded_file($_FILES['image_'.$i]['tmp_name'], $dest.$image_name);
                }
            }
        }

        echo json_encode(['status' => '1','message'=> 'New Venue Added!']);
    } else {
        echo json_encode(['status' => '0','message'=> 'Failed to Add New Venue!']);
    }
    mysqli_close($connect);
?>