<?php
    include("./config.php");

    $username = $_POST['username'];
    $password = $_POST['password'];

    
    $query = "SELECT * 
                FROM user 
                WHERE username = '$username'";
    $result = mysqli_query($connect, $query);
    $data = mysqli_fetch_assoc($result);
    
    if(password_verify($password, $data['password'])) {
        echo json_encode(['status' => '1', 'message'=> 'Login Success!', 'role' => $data['role_id']]);
    } else {
        echo json_encode(['status' => '0', 'message'=> 'Incorrect Username or Password!']);
    }
    mysqli_close($connect);
?>