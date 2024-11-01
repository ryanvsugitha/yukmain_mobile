<?php
    include("./config.php");

    $username = $_POST['username'];
    
    $query = "SELECT * 
                FROM user 
                WHERE username = '$username'";
    $result = mysqli_query($connect, $query);
    $data = mysqli_fetch_assoc($result);

    echo json_encode($data);
    mysqli_close($connect);
?>