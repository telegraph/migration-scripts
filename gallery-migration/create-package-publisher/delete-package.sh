#!/bin/bash
# Passwords are dummy passwords.

# -------- CONFIG --------
PACKAGE_NAME="migrated-galleries-publisher"
USERNAME="telegraph-cq-admin"
PASSWORD="VO9?~A2BC*VtqG"
PROTOCOL="http://"
HOST="54.78.59.174"
PORT="4503"
# -------- CONFIG --------

processTmp () {

 	batchNumber="${1}"
	packageName="${PACKAGE_NAME}-${batchNumber}"

		printf "Trying to delete the package ${packageName} \n"
	    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
	    printf "\n"
}

batchNumber=13
while [ $batchNumber -le 13 ]
do
    processTmp $batchNumber
    let batchNumber++
done

echo "END"