#! /bin/bash

set -euo pipefail

readonly WHI='\033[0m'
readonly YEL='\e[1;33m'
readonly RED='\e[1;31m'

readonly DIR_WORKING="$(dirname $(readlink -fm $0))"
readonly DIR_ROOT=$(dirname $(dirname $(dirname $(readlink -fm $0))))
readonly DIR_DEBIAN="$DIR_ROOT/src/debian"
readonly DIR_COMMON="$DIR_ROOT/src/common"
readonly DIR_RESOURCES="$DIR_ROOT/src/resources"
readonly DIR_TESTFILES="$DIR_ROOT/test/common"

cp -r $DIR_DEBIAN $DIR_WORKING
cp -r $DIR_COMMON $DIR_WORKING
cp -r $DIR_RESOURCES $DIR_WORKING
mkdir -p $DIR_WORKING/test
cp -rf $DIR_TESTFILES/* $DIR_WORKING/test

#echo -e "${YEL}Building container via docker-compose ...${WHI}"
#docker-compose -f $DIR_WORKING/docker-compose.yml up -d --force-recreate --build

#echo -e "${YEL}Installing package ...${WHI}"
#docker exec testcontainer apt install -y ./debian/build/aktin-notaufnahme-i2b2_000.deb

echo -e "${YEL}Checking package installation ...${WHI}"
#if [[ -z $(docker exec testcontainer dpkg -l | grep aktin-notaufnahme-i2b2) ]]; then
#    echo -e "${RED}Package is not installed${WHI}"
#    exit 1
#fi

# ADD exit 1
echo -e "${YEL}Checking package service status ...${WHI}"
#docker exec testcontainer systemctl is-active --quiet apache2 || echo echo -e "${RED}apache2 is not running${WHI}"
#docker exec testcontainer systemctl is-active --quiet wildfly || echo echo -e "${RED}wildfly is not running${WHI}"
#docker exec testcontainer systemctl is-active --quiet postgresql || echo echo -e "${RED}postgresql is not running${WHI}"

echo -e "${YEL}Checking service dependency between wildfly and postgres ...${WHI}"
#docker exec testcontainer ./test/test_wildfly_server_dependency.sh


# load demo data on i2b2

# test i2b2 query


echo -e "${YEL}Removing docker instance ...${WHI}"
#docker stop testcontainer
#docker rm testcontainer
#docker image rm testimage

echo -e "${YEL}Removing tmp folder ...${WHI}"
rm -rf $DIR_WORKING/debian
rm -rf $DIR_WORKING/common
rm -rf $DIR_WORKING/resources
rm -rf $DIR_WORKING/test
