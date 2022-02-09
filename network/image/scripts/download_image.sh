#!/bin/bash

# Exit if any of the intermediate steps fail
set -ex

eval "$(jq -r '@sh "IMAGE_URL=\(.image_url)"')"

# IMAGE_URL="https://rhcos-redirector.apps.art.xq1c.p1.openshiftapps.com/art/storage/releases/rhcos-4.9/49.84.202110081407-0/x86_64/rhcos-49.84.202110081407-0-ibmcloud.x86_64.qcow2.gz"

local_image_file=$(echo $IMAGE_URL|awk -F/ '{print $NF}')
local_image_file_uncompressed=${local_image_file/.gz/}

test -e $local_image_file_uncompressed || {
  curl -sLo $local_image_file $IMAGE_URL
  gunzip $local_image_file
}

local_image_file_uncompressed="${PWD}/${local_image_file_uncompressed}"
jq -n --arg local_image_file_uncompressed "$local_image_file_uncompressed" '{"local_image_file_uncompressed":$local_image_file_uncompressed}'
