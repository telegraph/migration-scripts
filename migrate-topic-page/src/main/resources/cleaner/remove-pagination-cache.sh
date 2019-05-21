#!/usr/bin/bash

FILE="${1}"

#--- CONFIG
PAGINATION=".selector.html"
# please not include the last "/" of the TELEGRAPH_CACHE path
TELEGRAPH_CACHE="CACHE_LOCATION"
#--- CONFIG

while read -r LINE
do
  NAME=$(basename "${LINE}")
  URL="${NAME}${PAGINATION}"
  echo "Name read from file - ${URL}"
  echo "${TELEGRAPH_CACHE}/${URL}"
  rm -rf "${TELEGRAPH_CACHE}/${URL}"
done < "${FILE}"
