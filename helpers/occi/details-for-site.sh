#!/bin/bash

#
#
#

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

IPS=`occi --auth x509 --user-cred "$PROXY_PATH" --voms --endpoint "$ENDPOINT" --action describe --resource "$2" --output-format json_extended | jq -r '.[0]["links"] | .[] | select(.kind == "http://schemas.ogf.org/occi/infrastructure#networkinterface" or .kind == "http://schemas.ogf.org/occi/core#link") | .["attributes"]["occi"]["networkinterface"]["address"]'`
for IP in $IPS ; do
  IP_TYPE=`python -c "from IPy import IP ; ip = IP(\"$IP\") ; print(ip.iptype())"`
  if [ "x$IP_TYPE" == "xPUBLIC" ]; then
    PUBLIC_IP=$IP
  fi
done

if [ -z "$PUBLIC_IP" ]; then
  echo $IPS | head -n 1
else
  printf "$PUBLIC_IP\n"
fi
