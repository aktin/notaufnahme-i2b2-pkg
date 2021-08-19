#! /bin/bash

set -euo pipefail

readonly RESOURCES=$(pwd)/resources
readonly XML_FILES=$RESOURCES/xml

readonly RES='\e[0m'
readonly RED='\e[0;31m'
readonly GRE='\e[0;32m'

# destination for query testing
URL="http://localhost:80/webclient/"

# loop over all example querys
XML=( getUserAuth getSchemes getQueryMasterList_fromUserId getCategories getModifiers runQueryInstance_fromQueryDefinition getQueryInstanceList_fromQueryMasterId getQueryResultInstanceList_fromQueryInstanceId getQueryResultInstanceList_fromQueryResultInstanceId )
for i in "${XML[@]}"
do
	# check if response of query contains tag <status type=DONE>, print whole response on failure
	RESPONSE=$(curl -d $XML_FILES/@i2b2_$i.xml -s $URL)
	if [ $(echo $RESPONSE | grep -c "<status type=\"DONE\">") == 1 ]; then
		echo -e "${GRE}$i successful${RES}"
	else
		echo -e "${RED}$i failed${RES}"
		echo $RESPONSE
		exit 1
	fi
done