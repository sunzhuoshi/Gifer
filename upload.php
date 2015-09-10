<?php
$UPLOAD_DIR = 'share/';
$MAX_FILE_SIZE = 10000000;   // 10mb

$ALLOW_FILE_TYPES = array(
    'image/jpeg' => 1,
    'image/png' => 1,
    'image/gif' => 1
);

date_default_timezone_set('UTC');

$file = $_FILES['file'];
$file_name = basename($file['name']);
$target = $UPLOAD_DIR . $file_name;
$file_size = $file['size'];
$file_type = $file['type'];
$file_url = '';

$ERROR_NO = 0;
$ERROR_OVER_FILE_SIZE = 1;
$ERROR_INVALID_FILE_TYPE = 2;
$ERROR_INVALID_PARAM = 3;
$ERROR_UNKNOWN = 4;

$ERROR_MESSAGES = array(
    $ERROR_NO => 'ok',
    $ERROR_OVER_FILE_SIZE => "file size is larger than max($MAX_FILE_SIZE)",
    $ERROR_INVALID_FILE_TYPE => "invalid file type($file_type)",
    $ERROR_INVALID_PARAM => 'invalid parameter',
    $ERROR_UNKNOWN => 'unknown error'
);

$result_code = $ERROR_NO;

if (!$file) {
    $result_code = $ERROR_INVALID_PARAM;
}
else if ($file_size > $MAX_FILE_SIZE)  {
    $result_code = $ERROR_OVER_FILE_SIZE;
}
else if (!array_key_exists($file_type, $ALLOW_FILE_TYPES)) {
    $result_code = $ERROR_INVALID_FILE_TYPE;
}
else {
    if (move_uploaded_file($file['tmp_name'], $target)) {
        $referrer = $_SERVER['REQUEST_URI'];
        $endIndex = strrpos($referrer, '/');
        if (0 <= $endIndex) {
            $referrer = substr($referrer, 0, $endIndex + 1);
            $file_url = 'http://'. $_SERVER['SERVER_NAME'] . $referrer . 'view.php?id=' . $file_name;
        }
        else {
            $result_code = $ERROR_UNKNOWN;
        }
    }
    else {
        $result_code = $ERROR_UNKNOWN;
    }
}

$response = array(
    'code' => $result_code,
    'msg' => $ERROR_MESSAGES[$result_code]
);

if ($result_code == $ERROR_NO) {
    $response['url'] = $file_url;
}

// JSON_UNESCAPED_SLASHES not supported by php 5.3;
echo json_encode($response, 0);
