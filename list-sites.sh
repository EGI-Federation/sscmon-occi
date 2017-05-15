#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a $DEBUG -eq 1 ]; then
  set -x
fi

set -o pipefail
set -e

XPATH_BIN='xpath'
APPDB_URL='https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20%2B%3Dsite.hasinstances%3A1%0A'

XPATH_SELECTOR='/appdb:appdb/appdb:site[contains(@infrastructure, "Production") and contains(@status, "Certified")]/site:service[contains(@type, "occi")]/../@name'

SITES=`curl -s -k "$APPDB_URL" | $XPATH_BIN -q -e "$XPATH_SELECTOR" 2> /dev/null | awk -F '=' '{ print $2 }' | sort -u | sed 's/"//g'`
if [ -z "$SITES" ]; then
  printf "There are no production sites available right now!\n" >&2
  exit 1
fi

printf "$SITES\n"
