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

if [ -z "$3" ]; then
  printf "You have to provide network ID!\n" >&2
  exit 3
fi

BASE_DIR="$(readlink -m $(dirname $0))/../../"
PROXY_PATH="$(voms-proxy-info -path)"
ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $1`
if [ "$?" -ne 0 ]; then
  printf "Couldn't get an endpoint for $1!\n" >&2
  exit 4
fi

# Remove OCCI-OS hardcored /network/ prefix
RESULT=$(occi --auth x509 --user-cred "$PROXY_PATH" --voms \
     --endpoint "$ENDPOINT" \
     --action link --resource "$2" --link "${ENDPOINT%/}/network/${3#/network/}" 2>&1)

if [ $? -eq 0 ]; then
  printf "$RESULT\n"
else
  if printf "$RESULT" | grep -q 'Floating IP pool not found'; then
    # For some sites it is required to specify the mixin
    occi --auth x509 --user-cred "$PROXY_PATH" --voms \
      --endpoint "$ENDPOINT" \
      --action link --resource "$2" \
      --link "${ENDPOINT%/}/network/${3#/network/}" \
      --mixin 'http://schemas.openstack.org/network/floatingippool#provider'
  else
    printf "$RESULT\n"
    exit 5
  fi
fi
