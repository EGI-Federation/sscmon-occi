# Try!

for SITE in $(./list-sites.sh) ; do echo "Site $SITE" ; ./start-compute.sh "$SITE" ; echo -e "\n\n" ; done
