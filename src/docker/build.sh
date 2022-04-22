#!/bin/bash
set -euo pipefail

readonly PACKAGE="aktin-notaufnahme-i2b2"

readonly VERSION="${1:-}"
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# Optional parameter
readonly FULL="${2:-}"

readonly DCURRENT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly DBUILD="${DCURRENT}/build"

function load_common_files_and_prepare_environment() {
    . "$(dirname "${DCURRENT}")/common/build.sh"
    clean_up_build_environment
    init_build_environment   
}

function load_docker_environment_variables() { 
	export $(cat ${DCURRENT}/.env | xargs)
}

function prepare_wildfly_docker() {
	mkdir -p "${DBUILD}/wildfly"
	sed -e "s/__VWILDFLY__/${VWILDFLY}/g" "${DCURRENT}/wildfly/Dockerfile" > "${DBUILD}/wildfly/Dockerfile"
	cp "${DCURRENT}/wildfly/entrypoint.sh" "${DBUILD}/wildfly/"
	cp "${DRESOURCES}/standalone.xml.patch" "${DBUILD}/wildfly/"
	download_wildfly_jdbc "/wildfly"
	download_wildfly_i2b2 "/wildfly"
	copy_datasource_for_postinstall "/wildfly/ds"
}

function prepare_postgresql_docker() {
	mkdir -p "${DBUILD}/database"
	cp "${DCURRENT}/database/Dockerfile" "${DBUILD}/database/"
	copy_database_for_postinstall "/database/sql"
}

function prepare_apache2_docker() {
	mkdir -p "${DBUILD}/httpd"
	cp "${DCURRENT}/httpd/Dockerfile" "${DBUILD}/httpd/"
	download_i2b2_webclient "/httpd/i2b2webclient"
	config_i2b2_webclient "/httpd/i2b2webclient"
}

function clean_up_old_docker_images() {
	LIST_IMAGES=( "${I2B2IMAGENAMESPACE}database" "${I2B2IMAGENAMESPACE}wildfly" "${I2B2IMAGENAMESPACE}httpd" )
	for IMAGE in "${LIST_IMAGES[*]}"; do
		# Stop and remove running container if exists
  		ID_CONTAINER="$(docker ps -q -f ancestor="${IMAGE}:latest")"
		if [ -n "${ID_CONTAINER}" ]; then
			docker stop "${ID_CONTAINER}" || true
			docker rm "${ID_CONTAINER}" || true
		fi
		# Remove image
		ID_IMAGE="$(docker images -q "${IMAGE}:latest")"
		if [ -n "${ID_IMAGE}" ]; then
			docker image rm "${ID_IMAGE}" || true
		fi
	done
}

function build_docker_images() {
	cwd="$(pwd)"
	cd "${DCURRENT}"
	docker-compose build
	cd "${cwd}"
}

main() {
    set -euo pipefail
	load_common_files_and_prepare_environment
	load_docker_environment_variables
	prepare_wildfly_docker
	prepare_postgresql_docker
	prepare_apache2_docker
	if [ "${FULL}" = "full" ]; then
		clean_up_old_docker_images
		build_docker_images
	fi
}

main
