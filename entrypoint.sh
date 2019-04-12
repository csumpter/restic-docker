#!/bin/bash
set -e

function log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a $LOG
}

function repoInitialized() {
    restic snapshots > /dev/null 2>&1
    rc=$?
    if [ $rc -eq 1 ]; then
        log "[INFO] Repository is not initialized"
        return 1
    elif [ $rc -eq 0 ]; then
        return 0
    fi
}

function initializeRepo() {
    restic init > /dev/null 2>&1
    rc = $?
    if [ $rc -eq 1 ]; then
        log "[ERROR] Failed to initialize repo"
        return 1
    elif [ $rc -eq 0 ]; then
        log "[INFO] Repo initialized"
        return 0
    fi
}

function checkRepoStatus() {
    log "[INFO] Checking restic repository status ..."
    repoInitialized
    if [ $? -eq 1 ]; then
        initializeRepo
    else
        return 0
    fi
}

log "[INFO] Starting container ..."
log "[INFO] Backup cron schedule is set to: ${BACKUP_CRON}"
echo "${BACKUP_CRON} /root/backup.sh >> $LOG 2>&1" > /var/spool/cron/crontabs/root

if [ -n "${FORGET_CRON}" ]; then
    echo "${FORGET_CRON} /root/forget.sh >> $LOG 2>&1" >> /var/spool/cron/crontabs/root
    log "[INFO] Forget cron schedule is set to: ${FORGET_CRON}"
fi

if [ -n "${PRUNE_CRON}" ]; then
    echo "${PRUNE_CRON} /root/prune.sh >> $LOG 2>&1" >> /var/spool/cron/crontabs/root
    log "[INFO] Prune cron schedule is set to: ${PRUNE_CRON}"
fi

log "[INFO] Timezone is set to: ${TZ}"
log "[INFO] Starting cron service"
crond
if [[ $? == 0 ]]; then
    log "[INFO] Cron service started successfully"
fi

# If the repo has never been initialized, init the repo
checkRepoStatus

log "[INFO] Container started"
tail -fn0 $LOG
