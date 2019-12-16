#!/bin/bash
set -e

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")]$1" | tee -a "$LOG"
}

repoInitialized() {
  restic snapshots || {
    log "[INFO] Repository is not initialized"
    return 1
  }
}

initializeRepo() {
  restic init || {
    log "[ERROR] Failed to initialize repo"
    return 1
  }
  log "[INFO] Repo initialized"
}

checkRepoStatus() {
  log "[INFO] Checking restic repository status ..."
  repoInitialized || initializeRepo
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
crond && log "[INFO] Cron service started successfully"

# If the repo has never been initialized, init the repo
checkRepoStatus

log "[INFO] Container started"
tail -fn0 "$LOG"
