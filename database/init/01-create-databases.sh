#!/bin/bash
set -e

# Create multiple databases for JLAM Platform
# Used by PostgreSQL docker-entrypoint-initdb.d

echo "Creating additional databases for JLAM Platform..."

# Parse POSTGRES_MULTIPLE_DATABASES environment variable
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        if [ "$db" != "$POSTGRES_DB" ]; then
            echo "Creating database: $db"
            psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
                CREATE DATABASE "$db";
                GRANT ALL PRIVILEGES ON DATABASE "$db" TO "$POSTGRES_USER";
EOSQL
            echo "Database $db created successfully"
        fi
    done
fi

echo "All databases created successfully!"