#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a $DEBUG -eq 1 ]; then
  set -x
fi

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2
  exit 1
fi

BASE_DIR="$HOME/sscmon-occi"
OCCI_DIR="$BASE_DIR/helpers/occi"

VMS=`$BASE_DIR/helpers/appdb/get-vms-for-site.sh $1`

if [ -n "$VMS" ]; then
  for VM in "$VMS"; do
    if [ -n "$DEBUG" -a $DEBUG -eq 1 ]; then
      occi --auth x509 --user-cred "$PROXY_PATH" --voms \
        --endpoint "$ENDPOINT" --action describe --resource "$VM" \
        --output-format json_extended | jq
    else
      printf "$VM\n" 
    fi

    # XXX Uncomment to delete VM
    # $OCCI_DIR/delete-for-site.sh "$ENDPOINT" "$VM"
    # TODO Get INTF_LINK from the VM description
    # IFS=`occi --auth x509 --user-cred "$PROXY_PATH" --voms --endpoint "$ENDPOINT" --action describe --resource "$2" --output-format json_extended | jq -r '.[0]["links"] | .[] | select(.kind == "http://schemas.ogf.org/occi/infrastructure#networkinterface" or .kind == "http://schemas.ogf.org/occi/core#link") | .["attributes"]["occi"]["networkinterface"]["address"]'`
    # TODO Release IP
    # if [ -z $INTTF_LINK ]; then
    #   $OCCI_DIR/release-for-site.sh "$1" "$INTF_LINK"
    # fi
  done
fi
