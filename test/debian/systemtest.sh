#! /bin/bash
set -euo pipefail

readonly WHI="\033[0m"
readonly YEL="\e[1;33m"
readonly RED="\e[1;31m"
readonly GRE="\e[0;32m"

readonly DIR_WORKING="$(dirname "$(readlink -fm "${0}")")"

readonly DIR_ROOT="$(dirname "$(dirname "$(dirname "$(readlink -fm "${0}")")")")"
readonly DIR_DEBIAN="${DIR_ROOT}/src/debian"
readonly DIR_COMMON="${DIR_ROOT}/src/common"
readonly DIR_RESOURCES="${DIR_ROOT}/src/resources"
readonly DIR_TESTRESOURCES="${DIR_ROOT}/test/resources"
readonly DIR_TESTSCRIPTS="${DIR_ROOT}/test/scripts"

function init_testing_environment() {
    cp -r "${DIR_DEBIAN}" "${DIR_WORKING}"
    cp -r "${DIR_COMMON}" "${DIR_WORKING}"
    cp -r "${DIR_RESOURCES}" "${DIR_WORKING}"
    mkdir -p "${DIR_WORKING}/test"
    cp -r "${DIR_TESTRESOURCES}" "${DIR_WORKING}/test"
    cp -r "${DIR_TESTSCRIPTS}" "${DIR_WORKING}/test"
}

function clean_up_testing_environment() {
    rm -rf "${DIR_WORKING}/debian"
    rm -rf "${DIR_WORKING}/common"
    rm -rf "${DIR_WORKING}/resources"
    rm -rf "${DIR_WORKING}/test"
}

function build_docker_image() {
    echo -e "${YEL}Building debian packages on docker container ...${WHI}"
    docker-compose -f "${DIR_WORKING}/docker-compose.yml" up -d --force-recreate --build
}

function clean_up_docker_image() {
    echo -e "${YEL}Removing docker instance ...${WHI}"
    docker stop testcontainer
    docker rm testcontainer
    docker image rm testimage
}

function install_debian_package() {
    echo -e "${YEL}Installing package ...${WHI}"
    docker exec testcontainer apt install -y ./debian/build/aktin-notaufnahme-i2b2_000.deb
}

function check_package_installation() {
    echo -e "${YEL}Checking package installation ...${WHI}"
    if [[ -z $(docker exec testcontainer dpkg -l | grep aktin-notaufnahme-i2b2) ]]; then
        echo -e "${RED} - package is not installed${WHI}"
        exit 1
    else
        echo -e "${GRE} - packages is installed${WHI}"
    fi
}

function check_service_status() {
    echo -e "${YEL}Checking package services ...${WHI}"
    docker exec testcontainer ./test/scripts/test_systemd_services.sh
}

function check_php_curl_extension() {
    echo -e "${YEL}Checking php curl extension ...${WHI}"
    docker exec testcontainer ./test/scripts/test_php_curl_extension.sh
}

function check_i2b2_webclient_config() {
    echo -e "${YEL}Checking configuration of i2b2 webclient ...${WHI}"
    docker exec testcontainer ./test/scripts/test_i2b2_webclient_config.sh
}

function check_i2b2_webclient_login() {
    echo -e "${YEL}Checking login into i2b2 webclient ...${WHI}"
    docker exec testcontainer ./test/scripts/test_i2b2_webclient_login.sh
}

function check_wildfly_service_dependency() {
    echo -e "${YEL}Checking service dependency between wildfly and postgres ...${WHI}"
    docker exec testcontainer ./test/scripts/test_wildfly_server_dependency.sh
}

function check_wildfly_user_and_group() {
    echo -e "${YEL}Checking existence of user and group wildfly ...${WHI}"
    docker exec testcontainer ./test/scripts/test_wildfly_user_group.sh
}

function check_wildfly_config() {
    echo -e "${YEL}Checking configuration of wildfly ...${WHI}"
    docker exec testcontainer ./test/scripts/test_wildfly_config.sh
}

function check_wildfly_deployments() {
    echo -e "${YEL}Checking wildfly deployments ...${WHI}"
    docker exec testcontainer ./test/scripts/test_wildfly_deployments.sh
}

# function disable_psql_updates() {
#    # stop updates for postgresql-12. Keep this method until new cda-importer is finished
#    if grep -q "Package: postgresql-12" /etc/apt/preferences.d/official-package-repositories.pref; then
#        echo -e "Unattendend-upgrades for postgresql-12 already disabled"
#    else
#        echo -e "Disabling postgresql-12 unattendend-upgrades ..."
#        cat <<EOF >>"/etc/apt/preferences.d/official-package-repositories.pref"
#Package: postgresql-12 postgresql-client-12 postgresql-common postgresql-client-common
#Pin: release o=Ubuntu
#Pin-Priority: -1
#EOF
#    fi
#}

function check_postgres_import() {
    echo -e "${YEL}Importing data into postgres and checking content ...${WHI}"
    docker exec testcontainer ./test/scripts/test_psql_demo_data.sh
}

# test update

# test remove package

function main() {
    #init_testing_environment
    #build_docker_image
    #install_debian_package
    #check_package_installation
    #check_service_status
    #check_php_curl_extension
    #check_i2b2_webclient_config
    #check_i2b2_webclient_login
    #check_wildfly_service_dependency
    #check_wildfly_user_and_group
    #check_wildfly_config
    #check_wildfly_deployments

    clean_up_testing_environment
    #clean_up_docker_image
}

main
