#!/bin/bash
set -euo pipefail

readonly PACKAGE="aktin-notaufnahme-i2b2"

if [ -z "${VERSION}" ]; then 
    readonly VERSION="${1:-}"
    if [ -z "${VERSION}" ]; then 
        echo "\$VERSION is empty."
        exit 1
    fi
fi

readonly DIR_CURRENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly DIR_BUILD="${DIR_CURRENT}/build/${PACKAGE}_${VERSION}"

function load_common_files_and_prepare_environment() {
    . "$(dirname "${DIR_CURRENT}")/common/build.sh"
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
    mkdir -p "${DIR_BUILD}/DEBIAN"
    sed -e "s/__PACKAGE__/${PACKAGE}/g" -e "s/__VERSION__/${VERSION}/g" "${DIR_CURRENT}/control" > "${DIR_BUILD}/DEBIAN/control"
    cp "${DIR_CURRENT}/config" "${DIR_BUILD}/DEBIAN/"
    cp "${DIR_CURRENT}/postinst" "${DIR_BUILD}/DEBIAN/"
    cp "${DIR_CURRENT}/prerm" "${DIR_BUILD}/DEBIAN/"
    sed -e "/^__I2B2_DROP__/{r ${DIR_RESOURCES}/database/i2b2_postgres_drop.sql" -e 'd;}' "${DIR_CURRENT}/postrm" > "${DIR_BUILD}/DEBIAN/postrm" && chmod 0755 "${DIR_BUILD}/DEBIAN/postrm"
}

function build_package() {
    dpkg-deb --build "${DIR_BUILD}"
    rm -rf "${DIR_BUILD}"
}

main() {
    set -euo pipefail 
    load_common_files_and_prepare_environment
    prepare_package_environment
    prepare_managment_scripts_and_files
    build_package
}

main
