#!/bin/sh
source config.sh

if [ ! $upload_server ]; then
    echo 'upload_server not assigned'
    exit 1
fi
if [ ! $upload_user ]; then
    echo 'upload_user not assigned'
    exit 1
fi
if [ ! $upload_dir ]; then
    echo 'upload_dir not assigned'
    exit 1
fi

tar_file='gifer.tar.gz';

echo "removing hidden file(s)..."
rm -rf .DS_Store

echo "packaging..."
tar -zcf $tar_file test.html upload.php share

echo "uploading..."
scp $tar_file $upload_user@$upload_server:$upload_dir/

echo "deploying..."
deploy_cmd="cd $upload_dir; rm -rf `ls | grep -v .tar.gz`; tar -xvf $tar_file_name; ls"
ssh $upload_user@$upload_server $deploy_cmd
