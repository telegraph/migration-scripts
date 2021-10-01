#!/bin/bash
# Cleanup : Passwords are dummy passwords. Delete packages from server

# -------- CONFIG --------
# PACKAGE_NAME=("travel_migration_pages" "backup-travel-tags-pages" "travel_migration_entire_backup_package" "travel_migration_delta_backup_package")
PACKAGE_NAME=("livepost-pages-13-08-2021")

USERNAME="admin"
PASSWORD="Telegraphpreprod!"
HOST="cms.aem-qa11.platforms-preprod-gcp.telegraph.co.uk"
PROTOCOL="http://"
PORT="4502"
DELETE_MODE="true"
NUMBER_OF_PACKAGES="11"
# -------- CONFIG --------

# FUNCTIONS
deleteFile() {
  if [ -f "${1}" ]; then
    rm -rf "${1}"
  fi
}

processTmp() {

  batchNumber="${1}"
  packageOriginalName="${2}"
  packageName="${packageOriginalName}-${batchNumber}"

  if [ "${DELETE_MODE}" = "true" ]; then
    echo "---- BEGIN - processing batch $batchNumber of $NUMBER_OF_PACKAGES from ${HOST}"
    printf "Trying to delete the package ${packageName} from ${HOST} \n"
    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
    printf "\n"
    echo "---- END - processing batch $batchNumber of $NUMBER_OF_PACKAGES  from ${HOST}"
  fi

}

# ------ MAIN --------
for i in ${PACKAGE_NAME[*]}; do
  echo "Parent - "$i
 for ((c = 1; c <= NUMBER_OF_PACKAGES; c++)); do
   echo "Child - "$c
   processTmp ${c} $i
 done
done
echo "END"
