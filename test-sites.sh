#!/usr/bin/env bash

# Test all the available sites by creating a VM using a pre-defined template and deleting it

# Colors for colorized output
# Color reset
RESET_COLOR='\e[0m' # Text Reset
BLUE_BOLD='\e[1;34m'
RED='\e[0;31m'
GREEN='\e[0;32m'

export COMPUTE_NAME=test-sites-$(whoami)-$(hostname)-$(date +%Y%m%d-%H%m)
export KEEP_VMS=0
WORKING_SITES=''
FAILING_SITES=''
printf "\nCreating VMs with title: ${BLUE_BOLD}$COMPUTE_NAME${RESET_COLOR}\n"

# You can also use a defined list of sites
# SITES='CESGA 100IT'
SITES=$(./list-sites.sh)
if [ $? -ne 0 ]; then
  printf 'Unable to retrieve the list of sites\n'
  exit 1
fi

NB_SITES=$(printf "$SITES" | wc -w)
printf "\nFound ${BLUE_BOLD}$NB_SITES${RESET_COLOR} sites\n"

for SITE in $SITES; do
  printf "\nTesting ${BLUE_BOLD}$SITE${RESET_COLOR}\n"
  START_OUTPUT=$(./start-compute.sh "$SITE" 2>&1)
  if [ $? -eq 0 ]; then
    printf "${GREEN}$SITE${RESET_COLOR} is working!\n"
    WORKING_SITES="$WORKING_SITES\n$SITE"
  else
    printf "${RED}$SITE${RESET_COLOR} returned an error:\n"
    printf "$START_OUTPUT\n"
    FAILING_SITES="$FAILING_SITES\n$SITE"
  fi
done

if [ -n "$WORKING_SITES" ]; then
  NB_SITES_WORKING=$(printf "$WORKING_SITES" | wc -w)
  printf "\nWorking sites (${GREEN}$NB_SITES_WORKING${RESET_COLOR}/$NB_SITES)\n"
  printf "${GREEN}$WORKING_SITES${RESET_COLOR}\n"
fi

if [ -n "$FAILING_SITES" ]; then
  NB_SITES_FAILING=$(printf "$FAILING_SITES" | wc -w)
  printf "\nFailing sites (${RED}$NB_SITES_FAILING${RESET_COLOR}/$NB_SITES)\n"
  printf "${RED}$FAILING_SITES${RESET_COLOR}\n"
fi
