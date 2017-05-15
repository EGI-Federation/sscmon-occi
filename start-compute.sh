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

COMPUTE_ID=`$OCCI_DIR/create-for-site.sh "$1"`
if [ "$?" -ne 0 ] || [ -z "$COMPUTE_ID" ]; then
  printf "Couldn't start a compute instance!\n" >&2
  exit 2
fi

COMPUTE_IP=`$OCCI_DIR/details-for-site.sh "$1" "$COMPUTE_ID"`
if [ "$?" -ne 0 ] || [ -z "$COMPUTE_IP" ]; then
  printf "Couldn't get compute instance details, running clean-up!\n" >&2
  $OCCI_DIR/delete-for-site.sh "$1" "$COMPUTE_ID"
  exit 3
fi

IP_TYPE=`python -c "from IPy import IP ; ip = IP(\"$COMPUTE_IP\") ; print(ip.iptype())"`
if [ "x$IP_TYPE" = "xPRIVATE" ]; then
  PUBLIC_NET_ID=`$OCCI_DIR/public-for-site.sh "$1"`
  if [ "$?" -ne 0 ] || [ -z "$PUBLIC_NET_ID" ]; then
    printf "Couldn't find a public network, running clean-up!\n" >&2
    $OCCI_DIR/delete-for-site.sh "$1" "$COMPUTE_ID"
    exit 4
  fi

  INTF_LINK=`$OCCI_DIR/attach-for-site.sh "$1" "$COMPUTE_ID" "$PUBLIC_NET_ID"`
  if [ "$?" -ne 0 ] || [ -z "$INTF_LINK" ]; then
    printf "Couldn't attach a public network, running clean-up!\n" >&2
    $OCCI_DIR/delete-for-site.sh "$1" "$COMPUTE_ID"
    exit 5
  fi

  COMPUTE_IP=`$OCCI_DIR/details-for-site.sh "$1" "$COMPUTE_ID"`
  if [ "$?" -ne 0 ] || [ -z "$COMPUTE_IP" ]; then
    printf "Couldn't get compute instance details, running clean-up!\n" >&2
    $OCCI_DIR/delete-for-site.sh "$1" "$COMPUTE_ID"
    $OCCI_DIR/release-for-site.sh "$1" "$INTF_LINK"
    exit 3
  fi
fi

# VM instantiation successful
printf "$COMPUTE_ID $COMPUTE_IP\n"

# Release IP and delete VM unless requested
if [ -z "$KEEP_VMS" -o $KEEP_VMS -ne 1 ]; then
  if [ -n "$INTTF_LINK" ]; then
    $OCCI_DIR/release-for-site.sh "$1" "$INTF_LINK"
  fi
  $OCCI_DIR/delete-for-site.sh "$1" "$COMPUTE_ID"
fi
