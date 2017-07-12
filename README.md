# Scripts and helpers to automatize testing of EGI FedCloud using occi

This repository contains scripts that have been initially created by [Boris Parak](https://github.com/arax).

## Overview

* Information about the sites is taken from the AppDB
  * AppDB gets information from GocDB and from the Top BDII gathering information from all the Site BDIIs
  * Endpoints that are not OK in [ARGO](http://argo.egi.eu/lavoisier/status_report-site?report=Critical&Fedcloud=true&accept=html) are not used
* `list-sites.sh` lists sites supporting the VO returned by `voms-proxy-info -vo`
* Interaction with the sites is done using OCCI
* All unsuccessful deployment attempts are cleaned
* By default all VM successfully instantiated are deleted, set `KEEP_VMS=1`
  if you want to keep them running
* Set `COMPUTE_NAME=my-custom-vm-title` to define the title of the VM to be created
* Set `DEBUG=1` to make scripts be run with `set -x`

## Dependencies

* `perl-xml-xpath` (`libxml-xpath-perl` on Ubuntu): for xpath filtering of AppDB XML output
* `jq`: for jq filtering of OCCI JSON output
* `occi, CAs and updated CRLs` using `fetch-crl`: https://wiki.egi.eu/wiki/HOWTO11 
* `python-ipy`: for parsing IP

## Contextualization

Create `context/fc-context.yml` using `context/fc-context.yml.template` (be
sure to set your ssh key).

## Starting a VM on a site

* `start-compute.sh` will create a VM with a public IP and having the title set
  to `my-first-compute-1-$(whoami)-$(hostname)` unless `COMPUTE_NAME` was set
  to a custom title.
* It is recommended to set a custom `COMPUTE_NAME` to allow to easily
  search and differentiate VMs from those launched by other users.
* Unless `KEEP_VMS=1` is set the VM will be deleted.

```sh
./start-compute.sh <SITE_NAME>
KEEP_VMS=1 ./start-compute.sh <SITE_NAME>
KEEP_VMS=1 COMPUTE_NAME=my-custom-test-vm ./start-compute.sh <SITE_NAME>
```

You can export `KEEP_VMS` and `COMPUTE_NAME` to use them during a complete session.

```sh
export KEEP_VMS=1
export COMPUTE_NAME=my-custom-test-vm
./start-compute.sh <SITE_NAME>
./list-vms.sh <SITE_NAME>
```

## Quickly testing on all the sites

The provided `test-sites.sh` script can be used to ease the testing of all the
sites: it will test all discovered sites in sequence and produce a sumarry of
the results.

```sh
./test-sites.sh
```

## Looking for leftover VMs on all the sites

* `list-vms.sh` will look for VM having the title set to `COMPUTE_VM` or will
  default to `my-first-compute-1-$(whoami)-$(hostname)`.

Script can be edited to automatically delete all found VMs, but please consider
doing this with care.

* `clean-compute.sh` can be used to delete a VM from a site.

```sh
for SITE in $(./list-sites.sh); do printf "Site $SITE\n"; ./list-vms.sh "$SITE"; printf "\n\n"; done
```

## Debugging

* Set `DEBUG=1` to enable debugging of the scripts (they will be run with `set -x`).
* The `appdb` and `occi` helpers can be used directly to do things manually.
* Look for information in:
  * [AppDB](https://appdb.egi.eu)
  * [GocDB](https://goc.egi.eu)
  * [ARGO monitoring](http://argo.egi.eu/lavoisier/status_report-site?report=Critical&Fedcloud=true&accept=html)
  * `Site BDII`: found in the `GocDB`
  * `Top BDII`: `ldap://lcg-bdii.cern.ch:2170`. It should contain all the
    information from the `Site BDII`
* For some `OpenStack` sites it is possible to use the native `OpenStack` CLI
  to test things if the `voms authentication` was configured for the endpoint

### Understanding why no endpoints are found for a site

* Check endpoint name in the [GocDB](https://goc.egi.eu)
* Check endpoint status in the [ARGO monitoring](http://argo.egi.eu/lavoisier/status_report-site?report=Critical&Fedcloud=true&accept=html)
* Check information available in the `Site BDII`. The `Site BDII` can be
  found in the `GocDB`, it is a service of type `Site-BDII` with the scope
  tag `FedCloud` set.

### Enabling debug output

```sh
DEBUG=1 ./start-compute.sh <SITE_NAME>
```

### Using the AppDB and OCCI helpers directly

The AppDB and OCCI helpers (specialized scripts that are used to do a specific
tasks) can be used directly and separately:

```sh
# Finding the endpoint of a site
./helpers/appdb/get-endpoint-for-site.sh <SITE_NAME>
# Finding the public network of a site
./helpers/occi/public-for-site.sh <SITE_NAME>
```

### Getting the raw XML from the AppDB

* EGI AppDB REST API documentation: https://wiki.egi.eu/wiki/EGI_AppDB_REST_API_v1.0

```sh
APPDB_URL='https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20%2B%3Dsite.hasinstances%3A1%0A'
curl -s -k "$APPDB_URL"
```

* The XML can be filtered using `xpath` as done in the `AppDB` helpers.

### Finding information about the sites in the GocDB

* Search the site name in the GocDB for information: https://goc.egi.eu/portal/
* The GocDB lists the downtimes published for a site

### Checking ARGO monitoring information

* [ARGO monitoring](http://argo.egi.eu/lavoisier/status_report-site?report=Critical&Fedcloud=true&accept=html)
  allows to see the status of the services registered in the GocDB
* In order to see the status of a site, use the following URL, replacing
  SITENAME by the exact name of the site:
  * http://argo.egi.eu/lavoisier/status_report-sf?report=Critical&accept=html&site=SITENAME

### Looking into Site BDII and Top BDII

* ldap-utils or similar is required to provide `ldapsearch` command
* BDII are mainly LDAP directories, so any LDAP client tool can be used
* Site BDII names can be found in the [GocDB](https://goc.egi.eu/portal/)
* Top BDII is `ldap://lcg-bdii.cern.ch:2170` and aggregates all the information
  from the Site BDIIs.

```sh
SITE_BDII='XXXX'
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue objectClass=GLUE2ComputingEndpoint 
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue objectClass=GLUE2Endpoint GLUE2EndpointURL
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue '(|(objectClass=GLUE2ApplicationEnvironment)(objectClass=GLUE2ExecutionEnvironment))' GLUE2EntityName
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue '(|(objectClass=GLUE2ApplicationEnvironment)(objectClass=GLUE2ExecutionEnvironment))' GLUE2EntityName | awk '/GLUE2EntityName/ {print $NF}'
# Replace SITENAME by the name of the site
ldapsearch -LLL -x -H ldap://lcg-bdii.cern.ch:2170 -b GLUE2DomainID=SITENAME,GLUE2GroupID=grid,o=glue
```

### Using OpenStack native CLI

* If a native `OpenStack` endpoint is configured at a site to use `VOMS`
  authentication it can be used as a manual alternative to OCCI.
* The native `OpenStack` endpoint can sometimes be discovered in the `GocDB` or 
  in the `Site BDII` search for an URL with port `5000` or the `v2.0` API Version.

```sh
ldapsearch -LLL -x -h $SITE_BDII -p 2170 -b o=glue objectClass=GLUE2Endpoint | grep -E '5000|v2.0'
```

`OpenStack` clients will need to have the [VOMS authentication plugin](https://github.com/enolfc/openstack-voms-auth-type),
see [EGI WiKi](https://wiki.egi.eu/wiki/Federated_Cloud_APIs_and_SDKs#CLI) for some
usage information.

Once the endpoint was found it is required to set the variables required by `OpenStack` tools.

``` sh
# Pepare OpenStack environment
export OS_AUTH_URL='<NATIVE_OPENSTACK_ENDPOINT>'
export OS_AUTH_TYPE=v2voms
export OS_X509_USER_PROXY=$(voms-proxy-info -path)
openstack project list
export OS_PROJECT_ID=<PROJECT_UUID>
# Interact with OpenStack services
openstack image list
openstack flavor list
openstack server list
```
