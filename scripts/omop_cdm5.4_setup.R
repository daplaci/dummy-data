install.packages("devtools")
devtools::install_github("OHDSI/CommonDataModel")
devtools::install_github("DatabaseConnector")

temp_driver_dir <- tempdir()
DatabaseConnector::downloadJdbcDrivers(
	"postgresql",
	temp_driver_dir
)

cd <- DatabaseConnector::createConnectionDetails(
	dbms = "postgresql",
	server = "localhost/omop_dev",
	user = "postgres",
	password = "postgres",
	port = 5432,
	pathToDriver = temp_driver_dir
)

conn <- DatabaseConnector::connect(cd)

DatabaseConnector::executeSql(
	connection = conn,
	sql = "DROP SCHEMA IF EXISTS cdm CASCADE; CREATE SCHEMA cdm;"
)

CommonDataModel::executeDdl(
	connectionDetails = cd,
	cdmVersion = "5.4",
	cdmDatabaseSchema = "cdm"
)

# Change FKs to be deferrable before COPYing flat files into db
# from: https://dba.stackexchange.com/a/216068
DatabaseConnector::querySql(
	connection = conn,
	sql = "
		SELECT 'alter table ' || quote_ident(ns.nspname) || '.' || quote_ident(tb.relname) ||
		       '  alter constraint ' || quote_ident(conname) || ' deferrable initially immediate;'
		FROM pg_constraint c
		JOIN pg_class tb ON tb.oid = c.conrelid
		JOIN pg_namespace ns ON ns.oid = tb.relnamespace
		WHERE ns.nspname IN ('cdm') AND c.contype = 'f';
	"
) %>%
	pull(1) %>%
	paste(collapse = "\n") %>%
	DatabaseConnector::executeSql(connection = conn, sql = .)

# Run this stuff in psql to COPY flat files into db
BEGIN;
SET search_path TO cdm;
SET CONSTRAINTS ALL DEFERRED;
COPY CONCEPT FROM '/data/2023-12-21__cdm_5.4/CONCEPT.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY DOMAIN FROM '/data/2023-12-21__cdm_5.4/DOMAIN.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY CONCEPT_CLASS FROM '/data/2023-12-21__cdm_5.4/CONCEPT_CLASS.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY VOCABULARY FROM '/data/2023-12-21__cdm_5.4/VOCABULARY.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY RELATIONSHIP FROM '/data/2023-12-21__cdm_5.4/RELATIONSHIP.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY CONCEPT_RELATIONSHIP FROM '/data/2023-12-21__cdm_5.4/CONCEPT_RELATIONSHIP.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY CONCEPT_ANCESTOR FROM '/data/2023-12-21__cdm_5.4/CONCEPT_ANCESTOR.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY CONCEPT_SYNONYM FROM '/data/2023-12-21__cdm_5.4/CONCEPT_SYNONYM.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COPY DRUG_STRENGTH FROM '/data/2023-12-21__cdm_5.4/DRUG_STRENGTH.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b' ;
COMMIT;

