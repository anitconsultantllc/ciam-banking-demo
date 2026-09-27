#!/usr/bin/env bash
# Runs once, the first time the Postgres volume is created.
# Creates one database + one owner role per service ("database per service"),
# so no service can read another service's tables.
set -euo pipefail

for db in keycloak customer account transfer notification; do
  echo "Creating ${db}_db owned by ${db}_user"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-SQL
    CREATE ROLE ${db}_user LOGIN PASSWORD '${APP_DB_PASSWORD}';
    CREATE DATABASE ${db}_db OWNER ${db}_user;
    REVOKE ALL ON DATABASE ${db}_db FROM PUBLIC;
SQL
done
