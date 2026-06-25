# MySQL binlog Retention

- Status: active
- Scope: parent Docker / MySQL operations

## Purpose

MySQL binary logs are kept enabled so recent recovery options remain available.
To avoid unbounded mysql-data volume growth, the parent Docker configuration
sets the retention period to 3 days.

Configured value:

    binlog_expire_logs_seconds = 259200

259200 seconds is 3 days. max_binlog_size is not a total capacity limit, so the
primary control is retention period plus routine capacity checks.

## Verification

Run these from the parent repository root.

    docker compose config
    docker compose ps mysql
    docker compose exec -T mysql sh -lc 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW VARIABLES LIKE '\''log_bin'\''; SHOW VARIABLES LIKE '\''binlog_expire_logs_seconds'\''; SHOW VARIABLES LIKE '\''max_binlog_size'\'';"'
    docker compose exec -T mysql sh -lc 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW BINARY LOGS;"'
    df -h
    sudo du -sh /var/lib/docker/volumes/api-discovery-hub_mysql-data || true

Expected values:

- log_bin remains ON.
- binlog_expire_logs_seconds is 259200.
- Root filesystem has enough free space for normal operation.
- mysql-data volume growth is visible in the capacity check.

## Production Apply Notes

Applying this configuration to an existing production container requires a MySQL
container recreation, for example:

    docker compose up -d --force-recreate mysql

Because this touches the production database container, run it only after human
approval. Do not delete Docker volumes.

## Prohibited Recovery Shortcuts

Do not remove binlog files directly from the host filesystem. If old binary logs
must be removed, use MySQL-managed purge commands so MySQL metadata and files
stay consistent.

Do not run:

    docker compose down -v
    docker system prune
    docker volume prune
    rm /var/lib/docker/volumes/.../binlog.*

## Rollback

Revert the configuration change, run docker compose config, and recreate the
MySQL container only after human approval. Do not delete the database volume and
do not remove binlog files directly from the OS.
