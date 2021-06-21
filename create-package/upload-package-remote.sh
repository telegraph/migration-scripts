#!/bin/bash
# Passwords are dummy passwords.

# -------- CONFIG --------
INPUT_FILE="./input/input-urls.txt"
OUTPUT_TMP="./output_tmp"
PACKAGES="https://drive.google.com/u/0/uc?id=1yWHbmeNEszDV8sFMsSffQbkZWRziNrX6&export=download"
PACKAGE_NAME="author_packages"
USERNAME="admin"
PASSWORD="admin"
PROTOCOL="http://"
HOST="localhost"
PORT="4502"
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
echo "Getting list of packages from ${PACKAGES}"
curl -s -L --create-dirs -o ${OUTPUT_TMP}/packages.csv ${PACKAGES}
counter=0  
while read line
do
	curl -s -L --create-dirs -o ${OUTPUT_TMP}/${PACKAGE_NAME}-${counter}.zip ${line}
	echo "Dowloaded ${line} as ${PACKAGE_NAME}-${counter}.zip"
	let counter++
done < ${OUTPUT_TMP}/packages.csv

for (( c=0; c<counter; c++ ))
do
   processTmp ${c}
done


echo "END"


