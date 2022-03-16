#!/bin/bash
# Downloads packages from SOURCE_PACKAGES_HOST and uploads them to HOST
# Passwords are dummy passwords.

# -------- CONFIG --------
OUTPUT_TMP="./output/a3-migrated-p1"
PACKAGE_NAME="a3-migrated-p1-13-07-2021"
USERNAME="telegraph"
PASSWORD="VO9?~A2BC*VtqG"
PROTOCOL="http://"
HOST="aem-stg64-pub1.aws-preprod.telegraph.co.uk"
PORT="4503"
NUMBER_OF_PACKAGES=30
SOURCE_PACKAGES_PROTOCOL="http://"
SOURCE_PACKAGES_HOST="10.38.10.9"
SOURCE_PACKAGES_PORT="4503"
SOURCE_PACKAGE_USERNAME="telegraph"
SOURCE_PACKAGE_PASSWORD="8dOWF3aO+K%w9tNe]>wn*?Tc"
DELETE_MODE="false"
SINGLE_PACKAGE_MODE="false"
TEMP_FILE="tmp.txt"
LOG_FILE="info.log"

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
rm -rf ${OUTPUT_TMP}

if [ ! -z "$START_PACKAGE" ]; then
  echo " START_PACKAGE = ${START_PACKAGE}"
  PKG_NUMBER=$START_PACKAGE
  echo " Number of packages = ${NUMBER_OF_PACKAGES} and starting Package number = ${PKG_NUMBER}"
else
  echo " START_PACKAGE is EMPTY so running for all packages"
fi

for ((c = PKG_NUMBER; c <= NUMBER_OF_PACKAGES; c++)); do
	url="${SOURCE_PACKAGES_PROTOCOL}${SOURCE_PACKAGES_HOST}:${SOURCE_PACKAGES_PORT}/crx/packmgr/download.jsp?_charset_=utf-8&path=/etc/packages/my_packages/${PACKAGE_NAME}-${c}.zip"
	code=$(curl  -u "${SOURCE_PACKAGE_USERNAME}":"${SOURCE_PACKAGE_PASSWORD}" -f -L -w '%{http_code}' --create-dirs -o ${OUTPUT_TMP}/${PACKAGE_NAME}-${c}.zip ${url})
	if [[ "$code" =~ ^2 ]]; then
		echo "Dowloaded ${PACKAGE_NAME}-${c}.zip from source ${SOURCE_PACKAGES_HOST} to ${OUTPUT_TMP} dir"
	else
		echo "There was an issue downloading the files from source ${SOURCE_PACKAGES_HOST}"
		exit $code
	fi
done

for ((c = PKG_NUMBER; c <= NUMBER_OF_PACKAGES; c++)); do
   processTmp ${c}
done


echo "END"


