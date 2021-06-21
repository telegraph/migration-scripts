#!/bin/bash
# Downloads packages from SOURCE_PACKAGES_HOST and uploads them to HOST
# Passwords are dummy passwords.

# -------- CONFIG --------
INPUT_FILE="./input/input-urls.txt"
OUTPUT_TMP="./output_tmp"
PACKAGE_NAME="a3_tranformed-pages-author"
USERNAME="admin"
PASSWORD="admin"
PROTOCOL="http://"
HOST="localhost"
PORT="4502"
NUMBER_OF_PACKAGES=1
SOURCE_PACKAGES_PROTOCOL="http://"
SOURCE_PACKAGES_HOST="aem-stg64-cms1.aws-preprod.telegraph.co.uk"
SOURCE_PACKAGES_PORT="4502"
SOURCE_PACKAGE_USERNAME="admin"
SOURCE_PACKAGE_PASSWORD="admin"
DELETE_MODE="false"
SINGLE_PACKAGE_MODE="false"
TEMP_FILE="tmp.txt"
LOG_FILE="info.log"
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

processTmp () {
	
 	batchNumber="${1}"
	packageName="${PACKAGE_NAME}-${batchNumber}"
	
	if [ "${DELETE_MODE}" = "true" ]; then
		printf "Trying to delete the package ${packageName} \n"
	    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
	    deleteFile "${OUTPUT_TMP}/${packageName}.zip"
	    deleteFile "${OUTPUT_TMP}/${LOG_FILE}"
	    printf "\n"
	else
		echo "---- START - processing batch $packageName -----"

		cp "${OUTPUT_TMP}/tmp.txt" "${OUTPUT_TMP}/${packageName}.txt"
		printf "${packageName} uploaded\n"
		curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_TMP}/${packageName}".zip -F name="${packageName}" -F force=true -F install=false ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
		printf "\n"
		printf "${packageName} installed\n"
		curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_TMP}/${packageName}".zip -F name="${packageName}" -F force=true -F install=true ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
		printf "\n"

		echo "---- END - processing batch $packageName -----"
	fi

	deleteFile "${OUTPUT_TMP}/${TEMP_FILE}"
}

# ------ MAIN --------
rm -rf ${OUTPUT_TMP}

for (( c=1; c <= NUMBER_OF_PACKAGES; c++ ))
do
	url="${SOURCE_PACKAGES_PROTOCOL}${SOURCE_PACKAGES_HOST}:${SOURCE_PACKAGES_PORT}/crx/packmgr/download.jsp?_charset_=utf-8&path=/etc/packages/my_packages/${PACKAGE_NAME}-${c}.zip"
	code=$(curl  -u "${SOURCE_PACKAGE_USERNAME}":"${SOURCE_PACKAGE_PASSWORD}" -f -L -w '%{http_code}' --create-dirs -o ${OUTPUT_TMP}/${PACKAGE_NAME}-${c}.zip ${url})
	if [[ "$code" =~ ^2 ]]; then
		echo "Dowloaded ${PACKAGE_NAME}-${c}.zip"
	else
		echo "There was an issue downloading the files"
		exit $code
	fi
done

for (( c=1; c <= NUMBER_OF_PACKAGES; c++ ))
do
   processTmp ${c}
done


echo "END"


