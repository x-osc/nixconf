set -euo pipefail

exec > >(systemd-cat -t wrtag) 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') - run_wrtag.sh started"
echo "SLSKD_SCRIPT_DATA: $SLSKD_SCRIPT_DATA"

download_path=$(echo "${SLSKD_SCRIPT_DATA}" | jq -r .localDirectoryName)
echo "download path: $download_path"

curl \
    --request POST \
    --data-urlencode "path=${download_path}" \
    "http://:verycoolpassword@localhost:7373/op/move"

