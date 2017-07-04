#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a "$DEBUG" = 1 ]; then
  set -x
fi

set -o pipefail

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2 
  exit 1
fi

BASE_DIR="$(readlink -m $(dirname $0))/../../"
PROXY_PATH="$(voms-proxy-info -path)"
ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an endpoint for $1!\n" >&2
  exit 2
fi

# With OOI network should have: id == 'PUBLIC'
# With deprecated OCCI-OS network should have: id == '/network/public'
INTIF=$(occi --auth x509 --user-cred "$PROXY_PATH" --voms \
  --endpoint "$ENDPOINT" \
  --action describe --resource network \
  --output-format json_extended | jq -r \
  '.[] | select(.["attributes"]["occi"]["core"]["id"] == "PUBLIC" or .["attributes"]["occi"]["core"]["id"] == "/network/public") | .["id"]')

# With OpenNebula network should have: title == 'public'
if [ -z "$INTIF" ]; then
  INTIF=$(occi --auth x509 --user-cred "$PROXY_PATH" --voms \
    --endpoint "$ENDPOINT" \
    --action describe --resource network \
    --output-format json_extended | jq -r \
    '.[] | select(.["attributes"]["occi"]["core"]["title"] == "public") | .["id"]')
fi

printf "$INTIF\n"
