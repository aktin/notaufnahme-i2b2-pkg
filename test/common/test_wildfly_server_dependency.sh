#! /bin/bash

set -euo pipefail

readonly WHI='\e[0m'
readonly YEL='\e[1;33m'
readonly RED='\e[0;31m'
readonly GRE='\e[0;32m'

if ! systemctl is-active --quiet postgresql; then
	systemctl start postgresql
	sleep 5s
fi

if ! systemctl is-active --quiet wildfly; then
	systemctl start wildfly
	sleep 5s
fi

echo -e "${YEL}Stopping postgresql service${WHI}"
systemctl stop postgresql
sleep 5s
if ! systemctl is-active --quiet postgresql; then
	echo -e "${GRE}postgresql is stopped${WHI}"
else
	echo -e "${RED}postgresql is not stopped${WHI}"
	exit 1
fi
if ! systemctl is-active --quiet wildfly; then
	echo -e "${GRE}wildfly is stopped${WHI}"
else
	echo -e "${RED}wildfly is not stopped${WHI}"
	exit 1
fi

echo "${YEL}Starting widlfly service${WHI}"
systemctl start wildfly
sleep 5s
if systemctl is-active --quiet wildfly; then
	echo -e "${GRE}wildfly is started${WHI}"
else
	echo -e "${RED}wildfly is not started${WHI}"
	exit 1
fi
if systemctl is-active --quiet postgresql; then
	echo -e "${GRE}postgresql is started${WHI}"
else
	echo -e "${RED}postgresql is not started${WHI}"
	exit 1
fi
