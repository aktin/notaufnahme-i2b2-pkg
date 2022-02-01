#!/bin/bash
set -euo pipefail

PACKAGE="aktin-notaufnahme-i2b2"

# Required parameter
VERSION="${1}"

# Optional parameter
FULL="${2}"

# Check if variables are empty
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# Directory this script is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DBUILD="${DIR}/build"

# Cleanup
rm -rf "${DIR}/build"

export I2B2IMAGENAMESPACE="$(echo "${PACKAGE}" | awk -F '-' '{print "ghcr.io/"$1"/"$2"-i2b2-"}')"
export DWHIMAGENAMESPACE="$(echo "${PACKAGE}" | awk -F '-' '{print "ghcr.io/"$1"/"$2"-dwh-"}')"

# Load common linux files
. "$(dirname "${DIR}")/common/build.sh"

# Prepare wildfly docker
mkdir -p "${DBUILD}/wildfly"
sed -e "s/__VWILDFLY__/${VWILDFLY}/g" "${DIR}/wildfly/Dockerfile" >"${DBUILD}/wildfly/Dockerfile"
cp "${DIR}/wildfly/entrypoint.sh" "${DBUILD}/wildfly/"
cp "${DRESOURCES}/standalone.xml.patch" "${DBUILD}/wildfly/"
download_wildfly_i2b2 "/wildfly"
download_wildfly_jdbc "/wildfly"
copy_datasource_for_postinstall "/wildfly/ds"

# Prepapare postgresql docker
mkdir -p "${DBUILD}/database"
cp "${DIR}/database/Dockerfile" "${DBUILD}/database/"
copy_database_for_postinstall "/database/sql"

# Prepare apache2 docker
mkdir -p "${DBUILD}/httpd"
cp "${DIR}/httpd/Dockerfile" "${DBUILD}/httpd/"
download_i2b2_webclient "/httpd/i2b2webclient"
config_i2b2_webclient "/httpd/i2b2webclient"

# Run docker-compose
if [ "${FULL}" = "full" ]; then

	# Clean up old images
	docker image rm ${I2B2IMAGENAMESPACE}database
	docker image rm ${I2B2IMAGENAMESPACE}wildfly
	docker image rm ${I2B2IMAGENAMESPACE}httpd

	cwd="$(pwd)"
	cd "${DIR}"
	docker-compose build
	cd "${cwd}"
fi