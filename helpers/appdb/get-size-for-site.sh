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

XPATH_SELECTOR="/appdb:appdb/appdb:site[contains(@infrastructure, \"Production\") and contains(@status, \"Certified\") and contains(@name, \"$1\")]/site:service[contains(@type, \"occi\") and contains(@service_status, 'OK')]/provider:template[provider_template:main_memory_size[. >= 512 and . <= 4096] and provider_template:logical_cpus[. > 1 and . < 5]][1]/provider_template:resource_name/text()"

SIZE=`curl -s -k "$APPDB_URL" | $XPATH_BIN -q -e "$XPATH_SELECTOR" 2> /dev/null | head -n 1`
if [ -z "$SIZE" ]; then
  printf "Couldn't find any suitable size/flavor at $1!\n" >&2
  exit 2
fi

printf "$SIZE\n"
