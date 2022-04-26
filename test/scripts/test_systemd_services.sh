#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

readonly LIST_SERVICES=(postgresql wildfly apache2)

# check if all services are running
for SERVICE in "${LIST_SERVICES[@]}"; do
    STATUS="$(systemctl show -p ActiveState --value ${SERVICE})"
    if [ "${STATUS}" != "active" ]; then
        echo -e "${RED}${SERVICE} is not running${WHI}"
        exit 1
    fi
done
echo -e "${GRE} - all services are running${WHI}"

# check if all services are enabled
for SERVICE in "${LIST_SERVICES[@]}"; do
    STATUS="$(systemctl is-enabled ${SERVICE})"
    if [ "${STATUS}" != "enabled" ]; then
        echo -e "${RED}${SERVICE} is not enabled${WHI}"
        exit 1
    fi
done
echo -e "${GRE} - all services are enabled${WHI}"
