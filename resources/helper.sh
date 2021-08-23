#!/bin/bash

# only for keys within [UNIT]
function add_entry_to_service() {
	SERVICE=/lib/systemd/system/$1
	KEY=$2
	VALUE=$3
    # workaround as grep returns null if key not found which leads to an error
    if grep -q "^$KEY=" $SERVICE;
    then
        line=$(grep "^$KEY=" $SERVICE)
		if [[ $line != *"$VALUE"* ]];
		then
			line+=" $VALUE"
			sed -i "s/^$KEY=.*/$line/" $SERVICE;
		fi
	else
		sed -ri "/^\[Unit\]$/a $KEY=$VALUE" $SERVICE;
	fi
}

# only for keys within [UNIT]
function remove_entry_from_service() {
    SERVICE=/lib/systemd/system/$1
    KEY=$2
    VALUE=$3
    # workaround as grep returns null if key not found which leads to an error
    if grep -q "^$KEY=" $SERVICE;
    then
        line=$(grep "^$KEY=" $SERVICE)
        if [[ $line == *"$VALUE"* ]];
        then
            line=$(echo $line | sed -e "s/$VALUE//")
            if [[ -z $(cut -d'=' -f2 <<< $line) ]];
            then
                sed -i "/^$KEY=.*/d" $SERVICE;
            else
                sed -i "s/^$KEY=.*/$line/" $SERVICE;
            fi
        fi
    fi
}