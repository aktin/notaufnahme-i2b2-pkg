#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

if [[ -z $(grep "wildfly" /etc/passwd) ]]; then
    echo -e "${RED} - user wildfly does not exist${WHI}"
    exit 1
fi

if [[ -z $(grep "wildfly" /etc/group) ]]; then
    echo -e "${RED} - group wildfly does not exist${WHI}"
    exit 1
fi

echo -e "${GRE} - user and group wildfly exists${WHI}"
