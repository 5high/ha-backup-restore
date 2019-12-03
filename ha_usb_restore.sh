#!/bin/bash
log() {
        if [ "${DEBUG}" == "true" ] || [ "${1}" != "d" ]; then
                echo "[${1}] ${2}"
                if [ "${3}" != "" ]; then
                        exit ${3}
                fi
        fi
}
sudo systemctl stop hass
if [ -b /dev/sda1 ]; then
	sudo mount /dev/sda1 /media
else
	sudo mount /dev/sdb1 /media
fi
BACKUP_FOLDER=/media/hassbackup/
BACKUP_LOCATION=$HOME/.homeassistant
if [ -d "${BACKUP_FOLDER}" ]; then
	if [ ! -d "${BACKUP_LOCATION}" ]; then
                log e "Homeassistant folder not found, is it correct?" 1
	else
	        sudo apt-get install zip -y
		cd ${BACKUP_LOCATION}
		#sudo rm -rf .cloud/ custom_components/ home-assistant* *.yaml *.conf .homekit.state .storage/
		unzip -o ${BACKUP_FOLDER}/hass-config.zip -d ${BACKUP_LOCATION}
		sudo systemctl restart hass
		sudo umount /media
        fi
else
        log e "Backup folder not found, is your USB drive mounted?" 1
fi
