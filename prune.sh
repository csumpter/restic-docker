#!/bin/bash
set -e

logFile=/var/log/restic/prune/$(date +"%Y-%m-%d-%H-%M-%S").log

function log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a "$logFile"
}

function showTime () {
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
    log "[INFO] Total prune time: ${time}"
}

start=$(date +%s)
log "[INFO] Starting prune"
log "[INFO] Log filename: ${logFile}"

start=$(date +%s)
log "[INFO] Starting prune process"
restic prune | tee -a "$logFile"
rc=$?
end=$(date +%s)
if [[ $rc == 0 ]]; then
    log "[INFO] Prune Successful"
else
    log "[ERROR] Prune failed with status ${!rc}"
    restic unlock
fi

end=$(date +%s)
log "[INFO] Finished prune at $(date)"
showTime $((end-start))
