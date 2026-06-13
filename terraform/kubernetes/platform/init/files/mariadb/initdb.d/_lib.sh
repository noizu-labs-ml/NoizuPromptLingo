#!/usr/bin/env bash
# Shared helpers for the per-app MariaDB initdb.d scripts.
#
# At runtime this is placed in /docker-entrypoint-initdb.d/ as "_lib" (no .sh
# extension) so the base image's initdb runner skips it; each per-app
# 1NN-<app>.sh sources it from the same directory. The _MARIADB_INITDB_LIB guard
# keeps it idempotent if sourced more than once. Runs during first-boot init,
# where the server is up and root is reachable over the local socket.
set -e
export _MARIADB_INITDB_LIB=1

: "${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD must be set}"
# MYSQL_PWD is exported by the deployment so the client never needs -p on argv.
export MYSQL_PWD="$MARIADB_ROOT_PASSWORD"

mdb() { mariadb --protocol=socket -uroot "$@"; }

# create_db <db_name> <user_env_var> <pass_env_var>
# Idempotent. No-op when the user env var is empty (app not provisioned here).
create_db() {
  local db_name="$1" user_var="$2" pass_var="$3"
  local db_user="${!user_var}" db_pass="${!pass_var}"

  if [ -z "$db_user" ]; then return 0; fi

  echo "Provisioning MariaDB database: $db_name (user: $db_user)"
  mdb <<SQL
CREATE DATABASE IF NOT EXISTS \`${db_name}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
ALTER USER '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%';
FLUSH PRIVILEGES;
SQL
}
