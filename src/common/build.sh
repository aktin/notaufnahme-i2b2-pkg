#!/bin/bash
set -euo pipefail

# Check if variables are empty
if [ -z "${PACKAGE}" ]; then echo "\$PACKAGE is empty."; exit 1; fi
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi
if [ -z "${DBUILD}" ]; then echo "\$DBUILD is empty."; exit 1; fi

# Superdirectory this script is located in + /resources
DRESOURCES="$( cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" &> /dev/null && pwd )/resources"

set -a
. "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/versions"
set +a

mkdir -p "${DBUILD}"

function download_i2b2_webclient() {
	DWEBCLIENT="${1}"

	wget "https://github.com/i2b2/i2b2-webclient/archive/v${VI2B2_WEBCLIENT}.zip" -P "${DBUILD}"
	unzip "${DBUILD}/v${VI2B2_WEBCLIENT}.zip" -d "${DBUILD}"
	rm "${DBUILD}/v${VI2B2_WEBCLIENT}.zip"
	mkdir -p "$(dirname "${DBUILD}${DWEBCLIENT}")"
	mv "${DBUILD}/i2b2-webclient-${VI2B2_WEBCLIENT}" "${DBUILD}${DWEBCLIENT}"
}

function config_i2b2_webclient() {
	DWEBCLIENT="${1}"

	sed -i 's|name: \"HarvardDemo\",|name: \"AKTIN\",|' "${DBUILD}${DWEBCLIENT}/i2b2_config_data.js"
	sed -i 's|urlCellPM: \"http://services.i2b2.org/i2b2/services/PMService/\",|urlCellPM: \"http://127.0.0.1:9090/i2b2/services/PMService/\",|' "${DBUILD}${DWEBCLIENT}/i2b2_config_data.js"
	sed -i 's|loginDefaultUsername : \"demo\"|loginDefaultUsername : \"\"|' "${DBUILD}${DWEBCLIENT}/js-i2b2/i2b2_ui_config.js"
	sed -i 's|loginDefaultPassword : \"demouser\"|loginDefaultPassword : \"\"|' "${DBUILD}${DWEBCLIENT}/js-i2b2/i2b2_ui_config.js"
}

function download_wildfly() {
	DWILDFLYHOME="$1"

	wget "https://download.jboss.org/wildfly/${VWILDFLY}/wildfly-${VWILDFLY}.zip" -P "${DBUILD}"
	unzip "${DBUILD}/wildfly-${VWILDFLY}.zip" -d "${DBUILD}"
	rm "${DBUILD}/wildfly-${VWILDFLY}.zip"
	mkdir -p "$(dirname "${DBUILD}${DWILDFLYHOME}")"
	mv "${DBUILD}/wildfly-${VWILDFLY}" "${DBUILD}${DWILDFLYHOME}"
}

function init_wildfly_systemd() {
	DWILDFLYHOME="$1"
	DWILDFLYCONFIG="$2"
	DSYSTEMD="$3"

	mkdir -p "${DBUILD}${DWILDFLYCONFIG}" "${DBUILD}${DSYSTEMD}"
	cp "${DBUILD}${DWILDFLYHOME}/docs/contrib/scripts/systemd/wildfly.service" "${DBUILD}${DSYSTEMD}/"
	cp "${DBUILD}${DWILDFLYHOME}/docs/contrib/scripts/systemd/wildfly.conf" "${DBUILD}${DWILDFLYCONFIG}/"

	echo "JBOSS_HOME=\"${DWILDFLYHOME}\"" >> "${DBUILD}${DWILDFLYCONFIG}/wildfly.conf"

	cp "${DBUILD}${DWILDFLYHOME}/docs/contrib/scripts/systemd/launch.sh" "${DBUILD}${DWILDFLYHOME}/bin/"
}

function config_wildfly() {
	DWILDFLYHOME="$1"

	# increases JVM heap size
	sed -i 's/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/' "${DBUILD}${DWILDFLYHOME}/bin/appclient.conf"
	sed -i 's/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/' "${DBUILD}${DWILDFLYHOME}/bin/standalone.conf"

	# fix CVE-2021-44228 (log4j2 vulnerability)
	echo 'JAVA_OPTS="$JAVA_OPTS -Dlog4j2.formatMsgNoLookups=true"' >> "${DBUILD}${DWILDFLYHOME}/bin/standalone.conf"

	patch -p1 -d "${DBUILD}${DWILDFLYHOME}" < "${DRESOURCES}/standalone.xml.patch"
}

function download_wildfly_jdbc() {
	DWILDFLYDEPLOYMENTS="$1"

	wget "https://jdbc.postgresql.org/download/postgresql-${VPOSTGRES_JDBC}.jar" -P "${DBUILD}${DWILDFLYDEPLOYMENTS}"
}

function download_wildfly_i2b2() {
	DWILDFLYDEPLOYMENTS="$1"

	# TODO load i2b2 from official sources
	wget "https://www.aktin.org/software/repo/org/i2b2/${VI2B2}/i2b2.war" -P "${DBUILD}${DWILDFLYDEPLOYMENTS}"
}

function copy_database_for_postinstall() {
	DDBPOSTINSTALL="$1"

	mkdir -p "$(dirname "${DBUILD}${DDBPOSTINSTALL}")"
	cp -r "${DRESOURCES}/database" "${DBUILD}${DDBPOSTINSTALL}"
}

function copy_datasource_for_postinstall() {
	DDSPOSTINSTALL="$1"

	mkdir -p "$(dirname "${DBUILD}${DDSPOSTINSTALL}")"
	cp -r "${DRESOURCES}/datasource" "${DBUILD}${DDSPOSTINSTALL}"
}

function copy_helper_functions_for_postinstall() {
	DHELPERPOSTINSTALL="$1"

	mkdir -p "$(dirname "${DBUILD}${DHELPERPOSTINSTALL}")"
	cp "${DRESOURCES}/helper.sh" "${DBUILD}${DHELPERPOSTINSTALL}"
}

function build_linux() {
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
