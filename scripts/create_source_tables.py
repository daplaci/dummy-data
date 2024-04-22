"""Create the source tables - Used for development purposes"""

from typing import Final, List
import sys

sys.path.insert(0, "/Users/ctx327/Documents/GitHub/rigshospitalet_etl/")
from etl.models.modelutils import (
    DIALECT_POSTGRES,
    create_tables_sql,
    drop_tables_sql,
)
from etl.models.source import (
    Administrations,
    CourseMetadata,
    DiagnosesProcedures,
    Observations,
    Prescriptions,
    Person,
    CourseIdCprMapping,
    LabkaBccLaboratory,
    LprDiagnoses,
    LprOperations,
    LprProcedures,
)
from etl.util.sql import clean_sql

SOURCE_MODELS: Final[List] = [
    Administrations,
    CourseMetadata,
    DiagnosesProcedures,
    Observations,
    Prescriptions,
    Person,
    CourseIdCprMapping,
    LabkaBccLaboratory,
    LprDiagnoses,
    LprOperations,
    LprProcedures,
]


@clean_sql
def _ddl_sql() -> str:
    statements = [
        drop_tables_sql(SOURCE_MODELS, cascade=True),
        create_tables_sql(SOURCE_MODELS, dialect=DIALECT_POSTGRES),
    ]
    return " ".join(statements)


SQL: Final[str] = _ddl_sql()

print(SQL)
