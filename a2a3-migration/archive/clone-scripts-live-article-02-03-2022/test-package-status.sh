#!/bin/bash
# Cleanup : Passwords are dummy passwords. Delete packages from server

# -------- CONFIG --------
PACKAGE_NAME="a2-backup-p1-22-07-2021"
USERNAME="admin"
PASSWORD="Telegraphpreprod!"
HOST="pub.aem-qa11.platforms-preprod-gcp.telegraph.co.uk"
PROTOCOL="http://"
PORT="4503"
NUMBER_OF_PACKAGES="35"
# -------- CONFIG --------



# FUNCTIONS
deleteFile () {
	if [ -f "${1}" ]; then
		rm -rf "${1}"
	fi
}
checkPackageStatus() {
  packageExist="true"
  packageCheck=$(curl -u "${USERNAME}":"${PASSWORD}" -s -I -w %{http_code} "${PROTOCOL}${HOST}:${PORT}/etc/packages/my_packages/${packageName}.zip")
  if [[ $packageCheck =~ "404 Not Found" ]]; then
    packageExist="false"
  else
    packageInstallationCheck=$(curl -u "${USERNAME}":"${PASSWORD}" "${PROTOCOL}${HOST}:${PORT}/etc/packages/my_packages/${packageName}.zip/jcr:content/vlt:definition.json" | grep 'lastUnpacked')
    if [ ! -z "$packageInstallationCheck" ]; then
      packageExist="true"
    else
      packageExist="false"
    fi
  fi
  echo "$packageExist"
}

processTmp () {

 	batchNumber="${1}"
	packageName="${PACKAGE_NAME}-${batchNumber}"
  packageStatus=$(checkPackageStatus "$packageName")
  if [ "${packageStatus}" = "false" ]; then
	  echo "---- ${packageName} might not exist or not installed"
	else
	  echo "---- ${packageName} is installed"
	fi

}

# ------ MAIN --------
for (( c=1; c <= NUMBER_OF_PACKAGES; c++ ))
do
   processTmp ${c}
done
echo "END"