#!/bin/bash
set -e

# ==========================================
# Project : Automated Backup & Cleanup System
# Author  : Guna
# Version : 1.0
# Purpose : Backup automation using Bash
# ==========================================


# Load configuration

source config/backup.conf


# Logging function

write_log()
{

MESSAGE=$1

TIME=$(date "+%Y-%m-%d %H:%M:%S")

echo "$TIME : $MESSAGE" >> "$LOG_FILE"

}

cleanup_old_backups()
{

echo "Cleaning old backups..."


write_log "Cleanup started"


find "$BACKUP_DIR" \
-name "backup_*.tar.gz" \
-type f \
-mtime +$RETENTION_DAYS \
-delete


write_log "Cleanup completed"

}
backup_summary()
{

echo ""
echo "========== BACKUP SUMMARY =========="


TOTAL_BACKUPS=$(find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f | wc -l)


echo "Total Backups : $TOTAL_BACKUPS"


TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | awk '{print $1}')


echo "Total Backup Storage : $TOTAL_SIZE"


LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | head -1)


echo "Latest Backup : $LATEST_BACKUP"


echo "===================================="


write_log "Backup summary generated"

}








# Create timestamp

DATE=$(date +"%Y-%m-%d_%H-%M-%S")


# Backup filename

BACKUP_FILE="backup_$DATE.tar.gz"


echo "Starting Backup..."


# Check source directories

for DIR in "${SOURCE_DIRS[@]}"
do

    if [ ! -d "$DIR" ]
    then

        echo "$DIR does not exist"

        write_log "ERROR - Source directory missing: $DIR"

        exit 1

    fi

done


# Create backup directory

mkdir -p "$BACKUP_DIR"


# Start logging

write_log "Backup started"


# Create backup

tar -czf "$BACKUP_DIR/$BACKUP_FILE" "${SOURCE_DIRS[@]}"


# Check backup status

if [ $? -eq 0 ]
then

    echo "Backup completed successfully"

    write_log "Backup completed successfully"

else

    echo "Backup failed"

    write_log "ERROR - Backup failed"

    exit 1

fi


# Verify backup file exists

if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]
then

    echo "Backup file verified"

    write_log "Backup file verified"

else

    echo "Backup file missing"

    write_log "ERROR - Backup file missing"

    exit 1

fi


# Backup size

BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | awk '{print $1}')


echo "Backup Size : $BACKUP_SIZE"

write_log "Backup Size : $BACKUP_SIZE"


echo "Backup File : $BACKUP_FILE"

write_log "Backup File : $BACKUP_FILE"


echo "Backup Process Completed"
exit 0
cleanup_old_backups
backup_summary
