#!/bin/bash
# Downloads packages from HOST to local
# Passwords are dummy passwords.

# -------- CONFIG --------
OUTPUT_TMP="./../output/a2-backup-p1"
PACKAGE_NAME="a3-migrated-live-article-p1-02-03-2022"
USERNAME="<USERNAME>"
PASSWORD="<PASSWORD>"
HOST="<HOST>"
PROTOCOL="http://"
PORT="4503"
NUMBER_OF_PACKAGES=1

START_PACKAGE=""
PKG_NUMBER="1"
# -------- CONFIG --------



# ------ MAIN --------
#rm -rf ${OUTPUT_TMP}

if [ ! -z "$START_PACKAGE" ] ; then
  echo " START_PACKAGE = ${START_PACKAGE} "
  PKG_NUMBER=$START_PACKAGE
  echo " Number of packages = ${NUMBER_OF_PACKAGES} and starting Package number = ${PKG_NUMBER}"
else
  echo " START_PACKAGE is EMPTY so running for all packages"
fi

for ((c = PKG_NUMBER; c <= NUMBER_OF_PACKAGES; c++)); do
  if [[ ! -f "$OUTPUT_TMP/${PACKAGE_NAME}-${c}.zip" ]]; then
    url="${PROTOCOL}${HOST}:${PORT}/crx/packmgr/download.jsp?_charset_=utf-8&path=/etc/packages/my_packages/${PACKAGE_NAME}-${c}.zip"
    code=$(curl  -u "${USERNAME}":"${PASSWORD}" -f -L -w '%{http_code}' --create-dirs -o ${OUTPUT_TMP}/${PACKAGE_NAME}-${c}.zip ${url})
    if [[ "$code" =~ ^2 ]]; then
      echo "Dowloaded ${PACKAGE_NAME}-${c}.zip from source ${HOST} to ${OUTPUT_TMP} dir"
    else
      echo "There was an issue downloading ${PACKAGE_NAME}-${c}.zip file from source ${HOST}"
      exit $code
    fi

  else
    echo "File ${PACKAGE_NAME}-${c}.zip aleady exist in ${OUTPUT_TMP} dir"
    fi
done

echo "END"


