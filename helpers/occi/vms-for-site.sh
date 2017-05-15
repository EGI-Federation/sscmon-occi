#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a $DEBUG -eq 1 ]; then
  set -x
fi

set -o pipefail

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2 
  exit 1
fi

BASE_DIR="$HOME/sscmon-occi"
PROXY_PATH="$(voms-proxy-info -path)"
ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an endpoint for $1!\n" >&2
  exit 2
fi

occi --endpoint $endpoint --auth x509 --user-cred $proxy_path --voms \
  --action describe --resource compute \
  | grep -q -s -b 2 'title = my-first-compute-1' \
  | awk '/location/ {print $3}'
