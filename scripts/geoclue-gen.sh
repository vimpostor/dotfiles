#!/usr/bin/env bash

# This script generates a static geoclue location file
# It uses the local timezone and looks up the coordinates of the timezone's city in the tzdb timezone description zone tab

LOCALTIME=/etc/localtime
ZONETAB=/usr/share/zoneinfo/zone1970.tab
GEOLOCATION=/etc/geolocation

set -e

TIMEZONE="$(file -b "$LOCALTIME" | grep -Eo '[[:alnum:]]+/[[:alnum:]]+$')"
SDMS="$(grep "$TIMEZONE" "$ZONETAB" | cut -f2)"
# These coordinates are in sign-degrees-minutes-seconds-format as per ISO-6709,
# thus we have to convert them to decimal degree coordinates first
LATITUDE="${SDMS%[+-]*}"
LONGITUDE="${SDMS:${#LATITUDE}}"
# Most coordinates are given as ±DDMM±DDDMM, but ±DDMMSS±DDDMMSS is also possible.
# For now just ignore the SS part, they are the least significant bits anyway
LATITUDESIGN="${LATITUDE:0:1}"
LATITUDEDEGREE="${LATITUDE:1:2}"
LATITUDEMINUTE="${LATITUDE:3:2}"
LONGITUDESIGN="${LONGITUDE:0:1}"
LONGITUDEDEGREE="${LONGITUDE:1:3}"
LONGITUDEMINUTE="${LONGITUDE:4:2}"

LATITUDEDECIMAL="$(echo | awk "{print $LATITUDESIGN${LATITUDEDEGREE#0} + ${LATITUDEMINUTE#0}/60}")"
LONGITUDEDECIMAL="$(echo | awk "{print $LONGITUDESIGN${LONGITUDEDEGREE#0} + ${LONGITUDEMINUTE#0}/60}")"

printf "%s # latitude\n%s # longitude\n0.0 # altitude\n1000.0 # accuracy radius\n" "$LATITUDEDECIMAL" "$LONGITUDEDECIMAL" | tee "$GEOLOCATION"

# extra security as per man 5 geoclue
chown geoclue "$GEOLOCATION"
chmod 600 "$GEOLOCATION"
