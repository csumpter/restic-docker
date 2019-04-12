#!/bin/bash
set -e

logFile=/var/log/restic/forget/`date +"%Y-%m-%d-%H-%M-%S"`.log

function log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a $logFile
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
    log "[INFO] Total forget time: ${time}"
}

start=`date +%s`
log "[INFO] Starting forget"
log "[INFO] Log filename: ${logFile}"
log "[INFO] RESTIC_FORGET_ARGS: ${RESTIC_FORGET_ARGS}"

if [ -n "${RESTIC_FORGET_ARGS}" ]; then
    start=`date +%s`
    restic forget ${RESTIC_FORGET_ARGS} | tee -a $logFile
    rc=$?
    end=`date +%s`
    if [[ $rc == 0 ]]; then
        log "[INFO] Forget successfull"
    else
        log "[ERROR] Forget failed with status ${$rc}"
        restic unlock
    fi
fi

end=`date +%s`
log "[INFO] Finished forget at $(date)"
showTime $((end-start))
