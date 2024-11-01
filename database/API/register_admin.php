<?php
    include("./config.php");

    $username = $_POST['username'];
    $password = $_POST['password'];

    $check_username = "SELECT * 
                        FROM user 
                        WHERE username = '$username'";
    $result = mysqli_query($connect, $check_username);
    $result = mysqli_num_rows($result);
    
    if ($result != 0) {
        echo json_encode(['status' => '0', 'message'=> 'Username already exist!']);
    } else {
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $register_query = "INSERT INTO user VALUES ('$username', '$hashed_password', '0', NULL)";
        if(mysqli_query($connect, $register_query)){
            echo json_encode(['status' => '1', 'message'=> 'Register Success!']);
        } else {
            echo json_encode(['status' => '0', 'message'=> 'Failed to register!']);
        }
    }
    mysqli_close($connect);
?>