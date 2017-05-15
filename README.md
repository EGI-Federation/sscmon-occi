# Scripts and helpers to automatize testing of EGI FedCloud using occi

## Overview

* Information about the sites is taken from the AppDB
* list-sites.sh does not filter sites, some might not support the required VO
* Interaction with the sites is done using OCCI
* All unsuccessful deployment attempts are cleaned
* By default all VM successfully instantiated are deleted, export `KEEP_VMS=1`
  if you want to keep them running
* Export `DEBUG=1` to make scripts be run with `set -x`

## Dependencies

* perl-xml-xpath (libxml-xpath-perl on Ubuntu): for xpath filtering of AppDB XML output
* jq: for jq filtering of OCCI JSON output
* occi, CAs and updated CRLs using fetch-crls: https://wiki.egi.eu/wiki/HOWTO11 

## Quickly testing on all the sites

```
for SITE in $(./list-sites.sh) ; do printf "Site $SITE\n" ; ./start-compute.sh "$SITE" ; printf "\n\n" ; done
```

## Looking for leftover VM on all the sites

This will look with VM having the following title set: `my-first-compute-1`.
Script can be edited to automatically delete all found VMs, but use with care.

```
for SITE in $(./list-sites.sh) ; do printf "Site $SITE\n" ; ./list-vms.sh "$SITE" ; printf "\n\n" ; done
```
