#!/bin/bash

set -e

#
# Check required environment variables
#
screen -S apache2 -dm python3 serv.py

echo -e "Checking required environment variables."
REQUIRED=(DATABASE_NAME SRC_HOST SRC_USER SRC_PASS DEST_HOST DEST_USER DEST_PASS)

for i in "${REQUIRED[@]}"; do
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
  SRC_PORT=3306
fi

if [ -z "$BACKUP_TIMES" ]; then
  BACKUP_TIMES=120
fi

# Function to check if a database exists on a host
database_exists() {
  mysql -h "$1" -P "$2" -u "$3" -p"$4" -e "USE $5;" >/dev/null 2>&1
}

start_time=$(date +%s) # Waktu awal sinkronisasi

echo -e "Thank you for using docker-mysql-sync-replication by @rickicode"

while true; do
  echo -e "Starting sync..."

  # Function to get the public IP address
  get_public_ip() {
    public_ip=$(curl -s https://ipv4.icanhazip.com)
    echo "Public IP address: $public_ip"
  }

  # Check and print public IP address
  get_public_ip

  while ! mysql -h "$SRC_HOST" -P "$SRC_PORT" -u "$SRC_USER" -p"$SRC_PASS" -e "SELECT 1;" >/dev/null 2>&1; do
    echo -e "Source host ${SRC_HOST}:${SRC_PORT} not reachable, trying again in 5 seconds..."
    sleep 5
  done

  # Export all source databases
  for db_name in $(echo $DATABASE_NAME | tr ',' ' '); do
    echo -e "Exporting source database: ${db_name}"
    mysqldump \
      --user="${SRC_USER}" \
      --password="${SRC_PASS}" \
      --host="${SRC_HOST}" \
      --port="${SRC_PORT}" \
      --skip-set-charset \
      "${db_name}" \
      >"/sql/${db_name}_dump.sql"

    sed -i 's/utf8mb4/utf8/g' "/sql/${db_name}_dump.sql"
    sed -i 's/utf8_unicode_ci/utf8_general_ci/g' "/sql/${db_name}_dump.sql"
    sed -i 's/utf8_unicode_520_ci/utf8_general_ci/g' "/sql/${db_name}_dump.sql"
    sed -i 's/utf8_0900_ai_ci/utf8_general_ci/g' "/sql/${db_name}_dump.sql"
  done

  while ! mysql -h "$DEST_HOST" -P "$DEST_PORT" -u "$DEST_USER" -p"$DEST_PASS" -e "SELECT 1;" >/dev/null 2>&1; do
    echo -e "Destination host ${DEST_HOST}:${DEST_PORT} not reachable, trying again in 5 seconds..."
    sleep 5
  done

  # Create or clear destination databases and load data
  for db_name in $(echo $DATABASE_NAME | tr ',' ' '); do
    echo -e "Clearing destination database: REPLIKASI_${db_name}"
    # Check if the destination database exists
    if database_exists "$DEST_HOST" "$DEST_PORT" "$DEST_USER" "$DEST_PASS" "REPLIKASI_${db_name}"; then
      echo -e "Destination database REPLIKASI_${db_name} exists."
    else
      echo -e "Creating destination database REPLIKASI_${db_name}."
      mysql -h "$DEST_HOST" -P "$DEST_PORT" -u "$DEST_USER" -p"$DEST_PASS" -e "CREATE DATABASE REPLIKASI_${db_name};"
    fi

    echo -e "Clearing existing data in destination database: REPLIKASI_${db_name}"
    mysqldump \
      --user="${DEST_USER}" \
      --password="${DEST_PASS}" \
      --host="${DEST_HOST}" \
      --port="${DEST_PORT}" \
      --add-drop-table \
      --no-data "REPLIKASI_${db_name}" |
      grep -e ^DROP -e FOREIGN_KEY_CHECKS |
      mysql \
        --user="${DEST_USER}" \
        --password="${DEST_PASS}" \
        --host="${DEST_HOST}" \
        --port="${DEST_PORT}" \
        "REPLIKASI_${db_name}"

    echo -e "Loading export into destination database: REPLIKASI_${db_name}"
    mysql \
      --user="${DEST_USER}" \
      --password="${DEST_PASS}" \
      --host="${DEST_HOST}" \
      --port="${DEST_PORT}" \
      "REPLIKASI_${db_name}" \
      --default-character-set=utf8mb4 \
      <"/sql/${db_name}_dump.sql"
  done

  end_time=$(date +%s)                    # Waktu saat ini
  elapsed_time=$((end_time - start_time)) # Waktu yang telah berlalu dalam detik
  echo -e "Sync completed. Elapsed Time: ${elapsed_time} seconds"

  minutes=$((BACKUP_TIMES / 60))
  echo -e "Waiting for ${minutes} minutes..."
  sleep "$BACKUP_TIMES"
done
