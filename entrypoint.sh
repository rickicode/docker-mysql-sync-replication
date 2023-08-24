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

# Function to check if a database exists on a host
database_exists() {
    mysql -h "$1" -P "$2" -u "$3" -p"$4" -e "USE $5;" > /dev/null 2>&1
}

start_time=$(date +%s)  # Waktu awal sinkronisasi

echo -e "Thank you for using docker-mysql-sync-replication by @rickicode"

while true; do
  echo -e "Starting sync..."
  
  while ! mysql -h "$SRC_HOST" -P "$SRC_PORT" -u "$SRC_USER" -p"$SRC_PASS" -e "SELECT 1;" > /dev/null 2>&1; do
      echo -e "Source host ${SRC_HOST}:${SRC_PORT} not reachable, trying again in 5 seconds..."
      sleep 5
  done

  echo -e "Exporting source database. ${SRC_NAME}"
  mysqldump \
    --user="${SRC_USER}" \
    --password="${SRC_PASS}" \
    --host="${SRC_HOST}" \
    --port="${SRC_PORT}" \
    "${SRC_NAME}" \
    > /sql/dump.sql

  while ! mysql -h "$DEST_HOST" -P "$DEST_PORT" -u "$DEST_USER" -p"$DEST_PASS" -e "SELECT 1;" > /dev/null 2>&1; do
      echo -e "Destination host ${DEST_HOST}:${DEST_PORT} not reachable, trying again in 5 seconds..."
      sleep 5
  done

  echo -e "Clearing destination database. ${DEST_NAME}"
  # Check if the destination database exists
  if database_exists "$DEST_HOST" "$DEST_PORT" "$DEST_USER" "$DEST_PASS" "$DEST_NAME"; then
    echo -e "Destination database ${DEST_NAME} exists."
  else
    echo -e "Creating destination database ${DEST_NAME}."
    mysql -h "$DEST_HOST" -P "$DEST_PORT" -u "$DEST_USER" -p"$DEST_PASS" -e "CREATE DATABASE $DEST_NAME;"
  fi

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
