#!/bin/sh
#  dockerignore_test.sh

# based on BMitch's answer from:
# How to test dockerignore file?
#  https://stackoverflow.com/questions/38946683/how-to-test-dockerignore-file

# tested on: ubuntu 18.04 lts (desktop)
# with:  Docker  version 19.03.12, build 48a66213fe

# note: will create and delete temporary file "Dockerfile.build-context"

# instructions
#
# 1. put this script in the folder where the image is being built
# make it executable using chmod 755  dockerignore_test.sh
#
# 2. edit this script to change the build-context
# for me the build-context is './project' because 
# my  docker-compose.yaml file has lines:
# if the build-context is the current directory 
# then change this to '.'
# 
#   web:
#     image: ...
#     ...
#     build:
#       context: ./project
#
# 3. edit the  .dockerignore  file and put it in the build-context directory
#
# 4. run script
# ./dockerignore_test.sh
# you should see list of files in build context
# these are the files that end up in your image
#
# 5. (optional) capture the list of files
# ./dockerignore_test.sh  > images_files_list
#
# 6. if you see unwanted files, go back to step 3
#

cat <<EOF >  Dockerfile.build-context
FROM  busybox
COPY . /build-context
WORKDIR /build-context
CMD find .
EOF

docker build -f  Dockerfile.build-context -t build-context ./project
docker run --rm -it build-context

rm  Dockerfile.build-context