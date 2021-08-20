#! /bin/bash

set -euo pipefail

readonly RES='\e[0m'
readonly RED='\e[0;31m'
readonly GRE='\e[0;32m'

if ! systemctl is-active --quiet postgresql; then
	echo "Starting postgresql"
	service postgresql start
fi

if ! systemctl is-active --quiet wildfly; then
	echo "Starting wildfly"
	service wildfly start
	sleep 10s
fi

echo "Stopping postgresql"
service postgresql stop
sleep 5s
if ! systemctl is-active --quiet postgresql; then
	echo -e "${GRE}postgresql is stopped${RES}"
else
	echo -e "${RED}postgresql is not stopped${RES}"
fi
if ! systemctl is-active --quiet wildfly; then
	echo -e "${GRE}wildfly is stopped${RES}"
else
	echo -e "${RED}wildfly is not stopped${RES}"
fi

echo "Starting widlfly"
service wildfly start
sleep 5s
if systemctl is-active --quiet wildfly; then
	echo -e "${GRE}wildfly is started${RES}"
else
	echo -e "${RED}wildfly is not started${RES}"
fi
if systemctl is-active --quiet postgresql; then
	echo -e "${GRE}postgresql is started${RES}"
else
	echo -e "${RED}postgresql is not started${RES}"
fi