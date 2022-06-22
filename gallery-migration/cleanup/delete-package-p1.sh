#!/bin/bash
# Cleanup : Passwords are dummy passwords. Delete packages from server

# -------- CONFIG --------
TODAYS_DATE=$(date +"%d-%m-%Y")
#PACKAGE_NAME="old-galleries-backup-p1-$TODAYS_DATE"
PACKAGE_NAME="migrated-galleries-publisher"
USERNAME="telegraph-cq-admin"
PASSWORD="VO9?~A2BC*VtqG"
HOST="54.78.59.174"
PROTOCOL="http://"
PORT="4503"
DELETE_MODE="true"
NUMBER_OF_PACKAGES="17"
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