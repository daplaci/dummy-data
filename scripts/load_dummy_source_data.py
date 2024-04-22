import sys
sys.path.append("..")

import os

import pandas as pd
from etl.util.connection import ConnectionDetails
from etl.util.db import make_engine_postgres

rigs_cnxn = ConnectionDetails(
    host="localhost",
    port="5432",
    dbname="omop_dev",
    dbms="postgresql",
    user="postgres",
    password="postgres",
)

rigs_engine = make_engine_postgres(rigs_cnxn)


def write_to_db(db_engine, table_frame: pd.DataFrame, table_name: str, schema: str = "source"):
    table_frame.to_sql(table_name, db_engine, if_exists="append", index=False, schema=schema)

path = os.path.join(os.path.dirname(__file__), "../dummy_data/")

administrations_df = pd.read_csv(f"{path}administrations.csv")
course_metadata_df = pd.read_csv(f"{path}course_metadata.csv")
diagnoses_procedures_df = pd.read_csv(f"{path}diagnoses_procedures.csv")
observations_df = pd.read_csv(f"{path}observations.csv")
person_df = pd.read_csv(f"{path}person.csv", dtype=str)
prescriptions_df = pd.read_csv(f"{path}prescriptions.csv")
courseid_cpr_mapping = pd.read_csv(f"{path}course_id_cpr_mapping.csv")

write_to_db(rigs_engine, administrations_df, "administrations")
write_to_db(rigs_engine, course_metadata_df, "course_metadata")
write_to_db(rigs_engine, diagnoses_procedures_df, "diagnoses_procedures")
write_to_db(rigs_engine, observations_df, "observations")
write_to_db(rigs_engine, person_df, "person")
write_to_db(rigs_engine, prescriptions_df, "prescriptions")
write_to_db(rigs_engine, courseid_cpr_mapping, "courseid_cpr_mapping")


laboratory_df = pd.read_csv(f'{path}laboratory.csv')
lprdiagnoses_df = pd.read_csv(f'{path}diagnoses.csv')
lproperations_df = pd.read_csv(f'{path}operations.csv')
lprprocedures_df = pd.read_csv(f'{path}procedures.csv')

write_to_db(rigs_engine, laboratory_df, 'laboratory', schema="registries")
write_to_db(rigs_engine, lprdiagnoses_df, 'diagnoses', schema='registries')
write_to_db(rigs_engine, lproperations_df, 'operations', schema='registries')
write_to_db(rigs_engine, lprprocedures_df, 'procedures', schema='registries')
