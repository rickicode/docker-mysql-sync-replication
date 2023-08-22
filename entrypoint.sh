#!/bin/bash

set -e

#
# Check required environment variables
#
echo -e "Checking required environment variables."
REQUIRED=( SRC_HOST SRC_USER SRC_PASS SRC_NAME DEST_HOST DEST_USER DEST_PASS DEST_NAME )

for i in "${REQUIRED[@]}"
do
  if [ -z "${!i}" ]; then
      echo -e "Environment variable ${i} is required, exiting..."
      exit 1
  fi
done

#
# Check if DEST_PORT and SRC_PORT are set
#

if [ -z "$DEST_PORT" ]; then
  DEST_PORT=3306 
fi

if [ -z "$SRC_PORT" ]; then
  DEST_PORT=3306
fi

if [ -z "$BACKUP_TIMES" ]; then
  BACKUP_TIMES=120
fi

# Function to check if a host is reachable
is_host_reachable() {
    ping -c 1 -W 1 "$1" > /dev/null 2>&1
}

start_time=$(date +%s)  # Waktu awal sinkronisasi

while true; do
  echo -e "Starting sync..."
  while ! is_host_reachable "$SRC_HOST"; do
      echo -e "Source host ${SRC_HOST} not reachable, trying again later..."
      sleep 1
  done

  echo -e "Exporting source database. ${SRC_NAME}"
  mysqldump \
    --user="${SRC_USER}" \
    --password="${SRC_PASS}" \
    --host="${SRC_HOST}" \
    --port="${SRC_PORT}" \
    "${SRC_NAME}" \
    > /sql/dump.sql

  while ! is_host_reachable "$DEST_HOST"; do
      echo -e "Destination host ${DEST_HOST} not reachable, trying again later..."
      sleep 1
  done

  echo -e "Clearing destination database. ${DEST_NAME}"
  mysqldump \
    --user="${DEST_USER}" \
    --password="${DEST_PASS}" \
    --host="${DEST_HOST}" \
    --port="${DEST_PORT}" \
    --add-drop-table \
    --no-data "${DEST_NAME}" | \
    grep -e ^DROP -e FOREIGN_KEY_CHECKS | \
    mysql \
    --user="${DEST_USER}" \
    --password="${DEST_PASS}" \
    --host="${DEST_HOST}" \
    --port="${DEST_PORT}" \
    "${DEST_NAME}"

  echo -e "Loading export into destination database. ${DEST_NAME}"
  mysql \
    --user="${DEST_USER}" \
    --password="${DEST_PASS}" \
    --host="${DEST_HOST}" \
    --port="${DEST_PORT}" \
    "${DEST_NAME}" \
    < /sql/dump.sql

  end_time=$(date +%s)  # Waktu saat ini
  elapsed_time=$((end_time - start_time))  # Waktu yang telah berlalu dalam detik
  echo -e "Sync completed. Elapsed Time: ${elapsed_time} seconds"

  minutes=$((BACKUP_TIMES / 60))
  echo -e "Waiting for ${minutes} minutes..."
  sleep $BACKUP_TIMES 
done
