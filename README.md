# trachAI dummy-data
Helper files for setting up dummy data.

## Structure
These scripts assumes the following folder structure:

```
.
├── docker-compose.yaml
├── dummy-data
│   ├── README.md
│   ├── data
│   │   ├── administrations.csv
│   │   ├── ...
│   │   └── ube.csv
│   └── scripts
│       ├── create_source_tables.py
│       ├── ...
│       └── load_dummy_source_data.py
├── rigshospitalet_etl
│   ├── Dockerfile
│   ├── README.md
│   ├── __pycache__
│   ├── connection.json
│   ├── db.env
│   ├── docker
│   ├── docker-compose.override.yml
│   ├── docker-compose.yml
│   ├── etl
│   ├── log
│   ├── postgresql.conf
│   ├── pyproject.toml
│   ├── pytest.ini
│   ├── requirements.dev.txt
│   ├── requirements.txt
│   ├── setup.cfg
│   ├── tests
│   └── venv
└── vocabs
    ├── CONCEPT.csv
    ├── CONCEPT_ANCESTOR.csv
    ├── CONCEPT_CLASS.csv
    ├── CONCEPT_RELATIONSHIP.csv
    ├── CONCEPT_SYNONYM.csv
    ├── DOMAIN.csv
    ├── DRUG_STRENGTH.csv
    ├── RELATIONSHIP.csv
    └── VOCABULARY.csv
```

## Process
1. Make sure you're in `./dummy-data`
2. Run `source ../rigshospitalet_etl/venv/bin/activate`
3. Run `python scripts/create_source_tables.py | pbcopy` (copies the DDL statements to the clipboard on Mac OS)
4. Execute the DDL statements in your preferred RDBMS
5. Run `python scripts/load_dummy_source_data.py`
