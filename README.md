# database-replikasi:latest

A Docker utility that wraps MySQL command line tools to perform a one-way sync from one database to another.

Since the source database may be in another Docker container that is still in the process of coming up, this utility automatically waits on the source database to become accessible before continuing.

## Usage

There are several ways to run `ghcr.io/rickicode/docker-mysql-sync-replication:latest`.

Stand-alone:

```
docker run -d \
  --name mysql-replikasi \
  --restart unless-stopped \
    -e BACKUP_TIMES=120 \
    -e SRC_HOST=sourcehost.netq.me \
    -e SRC_PORT=3306 \
    -e SRC_NAME=source_db_name \
    -e SRC_PASS=source_db_pass \
    -e SRC_USER=source_db_user \
    -e DEST_HOST=destinationhost.netq.me \
    -e DEST_PORT=3306 \
    -e DEST_NAME=destination_db_name \
    -e DEST_PASS=destination_db_pass \
    -e DEST_USER=destination_db_user \
    ghcr.io/rickicode/docker-mysql-sync-replication:latest
```

Docker Compose:

```
version: '2'

services:
  mysql-sync:
    image: 'ghcr.io/rickicode/docker-mysql-sync-replication:latest'
    container_name: mysql-replikasi
    restart: unless-stopped
    environment:
      - BACKUP_TIMES=120
      - SRC_HOST=sourcehost.netq.me
      - SRC_PORT=3306
      - SRC_NAME=source_db_name
      - SRC_PASS=source_db_pass
      - SRC_USER=source_db_user
      - DEST_HOST=destinationhost.netq.me
      - DEST_PORT=3306
      - DEST_NAME=destination_db_name
      - DEST_PASS=destination_db_pass
      - DEST_USER=destination_db_user

```

The important bits are the environment variables, **all of which are required**.

| Environment Variable | Description |
|----------------------|-------------|
| BACKUP_TIMES | Backup time in second |
| SRC_HOST | Source db hostname |
| SRC_NAME | Source db name |
| SRC_PASS | Source db password |   
| SRC_USER | Source db username |
| DEST_HOST | Destination db hostname |
| DEST_NAME | Destination db name |
| DEST_PASS | Destination db password |   
| DEST_USER | Destination db username |

The cointainer will run in the background and will automatically restart if the container is stopped or the Docker daemon is restarted.

