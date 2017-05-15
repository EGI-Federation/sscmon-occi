# Scripts and helpers to automatize testing of EGI FedCloud using occi

This repository contains scripts that have been initially created by [Boris Parak](https://github.com/arax).

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
* python-ipy: for parsing IP

## Contextualization

Create `context/fc-context.yml` using `context/fc-context.yml.template` (be sure to set your ssh key).

## Starting a VM on a site

* `start-compute.sh` will create a VM with a public IP and having the following title set: `my-first-compute-1`.
* Unless KEEP_VMS=1 was set the VM will be deleted.

## Quickly testing on all the sites

```
for SITE in $(./list-sites.sh) ; do printf "Site $SITE\n" ; ./start-compute.sh "$SITE" ; printf "\n\n" ; done
```

## Looking for leftover VM on all the sites

* `list-vms.sh` will look with VM having the following title set: `my-first-compute-1`.
Script can be edited to automatically delete all found VMs, but use with care.

* `clean-compute.sh` can also be used to delete a VM from a site.

```
for SITE in $(./list-sites.sh) ; do printf "Site $SITE\n" ; ./list-vms.sh "$SITE" ; printf "\n\n" ; done
```

## Debugging

### Getting the raw XML from the AppDB

```
APPDB_URL='https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20%2B%3Dsite.hasinstances%3A1%0A'
curl -s -k "$APPDB_URL"
```

### Looking into Site BDII information

* ldap-utils is required to provide ldapsearch command
* Site BDII name can be found in the GocDB: https://goc.egi.eu/portal/

```
SITE_BDII='XXXX'
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue objectClass=GLUE2Endpoint GLUE2EndpointURL
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue '(|(objectClass=GLUE2ApplicationEnvironment)(objectClass=GLUE2ExecutionEnvironment))' GLUE2EntityName
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue '(|(objectClass=GLUE2ApplicationEnvironment)(objectClass=GLUE2ExecutionEnvironment))' GLUE2EntityName | awk '/GLUE2EntityName/ {print $NF}'
```
