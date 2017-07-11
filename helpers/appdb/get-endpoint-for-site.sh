#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a "$DEBUG" = 1 ]; then
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

XPATH_SELECTOR="/appdb:appdb/appdb:site[contains(@infrastructure, 'Production') and contains(@status, 'Certified') and contains(@name, \"$1\")]/site:service[contains(@service_status, 'OK')]/siteservice:occi_endpoint_url/text()"

ENDPOINTS=`curl -s -k "$APPDB_URL" | $XPATH_BIN -q -e "$XPATH_SELECTOR" 2> /dev/null`
if [ -z "$ENDPOINTS" ]; then
  printf "Couldn't find a production endpoint at $1!\n" >&2
  exit 2
fi

# Exit with an error in case of multiple endpoints
NB_ENDPOINTS=$(printf "$ENDPOINTS" | wc -w)
if [ $NB_ENDPOINTS -gt 1 ]; then
  printf "Found multiple endpoints for $1:\n" >&2
  printf "$ENDPOINTS\n" >&2
  exit 2
fi

# Return only the first endpoint
ENDPOINT=`printf "$ENDPOINTS" | head -n 1`

printf "$ENDPOINT\n"
