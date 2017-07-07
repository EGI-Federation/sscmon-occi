#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a "$DEBUG" = 1 ]; then
  set -x
fi

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2
  exit 1
fi

BASE_DIR="$(readlink -m $(dirname $0))/../../"
PROXY_PATH="$(voms-proxy-info -path)"
COMPUTE_NAME="${COMPUTE_NAME:=my-first-compute-1-$(whoami)-$(hostname)}"
CONTEXT="$BASE_DIR/context/fc-context.yml"

if [ ! -f "$CONTEXT" ]; then
  printf "$CONTEXT is missing, please ensure it exists!\n" >&2
  exit 2
fi

ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an endpoint for $1!\n" >&2
  exit 2
fi

APPLIANCE=`$BASE_DIR/helpers/appdb/get-appliance-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an appliance ID at $1!\n" >&2
  exit 3
fi

SIZE=`$BASE_DIR/helpers/appdb/get-size-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get a size/flavor ID at $1!\n" >&2
  exit 4
fi

occi --auth x509 --user-cred "$PROXY_PATH" --voms \
     --endpoint "$ENDPOINT" \
     --action create --resource compute \
     --attribute occi.core.title="$COMPUTE_NAME" \
     --mixin "$APPLIANCE" \
     --mixin "$SIZE" \
     --context user_data="file://$CONTEXT" \
     --wait-for-active 360
