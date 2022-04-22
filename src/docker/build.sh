#!/bin/bash
set -euo pipefail

PACKAGE="aktin-notaufnahme-i2b2"

# Required parameter
VERSION="${1:-}"
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# Optional parameter
FULL="${2:-}"

# Directory this script is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DBUILD="${DIR}/build"

# Cleanup old files
rm -rf "${DIR}/build"

# Load content of .env as environment variables 
export $(cat ${DIR}/.env | xargs)

# Load common linux files (includes versions)
. "$(dirname "${DIR}")/common/build.sh"

# Prepare wildfly docker
mkdir -p "${DBUILD}/wildfly"
sed -e "s/__VWILDFLY__/${VWILDFLY}/g" "${DIR}/wildfly/Dockerfile" > "${DBUILD}/wildfly/Dockerfile"
cp "${DIR}/wildfly/entrypoint.sh" "${DBUILD}/wildfly/"
cp "${DRESOURCES}/standalone.xml.patch" "${DBUILD}/wildfly/"
download_wildfly_jdbc "/wildfly"
download_wildfly_i2b2 "/wildfly"
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
	LIST_IMAGES=( ${I2B2IMAGENAMESPACE}database ${I2B2IMAGENAMESPACE}wildfly ${I2B2IMAGENAMESPACE}httpd )
	for IMAGE in ${LIST_IMAGES[*]}; do
		echo $IMAGE
		# Stop and remove running container if exists
  		ID_CONTAINER=$(docker ps -q -f ancestor=${IMAGE}:latest)
		if [ -n ${ID_CONTAINER} ]; then
			docker stop ${ID_CONTAINER} || true
			docker rm ${ID_CONTAINER} || true
		fi
		# Remove image
		ID_IMAGE=$(docker images -q ${IMAGE}:latest)
		if [ -n ${ID_IMAGE} ]; then
			docker image rm ${ID_IMAGE} || true
		fi
	done

	cwd="$(pwd)"
	cd "${DIR}"
	docker-compose build
	cd "${cwd}"
fi
