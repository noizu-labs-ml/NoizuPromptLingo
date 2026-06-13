#!/usr/bin/env bash
# Shared helpers for the per-app MongoDB initdb.d scripts.
#
# At runtime this is placed in /docker-entrypoint-initdb.d/ as "_lib" (no .sh
# extension) so the base image's initdb runner skips it; each per-app
# 1NN-<app>.sh sources it from the same directory. Runs during first-boot init,
# authenticated as the root user the image just created from MONGO_INITDB_ROOT_*.
set -e
export _MONGO_INITDB_LIB=1

: "${MONGO_INITDB_ROOT_USERNAME:?}"
: "${MONGO_INITDB_ROOT_PASSWORD:?}"

# create_db <db_name> <user_env_var> <pass_env_var>
# Idempotent (creates or updates the app user). No-op when the user env var is
# empty (app not provisioned here).
create_db() {
  local db_name="$1" user_var="$2" pass_var="$3"
  local db_user="${!user_var}" db_pass="${!pass_var}"

  if [ -z "$db_user" ]; then return 0; fi

  echo "Provisioning MongoDB database: $db_name (user: $db_user)"
  mongosh --quiet \
    -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" \
    --authenticationDatabase admin <<EOF
const appDb = db.getSiblingDB("${db_name}");
const roles = [{ role: "readWrite", db: "${db_name}" }];
if (appDb.getUser("${db_user}")) {
  appDb.updateUser("${db_user}", { pwd: "${db_pass}", roles: roles });
} else {
  appDb.createUser({ user: "${db_user}", pwd: "${db_pass}", roles: roles });
}
EOF
}
