#!/bin/bash

ENV_FILE="$(dirname "$0")/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
else
  echo "Error: .env file not found. Exiting."
  exit 1
fi

if [ -z "$SOURCE_DIRS" ]; then
  echo "Error: SOURCE_DIRS not defined in .env file. Exiting."
  exit 1
fi

REMOTE_BACKUP_BASE="/backups"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DEST_DIR="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BACKUP_BASE}/backup_${DATE}"

ssh "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ${REMOTE_BACKUP_BASE}/backup_${DATE}"
if [ $? -ne 0 ]; then
  echo "Error: Could not create backup directory on remote server." >&2
  exit 1
fi

LOG_FILE="/var/log/backup_script.log"
echo "Backup started at $(date)" >>"$LOG_FILE"

for SOURCE in $SOURCE_DIRS; do
  if [ -d "$SOURCE" ]; then
    echo "Starting backup for $SOURCE..." >>"$LOG_FILE"
    rsync -avz --delete "$SOURCE" "${DEST_DIR}/$(basename "$SOURCE")" >>"$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
      echo "Backup for $SOURCE completed successfully." >>"$LOG_FILE"
    else
      echo "Error: Backup for $SOURCE failed." >>"$LOG_FILE"
    fi
  else
    echo "Warning: Source directory $SOURCE does not exist." >>"$LOG_FILE"
  fi
done

if grep -q "Error" "$LOG_FILE"; then
  SUBJECT="Backup Failed - ${DATE}"
  MESSAGE="One or more directories failed to backup. Please review the log file at ${LOG_FILE}."
else
  SUBJECT="Backup Successful - ${DATE}"
  MESSAGE="Backup completed successfully. All files are backed up to ${DEST_DIR}."
fi

echo "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL"

echo "Backup process completed at $(date)." >>"$LOG_FILE"
