#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create additional databases and users

    -- Database 1: north
    CREATE DATABASE north;

    -- User 1: usr_north with read-write access to north
    CREATE USER usr_north WITH PASSWORD 'Pass1234';
    GRANT ALL PRIVILEGES ON DATABASE north TO usr_north;

    -- Database 2: west
    CREATE DATABASE west;

    -- User 2: usr_west with read-write access to west
    CREATE USER usr_west WITH PASSWORD 'Pass1234';
    GRANT ALL PRIVILEGES ON DATABASE west TO usr_west;
EOSQL

# Grant schema privileges for north
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "north" <<-EOSQL
    GRANT ALL ON SCHEMA public TO usr_north;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO usr_north;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO usr_north;
EOSQL

# Grant schema privileges for west
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "west" <<-EOSQL
    GRANT ALL ON SCHEMA public TO usr_west;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO usr_west;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO usr_west;
EOSQL

