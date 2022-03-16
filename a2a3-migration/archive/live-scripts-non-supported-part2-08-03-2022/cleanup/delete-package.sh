#!/bin/bash
# Cleanup : Passwords are dummy passwords. Delete packages from server

# -------- CONFIG --------
PACKAGE_NAME="a2-backup-non-supported-part2-<DATE>"
#PACKAGE_NAME="a3-migrated-non-supported-part2-<DATE>"
USERNAME="<USERNAME>"
PASSWORD="<PASSWORD>"
HOST="<HOST>"
PROTOCOL="http://"
PORT="4502"
DELETE_MODE="true"
NUMBER_OF_PACKAGES="33"
# -------- CONFIG --------



# FUNCTIONS
deleteFile () {
	if [ -f "${1}" ]; then
		rm -rf "${1}"
	fi
}

processTmp () {

 	batchNumber="${1}"
	packageName="${PACKAGE_NAME}-${batchNumber}"

	if [ "${DELETE_MODE}" = "true" ]; then
	  echo "---- BEGIN - processing batch $batchNumber of $NUMBER_OF_PACKAGES from ${HOST}"
		printf "Trying to delete the package ${packageName} from ${HOST} \n"
	    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
	    printf "\n"
		echo "---- END - processing batch $batchNumber of $NUMBER_OF_PACKAGES  from ${HOST}"
	fi

}

# ------ MAIN --------
for (( c=1; c <= NUMBER_OF_PACKAGES; c++ ))
do
   processTmp ${c}
done
echo "END"