#!/bin/bash

# Set your paths below. Script can be run from any folder as long as your the right user and the drive is mounted.
# You can either include or exclude the database, incase you have mysql or simply don't want to backup a big file.
# Do check the storage on your drive.

if [ -b /dev/sda1 ]; then
	sudo mount /dev/sda1 /media
else
	sudo mount /dev/sdb1 /media
fi
sudo chmod -R 777 /media/
sudo mkdir /media/hassbackup
sudo chmod -R 777 /media/hassbackup/
sudo apt-get install zip -y
BACKUP_FOLDER=/media/hassbackup/
BACKUP_FILE=${BACKUP_FOLDER}hass-config_$(date +"%Y%m%d_%H%M%S").zip
BACKUP_FILE1=${BACKUP_FOLDER}hass-config.zip
BACKUP_LOCATION=$HOME/.homeassistant
INCLUDE_DB=false
DAYSTOKEEP=0 # Set to 0 to keep it forever.

log() {
        if [ "${DEBUG}" == "true" ] || [ "${1}" != "d" ]; then
                echo "[${1}] ${2}"
                if [ "${3}" != "" ]; then
                        exit ${3}
                fi
        fi
}

if [ -d "${BACKUP_FOLDER}" ]; then
        if [ ! -d "${BACKUP_LOCATION}" ]; then
                log e "Homeassistant folder not found, is it correct?" 1
        fi
        pushd ${BACKUP_LOCATION} >/dev/null
        if [ "${INCLUDE_DB}" = true ] ; then
                log i "Creating backup with database"
                sudo zip -9 -q -r ${BACKUP_FILE} . -x"components/*" -x"deps/*" -x"home-assistant.log"
		sudo zip -9 -q -r ${BACKUP_FILE1} . -x"components/*" -x"deps/*" -x"home-assistant.log"
        else
                log i "Creating backup"
                sudo zip -9 -q -r ${BACKUP_FILE} . -x"components/*" -x"deps/*" -x"home-assistant.db" -x"home-assistant_v2.db" -x"home-assistant.log"
		sudo zip -9 -q -r ${BACKUP_FILE1} . -x"components/*" -x"deps/*" -x"home-assistant.db" -x"home-assistant_v2.db" -x"home-assistant.log"
        fi

        popd >/dev/null

        log i "Backup complete: ${BACKUP_FILE}"
        if [ "${DAYSTOKEEP}" = 0 ] ; then
                log i "Keeping all files no prunning set"
        else
                log i "Deleting backups older then ${DAYSTOKEEP} day(s)"
                OLDFILES=$(find ${BACKUP_FOLDER} -mindepth 1 -mtime +${DAYSTOKEEP} -delete -print)
                if [ ! -z "${OLDFILES}" ] ; then
                        log i "Found the following old files:"
                        echo "${OLDFILES}"
                fi
        fi
else
        log e "Backup folder not found, is your USB drive mounted?" 1
fi
sudo umount /media
