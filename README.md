<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/rickicode/docker-mysql-sync-replication.svg)](https://github.com/rickicode/docker-mysql-sync-replication/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/rickicode/docker-mysql-sync-replication.svg)](https://github.com/rickicode/docker-mysql-sync-replication/pulls)

</div>


# Docker MySQL Sync Replication


<p align="center"> A Docker utility that wraps MySQL command line tools to perform a one-way sync from one database to another.
<br> 
Since the source database may be in another Docker container that is still in the process of coming up, this utility automatically waits on the source database to become accessible before continuing.
</p>



## Usage

There are several ways to run `ghcr.io/rickicode/docker-mysql-sync-replication:latest`.

### Stand-alone:

```
docker run -d \
  --name mysql-replikasi \
  --restart unless-stopped \
    -e BACKUP_TIMES=120 \
    -e DATABASE_NAME=databasename \
    -e SRC_HOST=source.netq.me \
    -e SRC_PORT=3306 \
    -e SRC_USER=source_db_user \
    -e SRC_PASS=source_db_pass \
    -e DEST_HOST=dest.netq.me \
    -e DEST_PORT=3306 \
    -e DEST_USER=destination_db_user \
    -e DEST_PASS=destination_db_pass \
    ghcr.io/rickicode/docker-mysql-sync-replication:latest
```

### Docker Compose:

```
version: '3'

services:
  mysql-sync:
    image: 'ghcr.io/rickicode/docker-mysql-sync-replication:latest'
    container_name: mysql-replikasi
    restart: unless-stopped
    environment:
      - BACKUP_TIMES=120
      - DATABASE_NAME=databasename
      - SRC_HOST=source.netq.me
      - SRC_PORT=3306
      - SRC_USER=source_db_user
      - SRC_PASS=source_db_pass
      - DEST_HOST=dest.netq.me
      - DEST_PORT=3306
      - DEST_USER=destination_db_user
      - DEST_PASS=destination_db_pass

```
### Example
Support Multiple Database by using comma (,)
```
BACKUP_TIMES=120
DATABASE_NAME=netqdb,wpdb
SRC_HOST=source.netq.me
SRC_PORT=3306
SRC_USER=root
SRC_PASS=whymelord
DEST_HOST=dest.netq.me
DEST_PORT=3306
DEST_USER=root
DEST_PASS=whymelord
```

### ENV
The important bits are the environment variables, **all of which are required**.

| Environment Variable | Description |
|----------------------|-------------|
| BACKUP_TIMES | Backup time in second |
| DATABASE_NAME | Database Name you want Backup |
| SRC_HOST | Source db hostname |
| SRC_USER | Source db username |
| SRC_PASS | Source db password |   
| DEST_HOST | Destination db hostname |
| DEST_USER | Destination db username |
| DEST_PASS | Destination db password |   


DB NAME will be created if not exist.<br>
The cointainer will run in the background and will automatically restart if the container is stopped or the Docker daemon is restarted.



### Deploy using the Koyeb button

The fastest way to deploy the Flask application is to click the **Deploy to Koyeb** button below.

[![Deploy to Koyeb](https://www.koyeb.com/static/images/deploy/button.svg)](https://app.koyeb.com/deploy?name=MYSQL-REPLICATIONtype=docker&image=ghcr.io/rickicode/docker-mysql-sync-replication:latest)

Clicking on this button brings you to the Koyeb App creation page with everything pre-set to launch this application.




## Powered by <a name = "powered_by"></a>

- [NETQ.ME](https://netq.me/) - Free Tunneling Service
- [HIJITOKO](https://hijitoko.com/) - Online Store

## ✍️ Authors <a name = "authors"></a>

- [@rickicode](https://github.com/rickicode)

