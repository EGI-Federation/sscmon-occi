#!/usr/bin/env bash

# Dump the VMs of all the sites, displaying minimal info about them

# Colors for colorized output
# Color reset
RESET_COLOR='\e[0m' # Text Reset
BLUE_BOLD='\e[1;34m'

X509_USER_PROXY="$(voms-proxy-info -path)"
BASE_DIR="$(readlink -m $(dirname $0))"

SITES=$(./list-sites.sh)
if [ $? -ne 0 ]; then
  printf 'Unable to retrieve the list of sites\n'
  exit 1
fi

NB_SITES=$(printf "$SITES" | wc -w)
printf "\nFound ${BLUE_BOLD}$NB_SITES${RESET_COLOR} sites\n"
for SITE in $SITES; do
  printf "\nSearching VM on ${BLUE_BOLD}$SITE${RESET_COLOR}\n"

  ENDPOINT=`$BASE_DIR/helpers/appdb/get-endpoint-for-site.sh $SITE`
  if [ $? -ne 0 ]; then
    printf "Couldn't get an endpoint for $SITE!\n" >&2
  else
    occi -X -e $ENDPOINT -x $X509_USER_PROXY -n x509 \
      -a describe -r compute \
      | grep -E '^(>> location:|occi.core.id|occi.core.title|occi.compute.hostname)'
  fi
done
