#!/bin/bash
set -euo pipefail

PACKAGE="aktin-notaufnahme-i2b2"

# Required parameter
VERSION="${1}"
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# Directory this script is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DBUILD="${DIR}/build/${PACKAGE}_${VERSION}"

# Cleanup
rm -rf "${DIR}/build"

# Load common linux files
. "$(dirname "${DIR}")/common/build.sh"

# prepare package environment
download_i2b2_webclient "/var/www/html/webclient"
config_i2b2_webclient "/var/www/html/webclient"
download_wildfly "/opt/wildfly"
config_wildfly "/opt/wildfly"
init_wildfly_systemd "/opt/wildfly" "/etc/wildfly" "/lib/systemd/system"
download_wildfly_jdbc "/opt/wildfly/standalone/deployments"
download_wildfly_i2b2 "/opt/wildfly/standalone/deployments"
copy_database_for_postinstall "/usr/share/${PACKAGE}/database"
copy_datasource_for_postinstall "/usr/share/${PACKAGE}/datasource"
copy_helper_functions_for_postinstall "/usr/share/${PACKAGE}"

# Prepare .deb management scripts and control files
mkdir -p "${DBUILD}/DEBIAN"
sed -e "s/__PACKAGE__/${PACKAGE}/g" \
    -e "s/__VERSION__/${VERSION}/g" \
    "${DIR}/control" > "${DBUILD}/DEBIAN/control"
cp "${DIR}/config" "${DBUILD}/DEBIAN/"
cp "${DIR}/postinst" "${DBUILD}/DEBIAN/"
cp "${DIR}/prerm" "${DBUILD}/DEBIAN/"
sed -e "/^__I2B2_DROP__/{r ${DRESOURCES}/database/i2b2_postgres_drop.sql" -e 'd;}' "${DIR}/postrm" > "${DBUILD}/DEBIAN/postrm" && chmod 0755 "${DBUILD}/DEBIAN/postrm"

dpkg-deb --build "${DBUILD}"
rm -rf "${DBUILD}"
