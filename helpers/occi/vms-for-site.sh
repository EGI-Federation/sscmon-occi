#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a "$DEBUG" = 1 ]; then
  set -x
fi

set -e
set -o pipefail

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2 
  exit 1
fi

COMPUTE_NAME="${COMPUTE_NAME:=my-first-compute-1}"
BASE_DIR="$(readlink -m $(dirname $0))/../../"
PROXY_PATH="$(voms-proxy-info -path)"
ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an endpoint for $1!\n" >&2
  exit 2
fi

occi --auth x509 --user-cred "$PROXY_PATH" --voms \
  --endpoint $ENDPOINT \
  --action describe --resource compute \
  | grep -s -B 2 "title = $COMPUTE_NAME" \
  | awk '/location/ {print $3}'
