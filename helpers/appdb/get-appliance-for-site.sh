#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a $DEBUG -eq 1 ]; then
  set -x
fi

set -o pipefail
set -e

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2
  exit 1
fi

XPATH_BIN='xpath'
APPDB_URL='https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20%2B%3Dsite.hasinstances%3A1%0A'
VO_NAME='fedcloud.egi.eu'
#APPDB_AID='c22f717b-1a4d-4f75-a547-f6d8ae368c77' # CentOS 7 for fedcloud.egi.eu
APPDB_AID='6a532a8f-ba71-4c5c-99e9-ac1cfe467708' # CentOS 6 for fedcloud.egi.eu https://appdb.egi.eu/store/vappliance/egi.centos.6

XPATH_SELECTOR="string(/appdb:appdb/appdb:site[contains(@infrastructure, \"Production\") and contains(@status, \"Certified\") and contains(@name, \"$1\")]/site:service[contains(@type, \"occi\")]/siteservice:image[contains(@identifier, \"$APPDB_AID\")]/siteservice:occi/vo:vo[contains(@name, \"$VO_NAME\")]/../@id)"

APPL_ID=`curl -s -k "$APPDB_URL" | $XPATH_BIN -q -e "$XPATH_SELECTOR" 2> /dev/null | head -n 1`
if [ -z "$APPL_ID" ]; then
  printf "Appliance \"$APPDB_AID\" not available at $1 for VO $VO_NAME!\n" >&2
  exit 2
fi

printf "$APPL_ID\n"
