<?php

    date_default_timezone_set("Asia/Jakarta");

    define('HOST', '127.0.0.1');
    define('USER', 'root');
    define('PASS', '');
    define('DB', 'yuk_main');

    $connect = mysqli_connect(HOST,USER,PASS,DB) or die('Unable to Connect');
?>