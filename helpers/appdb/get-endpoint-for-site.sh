#!/bin/bash

#
#
#

set -o pipefail
set -e

if [ -z "$1" ]; then
  printf "You have to provide a site name!\n" >&2
  exit 1
fi

XPATH_BIN='/usr/local/bin/xpath'
APPDB_URL='https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20%2B%3Dsite.hasinstances%3A1%0A'

XPATH_SELECTOR="/appdb:appdb/appdb:site[contains(@infrastructure, 'Production') and contains(@status, 'Certified') and contains(@name, \"$1\")]/site:service/siteservice:occi_endpoint_url/text()"

ENDPOINT=`curl -s -k "$APPDB_URL" | $XPATH_BIN -q -e "$XPATH_SELECTOR" 2> /dev/null | head -n 1`
if [ -z "$ENDPOINT" ]; then
  printf "Couldn't find a production endpoint at $1!\n" >&2
  exit 2
fi

printf "$ENDPOINT\n"
