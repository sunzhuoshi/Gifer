<!DOCTYPE html>
<html manifest="gifer.manifest">
<head>
    <title></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0">
    <style type="text/css">
        html body {
            margin: 10px 0;
        }
        #image_wrapper {
            margin: 10px auto;
            max-width: 300px;
            text-align: center;
        }
        img {
            width: 100%;
        }
    </style>
</head>
<body>
<div id="image_wrapper">
    <?php
    const ROOT_DIR = 'share/';
    $queries = Array();
    parse_str($_SERVER['QUERY_STRING'], $queries);

    if (isset($queries['id'])) {
        $id = $queries['id'];
        $image_file_path = ROOT_DIR . $id;
        $image_comment = '';
        $image_comment_file_path = $image_file_path . '.txt';

        // comment
        $image_comment_file = fopen($image_comment_file_path, 'r');
        if ($image_comment_file) {
            $image_comment = fread($image_comment_file, filesize($image_comment_file_path));
            fclose($image_comment_file);
        }
        if ($image_comment) {
            echo "<div style='padding: 5px'>$image_comment</div>";
        }
        // image
        echo "<img src=\"$image_file_path\"/>";
    }
    else {
        echo 'Invalid parameter(s)';
    }
    ?>
</div>
</body>
</html>