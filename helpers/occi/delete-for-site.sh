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

if [ -z "$2" ]; then
  printf "You have to provide compute URI!\n" >&2
  exit 2
fi

BASE_DIR="$(readlink -m $(dirname $0))/../../"
PROXY_PATH="$(voms-proxy-info -path)"
ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an endpoint for $1!\n" >&2
  exit 3
fi

occi --auth x509 --user-cred "$PROXY_PATH" --voms \
     --endpoint "$ENDPOINT" \
     --action delete --resource "$2"
