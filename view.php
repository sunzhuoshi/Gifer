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
        $src = ROOT_DIR . $id;
        echo "<img src=\"$src\"/>";
    }
    else {
        echo 'Invalid parameter(s)';
    }
    ?>
</div>
</body>
</html>