<?php
    include("./config.php");

    $venue_id = $_POST['venue_id'];
    $court_name = $_POST['court_name'];
    $court_desc = $_POST['court_desc'];
    $court_image = $_FILES['court_image'];
    $sport_selected = $_POST['sport_selected'];
    
    $query = "INSERT INTO court VALUES (NULL, '$venue_id', '$sport_selected', '$court_name', '$court_desc', NULL)";
    
    if(mysqli_query($connect, $query)){

        $get_court_id = "SELECT * 
                        FROM court 
                        WHERE venue_id = '$venue_id' 
                        ORDER BY court_id DESC 
                        LIMIT 1";
        $image_name_result = mysqli_query($connect, $get_court_id);
        $image_name_result = mysqli_fetch_assoc($image_name_result);
        $image_name = $image_name_result['court_id'];
        $image_ext = explode('.', $court_image['name']);

        $court_id = $image_name_result['court_id'];
        
        $temp = count($image_ext)-1;
        $image_name = "COURT_".$image_name.".".$image_ext[$temp];
        
        $dest = '../court_image/';

        $update_image = "UPDATE court 
                        SET court_image = '$image_name' 
                        WHERE court_id = '$court_id'";
        
        if(mysqli_query($connect, $update_image)){
            move_uploaded_file($court_image['tmp_name'], $dest.$image_name);
        }

        echo json_encode(["status"=> "1", "message" => "Court Successfully Added!"]);
    } else {
        echo json_encode(["status"=> "0", "message" => "Failed to Add Court!"]);
    }

    mysqli_close($connect);
?>
