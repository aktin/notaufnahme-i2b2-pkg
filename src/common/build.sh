#!/bin/bash
set -euo pipefail

# Check if variables are empty
if [ -z "${PACKAGE}" ]; then
    echo "\$PACKAGE is empty."
    exit 1
fi
if [ -z "${VERSION}" ]; then
    echo "\$VERSION is empty."
    exit 1
fi
if [ -z "${DIR_BUILD}" ]; then
    echo "\$DIR_BUILD is empty."
    exit 1
fi

# Superdirectory this script is located in + /resources, namely src/resources
readonly DIR_RESOURCES="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" &>/dev/null && pwd)/resources"

function init_build_environment() {
    set -a
    . "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/versions"
    set +a
    mkdir -p "${DIR_BUILD}"
}

function clean_up_build_environment() {
    rm -rf "${DIR_BUILD}"
}

function download_i2b2_webclient() {
    local DIR_WEBCLIENT="${1}"

    wget "https://github.com/i2b2/i2b2-webclient/archive/v${VERSION_I2B2_WEBCLIENT}.zip" -P "${DIR_BUILD}"
    unzip "${DIR_BUILD}/v${VERSION_I2B2_WEBCLIENT}.zip" -d "${DIR_BUILD}"
    rm "${DIR_BUILD}/v${VERSION_I2B2_WEBCLIENT}.zip"
    mkdir -p "$(dirname "${DIR_BUILD}${DIR_WEBCLIENT}")"
    mv "${DIR_BUILD}/i2b2-webclient-${VERSION_I2B2_WEBCLIENT}" "${DIR_BUILD}${DIR_WEBCLIENT}"
}

function config_i2b2_webclient() {
    local DIR_WEBCLIENT="${1}"

    sed -i "s|name: \"HarvardDemo\",|name: \"AKTIN\",|" "${DIR_BUILD}${DIR_WEBCLIENT}/i2b2_config_data.js"
    sed -i "s|urlCellPM: \"http://services.i2b2.org/i2b2/services/PMService/\",|urlCellPM: \"http://127.0.0.1:9090/i2b2/services/PMService/\",|" "${DIR_BUILD}${DIR_WEBCLIENT}/i2b2_config_data.js"
    sed -i "s|loginDefaultUsername : \"demo\"|loginDefaultUsername : \"\"|" "${DIR_BUILD}${DIR_WEBCLIENT}/js-i2b2/i2b2_ui_config.js"
    sed -i "s|loginDefaultPassword : \"demouser\"|loginDefaultPassword : \"\"|" "${DIR_BUILD}${DIR_WEBCLIENT}/js-i2b2/i2b2_ui_config.js"
}

function download_wildfly() {
    local DIR_WILDFLY_HOME="${1}"

    wget "https://download.jboss.org/wildfly/${VERSION_WILDFLY}/wildfly-${VERSION_WILDFLY}.zip" -P "${DIR_BUILD}"
    unzip "${DIR_BUILD}/wildfly-${VERSION_WILDFLY}.zip" -d "${DIR_BUILD}"
    rm "${DIR_BUILD}/wildfly-${VERSION_WILDFLY}.zip"
    mkdir -p "$(dirname "${DIR_BUILD}${DIR_WILDFLY_HOME}")"
    mv "${DIR_BUILD}/wildfly-${VERSION_WILDFLY}" "${DIR_BUILD}${DIR_WILDFLY_HOME}"
}

function init_wildfly_systemd() {
    local DIR_WILDFLY_HOME="${1}"
    local DIR_WILDFLY_CONFIG="${2}"
    local DIR_SYSTEMD="${3}"

    mkdir -p "${DIR_BUILD}${DIR_WILDFLY_CONFIG}" "${DIR_BUILD}${DIR_SYSTEMD}"
    cp "${DIR_BUILD}${DIR_WILDFLY_HOME}/docs/contrib/scripts/systemd/wildfly.service" "${DIR_BUILD}${DIR_SYSTEMD}/"
    cp "${DIR_BUILD}${DIR_WILDFLY_HOME}/docs/contrib/scripts/systemd/wildfly.conf" "${DIR_BUILD}${DIR_WILDFLY_CONFIG}/"

    echo "JBOSS_HOME=\"${DIR_WILDFLY_HOME}\"" >>"${DIR_BUILD}${DIR_WILDFLY_CONFIG}/wildfly.conf"

    cp "${DIR_BUILD}${DIR_WILDFLY_HOME}/docs/contrib/scripts/systemd/launch.sh" "${DIR_BUILD}${DIR_WILDFLY_HOME}/bin/"
}

function config_wildfly() {
    local DIR_WILDFLY_HOME="${1}"

    # increases JVM heap size
    sed -i "s/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/" "${DIR_BUILD}${DIR_WILDFLY_HOME}/bin/appclient.conf"
    sed -i "s/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/" "${DIR_BUILD}${DIR_WILDFLY_HOME}/bin/standalone.conf"

    # fix CVE-2021-44228 (log4j2 vulnerability)
    echo "JAVA_OPTS=\"\$JAVA_OPTS -Dlog4j2.formatMsgNoLookups=true\"" >>"${DIR_BUILD}${DIR_WILDFLY_HOME}/bin/standalone.conf"

    patch -p1 -d "${DIR_BUILD}${DIR_WILDFLY_HOME}" <"${DIR_RESOURCES}/standalone.xml.patch"
}

function download_wildfly_jdbc() {
    local DIR_WILDFLY_DEPLOYMENTS="${1}"

    wget "https://jdbc.postgresql.org/download/postgresql-${VERSION_POSTGRES_JDBC}.jar" -P "${DIR_BUILD}${DIR_WILDFLY_DEPLOYMENTS}"
}

function download_wildfly_i2b2() {
    local DIR_WILDFLY_DEPLOYMENTS="${1}"

    # TODO load i2b2 from official sources
    wget "https://www.aktin.org/software/repo/org/i2b2/${VERSION_I2B2}/i2b2.war" -P "${DIR_BUILD}${DIR_WILDFLY_DEPLOYMENTS}"
}

function copy_database_for_postinstall() {
    local DIR_DB_POSTINSTALL="${1}"

    mkdir -p "$(dirname "${DIR_BUILD}${DIR_DB_POSTINSTALL}")"
    cp -r "${DIR_RESOURCES}/database" "${DIR_BUILD}${DIR_DB_POSTINSTALL}"
}

function copy_datasource_for_postinstall() {
    local DIR_DS_POSTINSTALL="${1}"

    mkdir -p "$(dirname "${DIR_BUILD}${DIR_DS_POSTINSTALL}")"
    cp -r "${DIR_RESOURCES}/datasource" "${DIR_BUILD}${DIR_DS_POSTINSTALL}"
}

function copy_helper_functions_for_postinstall() {
    local DIR_HELPER_POSTINSTALL="${1}"

    mkdir -p "$(dirname "${DIR_BUILD}${DIR_HELPER_POSTINSTALL}")"
    cp "${DIR_RESOURCES}/helper.sh" "${DIR_BUILD}${DIR_HELPER_POSTINSTALL}"
}
