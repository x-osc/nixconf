#! /usr/bin/env bash

download_path=$(echo "${SLSKD_SCRIPT_DATA}" | jq -r .localDirectoryName)

curl \
    --request POST \
    --data-urlencode "path=${download_path}" \
    "http://:verycoolpassword@localhost:7373/op/move"
