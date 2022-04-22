#!/bin/bash
set -euo pipefail

readonly PACKAGE="aktin-notaufnahme-i2b2"

readonly VERSION="${1:-}"
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

readonly DCURRENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly DBUILD="${DCURRENT}/build/${PACKAGE}_${VERSION}"

function load_common_files_and_prepare_environment() {
    . "$(dirname "${DCURRENT}")/common/build.sh"
    clean_up_build_environment
    init_build_environment   
}

function prepare_package_environment() {
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
}

function prepare_managment_scripts_and_files() {
    mkdir -p "${DBUILD}/DEBIAN"
    sed -e "s/__PACKAGE__/${PACKAGE}/g" -e "s/__VERSION__/${VERSION}/g" "${DCURRENT}/control" > "${DBUILD}/DEBIAN/control"
    cp "${DCURRENT}/config" "${DBUILD}/DEBIAN/"
    cp "${DCURRENT}/postinst" "${DBUILD}/DEBIAN/"
    cp "${DCURRENT}/prerm" "${DBUILD}/DEBIAN/"
    sed -e "/^__I2B2_DROP__/{r ${DRESOURCES}/database/i2b2_postgres_drop.sql" -e 'd;}' "${DCURRENT}/postrm" > "${DBUILD}/DEBIAN/postrm" && chmod 0755 "${DBUILD}/DEBIAN/postrm"
}

function build_package() {
    dpkg-deb --build "${DBUILD}"
    rm -rf "${DBUILD}"
}

main() {
    set -euo pipefail 
    load_common_files_and_prepare_environment
    prepare_package_environment
    prepare_managment_scripts_and_files
    build_package
}

main
