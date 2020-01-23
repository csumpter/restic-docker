#!/bin/bash
set -e
# credit: some of the code for this script inspired by https://github.com/lobaro/restic-backup-docker

logFile="/var/log/restic/backup/$(date +"%Y-%m-%d-%H-%M-%S").log"

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a "$logFile"
}

showTime() {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    time="${day}d ${hour}h ${min}m ${sec}s"
    log "[INFO] Total backup time: ${time}"
}

start=$(date +%s)
log "[INFO] Starting backup"
log "[INFO] Log filename: ${logFile}"

if [ -n "${RESTIC_BACKUP_ARGS}" ]; then
    log "[INFO] RESTIC_BACKUP_ARGS: ${RESTIC_BACKUP_ARGS}"
fi

restic backup /data ${RESTIC_BACKUP_ARGS} --tag="${RESTIC_TAG}" | tee -a "$logFile"
rc=$?
if [[ $rc == 0 ]]; then
    log "[INFO] Backup succeeded"
else
    log "[ERROR] Backup failed with status ${rc}"
    restic unlock
    copyErrorLog
    kill 1
fi
end=$(date +%s)
log "[INFO] Finished backup at $(date)"
showTime $((end-start))
