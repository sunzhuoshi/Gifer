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

tar_file='gifer.tar.gz'

echo "removing hidden file(s)..."
find . -name ".DS_Store"  | xargs rm -f

echo "packaging..."
tar -zcf $tar_file gifer.manifest index.html test.html upload.php view.php share .htaccess

echo "uploading..."
scp $tar_file $upload_user@$upload_server:$upload_dir/

echo "deploying..."
deploy_cmd="cd $upload_dir; tar -xvf $tar_file; rm -f *.tar.gz; ls"
ssh $upload_user@$upload_server $deploy_cmd
