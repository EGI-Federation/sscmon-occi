#!/bin/bash

#
#
#

if [ -n "$DEBUG" -a "$DEBUG" = 1 ]; then
  set -x
fi

set -o pipefail
set -e

BASE_DIR="$(readlink -m $(dirname $0))"
OCCI_DIR="$BASE_DIR/helpers/occi"

$OCCI_DIR/delete-for-site.sh $*
