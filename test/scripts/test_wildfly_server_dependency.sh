#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly YEL="\e[1;33m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

if ! systemctl is-active --quiet postgresql; then
    systemctl start postgresql
    sleep 5s
fi

if ! systemctl is-active --quiet wildfly; then
    systemctl start wildfly
    sleep 5s
fi

# stop postgresql and check if wildfly is also stopped
echo -e "${YEL} - stopping postgresql service${WHI}"
systemctl stop postgresql
sleep 5s
if ! systemctl is-active --quiet postgresql; then
    echo -e "${GRE} - postgresql is stopped${WHI}"
else
    echo -e "${RED} - postgresql is not stopped${WHI}"
    exit 1
fi
if ! systemctl is-active --quiet wildfly; then
    echo -e "${GRE} - wildfly is stopped${WHI}"
else
    echo -e "${RED} - wildfly is not stopped${WHI}"
    exit 1
fi

# start wildfly and check if postgresql is also started
echo -e "${YEL} - starting widlfly service${WHI}"
systemctl start wildfly
sleep 5s
if systemctl is-active --quiet wildfly; then
    echo -e "${GRE} - wildfly is started${WHI}"
else
    echo -e "${RED} - wildfly is not started${WHI}"
    exit 1
fi
if systemctl is-active --quiet postgresql; then
    echo -e "${GRE} - postgresql is started${WHI}"
else
    echo -e "${RED} - postgresql is not started${WHI}"
    exit 1
fi
