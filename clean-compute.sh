#!/bin/bash

#
#
#

set -o pipefail
set -e

BASE_DIR="$HOME/sscmon-occi"
OCCI_DIR="$BASE_DIR/helpers/occi"

$OCCI_DIR/delete-for-site.sh $*
