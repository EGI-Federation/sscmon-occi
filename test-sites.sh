#!/bin/sh

# Test all the available sites by creating a VM using a pre-defined template and deleting it

export COMPUTE_NAME=test-sites-$(whoami)-$(hostname)-$(date +%Y%m%d-%H%m)
export KEEP_VMS=0
WORKING_SITES=''
FAILING_SITES=''

printf "Creating VMs with title: $COMPUTE_NAME\n"

# You can also use a defined list of sites
# SITES='CESGA 100IT'
SITES=$(./list-sites.sh)
if [ $? -ne 0 ]; then
  printf 'Unable to retrieve the list of sites\n'
  exit 1
fi

NB_SITES=$(printf "$SITES" | wc -w)
printf "\nFound $NB_SITES sites\n"

for SITE in $SITES; do
  printf "\nTesting $SITE\n"
  START_OUTPUT=$(./start-compute.sh "$SITE" 2>&1)
  if [ $? -eq 0 ]; then
    printf "$SITE is working!\n"
    WORKING_SITES="$WORKING_SITES\n$SITE"
  else
    printf "$SITE returned an error:\n"
    printf "$START_OUTPUT\n"
    FAILING_SITES="$FAILING_SITES\n$SITE"
  fi
done

if [ -n "$WORKING_SITES" ]; then
  NB_SITES_WORKING=$(printf "$WORKING_SITES" | wc -w)
  printf "\nWorking sites ($NB_SITES_WORKING/$NB_SITES)\n"
  printf "$WORKING_SITES\n"
fi

if [ -n "$FAILING_SITES" ]; then
  NB_SITES_FAILING=$(printf "$FAILING_SITES" | wc -w)
  printf "\nFailing sites ($NB_SITES_FAILING/$NB_SITES)\n"
  printf "$FAILING_SITES\n"
fi
