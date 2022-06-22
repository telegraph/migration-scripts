#!/bin/bash
# Uploads locally downloaded packages to HOST
# Passwords are dummy passwords.

# -------- CONFIG --------
OUTPUT_TMP="./packages/publisher"
PACKAGE_NAME="migrated-galleries-publisher"
USERNAME="telegraph"
PASSWORD="VO9?~A2BC*VtqG"
HOST="54.76.251.186"
PROTOCOL="http://"
PORT="4503"
NUMBER_OF_PACKAGES=1
DELETE_MODE="false"
TEMP_FILE="tmp-p1.txt"
LOG_FILE="upload-p1-info.log"

START_PACKAGE=""
PKG_NUMBER="1"
# -------- CONFIG --------



# FUNCTIONS
deleteFile () {
	if [ -f "${1}" ]; then
		rm -rf "${1}"
	fi
}

getFilters () {
	filter=""
	while read line
	do
		if [ ! -z "$line" ]; then
			echo "${2} : ${line}" >> "${OUTPUT_FILE}/${LOG_FILE}"
	    	filter="${filter} {\"root\" : \"${line}\", \"rules\": []}, "
	    fi
	done < "${1}"
	echo "${filter:0:${#filter}-2}"
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
  packageExist=$(checkPackageStatus "$packageName")
  if [ "$packageExist" = "false" ]; then
    printf "'${packageName}.zip' package does not exist in the host ${HOST}, so uploading... \n"

	if [ "${DELETE_MODE}" = "true" ]; then
		printf "Trying to delete the package ${packageName} in host ${HOST} \n"
	    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
	    deleteFile "${OUTPUT_TMP}/${packageName}.zip"
	    deleteFile "${OUTPUT_TMP}/${LOG_FILE}"
	    printf "\n"
	else
      echo "---- START - processing batch $packageName ----- in the host ${HOST} "

		cp "${OUTPUT_TMP}/tmp.txt" "${OUTPUT_TMP}/${packageName}.txt"
      printf "${packageName} uploaded to the host ${HOST} \n"
		curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_TMP}/${packageName}".zip -F name="${packageName}" -F force=true -F install=false ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
		printf "\n"
      printf "${packageName} installed in the host ${HOST} \n"
		curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_TMP}/${packageName}".zip -F name="${packageName}" -F force=true -F install=true ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
		printf "\n"

      echo "---- END - processing batch $packageName ----- in the host ${HOST} "
    fi

  else
    echo "'${packageName}.zip' package already installed in the host ${HOST}, so SKIPPING the package"
	fi

	deleteFile "${OUTPUT_TMP}/${TEMP_FILE}"
}

# ------ MAIN --------
if [ ! -z "$START_PACKAGE" ]; then
  echo " START_PACKAGE = ${START_PACKAGE}"
  PKG_NUMBER=$START_PACKAGE
  echo " Number of packages = ${NUMBER_OF_PACKAGES} and starting Package number = ${PKG_NUMBER}"
else
  echo " START_PACKAGE is EMPTY so running for all packages"
fi

for (( c=PKG_NUMBER; c <= NUMBER_OF_PACKAGES; c++ ))
do
   processTmp ${c}
done


echo "END"


