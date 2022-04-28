#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

DIR_WILDFLY_DEPLOYMENTS="/opt/wildfly/standalone/deployments"

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2hive</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/crc-ds.xml") ]]; then
    echo -e "${RED} - crc-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2crcdata</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/crc-ds.xml") ]]; then
    echo -e "${RED} - crc-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2hive</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/im-ds.xml") ]]; then
    echo -e "${RED} - im-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2imdata</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/im-ds.xml") ]]; then
    echo -e "${RED} - im-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2hive</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/ont-ds.xml") ]]; then
    echo -e "${RED} - ont-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2metadata</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/ont-ds.xml") ]]; then
    echo -e "${RED} - ont-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2pm</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/pm-ds.xml") ]]; then
    echo -e "${RED} - pm-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2hive</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/work-ds.xml") ]]; then
    echo -e "${RED} - work-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<connection-url>jdbc:postgresql://localhost:5432/i2b2?searchPath=i2b2workdata</connection-url>" "${DIR_WILDFLY_DEPLOYMENTS}/work-ds.xml") ]]; then
    echo -e "${RED} - work-ds.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -f "${DIR_WILDFLY_DEPLOYMENTS}/i2b2.war" ]]; then
    echo -e "${RED} - i2b2.war does not exist${WHI}"
    exit 1
fi

if [[ -f "${DIR_WILDFLY_DEPLOYMENTS}/postgresql-42.2.8.jar" ]]; then
    echo -e "${RED} - postgresql.jar does not exist${WHI}"
    exit 1
fi

echo -e "${GRE} - all wildfly deployments are set accordingly${WHI}"
