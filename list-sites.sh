#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a "$DEBUG" = 1 ]; then
  set -x
fi

set -o pipefail
set -e

# Filter (flt parameter) has to be URL encoded
# AppDB REST API filtering: https://wiki.egi.eu/wiki/EGI_AppDB_REST_API_v1.0#Paging_and_Filtering
# URL encode/decode: http://urldecode.org/

# Filter all sites having at least one OCCI endpoint and one image obtained from the AppDB
# +=site.supports:1 +=site.hasinstances:1
# FILTER='%2B%3Dsite.supports%3A1%20%2B%3Dsite.hasinstances%3A1%0A'

# Filter all sites having at least one OCCI endpoint and one image obtained from the AppDB
# and supporting the VO used by the available voms proxy, like fedcloud.egi.eu
# +=site.supports:1 +=site.hasinstances:1 +=vo.name:fedcloud.egi.eu
VO=$(voms-proxy-info -vo)
FILTER="%2b%3dsite.supports%3a1+%2b%3dsite.hasinstances%3a1+%2b%3dvo.name%3a${VO}%0d%0a"

APPDB_URL="https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=${FILTER}"

XPATH_BIN='xpath'
XPATH_SELECTOR='/appdb:appdb/appdb:site[contains(@infrastructure, "Production") and contains(@status, "Certified")]/site:service[contains(@type, "occi")]/../@name'

SITES=`curl -s -k "$APPDB_URL" | $XPATH_BIN -q -e "$XPATH_SELECTOR" 2> /dev/null | awk -F '=' '{ print $2 }' | sort -u | sed 's/"//g'`
if [ -z "$SITES" ]; then
  printf "There are no production sites available right now!\n" >&2
  exit 1
fi

printf "$SITES\n"
