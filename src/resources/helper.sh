#!/bin/bash

# only for keys within [UNIT]
function add_entry_to_service() {
    set -euo pipefail
	local DIR_SERVICE="/lib/systemd/system/${1}"
	local KEY="${2}"
	local VALUE="${3}"
    # workaround as grep returns null if key not found which leads to an error
    if grep -q "^${KEY}=" "${DIR_SERVICE}";
    then
        LINE="$(grep "^${KEY}=" "${DIR_SERVICE}")"
		if [[ "${LINE}" != *"${VALUE}"* ]];
		then
			LINE+=" ${VALUE}"
			sed -i "s/^${KEY}=.*/${LINE}/" "${DIR_SERVICE}";
		fi
	else
		sed -ri "/^\[Unit\]$/a ${KEY}=${VALUE}" "${DIR_SERVICE}";
	fi
}

# only for keys within [UNIT]
function remove_entry_from_service() {
    set -euo pipefail
	local DIR_SERVICE="/lib/systemd/system/${1}"
	local KEY="${2}"
	local VALUE="${3}"
    # workaround as grep returns null if key not found which leads to an error
    if grep -q "^${KEY}=" "${DIR_SERVICE}";
    then
        LINE=$(grep "^${KEY}=" "${DIR_SERVICE}")
        if [[ "${LINE}" == *"${VALUE}"* ]];
        then
            LINE="$(echo ${LINE} | sed -e "s/${VALUE}//")"
            if [[ -z "$(cut -d'=' -f2 <<< ${LINE})" ]];
            then
                sed -i "/^${KEY}=.*/d" "${DIR_SERVICE}";
            else
                sed -i "s/^${KEY}=.*/${LINE}/" "${DIR_SERVICE}";
            fi
        fi
    fi
}
