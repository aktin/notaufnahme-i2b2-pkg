#!/bin/bash
set -euo pipefail

# Required parameters
PACKAGE="${1}"
VERSION="${2}"

# Optional parameter
FULL="${3}"

# Check if variables are empty
if [ -z "${PACKAGE}" ]; then echo "\$PACKAGE is empty."; exit 1; fi
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
move_datasource_for_postinstall "/wildfly/ds"

# Prepapare postgresql docker
mkdir -p "${DBUILD}/database"
cp "${DIR}/database/Dockerfile" "${DBUILD}/database/"
move_database_for_postinstall "/database/sql"
cat "${DBUILD}/database/sql/i2b2_postgres_init.sql" >"${DBUILD}/database/sql/00_init.sql"
cat "${DBUILD}/database/sql/i2b2_db.sql" >>"${DBUILD}/database/sql/00_init.sql"

# Prepare apache2 docker
mkdir -p "${DBUILD}/httpd"
cp "${DIR}/httpd/Dockerfile" "${DBUILD}/httpd/"
download_i2b2_webclient "/httpd/i2b2webclient"
config_i2b2_webclient "/httpd/i2b2webclient"

# Run docker-compose
if [ "${FULL}" = "full" ]; then
	cwd="$(pwd)"
	cd "${DIR}"
	docker-compose build
	cd "${cwd}"
fi
