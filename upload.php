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
$file_size = $file['size'];
$file_type = $file['type'];
$target = $UPLOAD_DIR . $file_name;
$file_url = '';

$ERROR_NO = 0;
$ERROR_TOO_LARGE_FILE_SERVER = 1;
$ERROR_TOO_LARGE_FILE = 2;
$ERROR_INVALID_FILE_TYPE = 3;
$ERROR_INVALID_PARAM = 4;
$ERROR_UNKNOWN = -1;

$detail_error_message = '';

$ERROR_MESSAGES = array(
    $ERROR_NO => 'ok',
    $ERROR_TOO_LARGE_FILE_SERVER => 'too large file(server)',
    $ERROR_TOO_LARGE_FILE => "too large file($file_size / $MAX_FILE_SIZE)",
    $ERROR_INVALID_FILE_TYPE => "invalid file type($file_type)",
    $ERROR_INVALID_PARAM => 'invalid parameter',
    $ERROR_UNKNOWN => 'unknown error'
);

$result_code = $ERROR_NO;

if (!$file) {
    $result_code = $ERROR_INVALID_PARAM;
}
else {
    $file_error = $file['error'];
    switch($file_error) {
        case 1:
            $result_code = $ERROR_TOO_LARGE_FILE_SERVER;
            break;
        case 0:
            if ($file_size > $MAX_FILE_SIZE)  {
                $result_code = $ERROR_TOO_LARGE_FILE;
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
            break;
        default:
            $result_code = $ERROR_UNKNOWN;
            $detail_error_message = ", file error: $file_error";
            break;
    }
}

$response = array(
    'code' => $result_code,
    'msg' => $ERROR_MESSAGES[$result_code] . $detail_error_message
);

if ($result_code == $ERROR_NO) {
    $response['url'] = $file_url;
}

// JSON_UNESCAPED_SLASHES not supported by php 5.3;
echo json_encode($response, 0);
