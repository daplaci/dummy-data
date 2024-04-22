#!/bin/bash
set -e

# Load the OMOP CDM schema
psql -v ON_ERROR_STOP=1 --host localhost --username "$POSTGRES_USER" --port "$POSTGRES_PORT" --dbname "$POSTGRES_DB" -v cdmDatabaseSchema=omopcdm <<-EOSQL
\i 'omop_cdm_schema.sql';
EOSQL

# Load the vocabulary
psql -v ON_ERROR_STOP=1 --host localhost --username "$POSTGRES_USER" --port "$POSTGRES_PORT" --dbname "$POSTGRES_DB" -v cdmDatabaseSchema=omopcdm <<-EOSQL
\i 'load_localhost_vocabulary.sql';
EOSQL
