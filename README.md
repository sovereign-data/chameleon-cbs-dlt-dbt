# chameleon-cbs-dlt-dbt

CBS StatLine open data (NL) → **dlt** → parquet on the platform's S3 (RustFS) →
**dbt** on Chameleon SQE (Iceberg via Polaris).

Use case: *what does an average Dutch home pay for energy, per municipality and
dwelling type?* CBS publishes average use (81528NED, 2010–now) and average
consumer tariffs (85592NED, monthly since 2021); gold multiplies the two.

```
ingest/cbs_pipeline.py   dlt: CBS OData feed -> s3://cbs-landing/raw/cbs/<table>/ (replace)
models/bronze            read_parquet() of each landed folder -> cbs_bronze.*
models/silver            typed facts per year + region/dwelling dims -> cbs_silver.*
models/gold              energy_cost_per_dwelling -> cbs_gold.*
```

The same dbt project runs two ways (see `chameleon-airflow-e2e`):

| | dbt in Airflow | dbt in Chameleon |
|---|---|---|
| Who runs dbt | Airflow worker (cosmos, one task per model) | Backend dbt-runner pod (`ChameleonDbtRunOperator`) |
| Code | git-synced submodule of the DAG repo | cloned by the backend from this repo (`chameleon_project`) |
| Auth to SQE | service-principal token fetched in the task | backend token exchange for the workspace |
| Lineage / run history | Airflow UI | Chameleon UI (lineage, dbt runs) + Airflow |

## Platform prerequisites

- Bucket `cbs-landing` (Terraform `chameleon_storage_bucket`, see `chameleon-platform-tf`).
- SQE allows reading it: `valueOverrides.sqe.extraTvfPrefixes: ["s3://cbs-landing/"]` on the DataPlatform CR.

## Local

```bash
uv sync --group dev
uv run pytest -q ingest

# land to local disk (no platform needed)
CBS_LANDING_BUCKET_URL=file:///tmp/cbs uv run python ingest/cbs_pipeline.py

# land to the platform's RustFS
export DESTINATION__FILESYSTEM__CREDENTIALS__AWS_ACCESS_KEY_ID=...
export DESTINATION__FILESYSTEM__CREDENTIALS__AWS_SECRET_ACCESS_KEY=...
export DESTINATION__FILESYSTEM__CREDENTIALS__ENDPOINT_URL=https://rustfs.test.sovereign-data.org
uv run python ingest/cbs_pipeline.py

# dbt against SQE (public sql.<domain> route); token = Keycloak access token with aud sqe
export DBT_ACCESS_TOKEN=$(curl -s -d grant_type=client_credentials -d client_id=... -d client_secret=... \
  https://keycloak.test.sovereign-data.org/realms/chameleon/protocol/openid-connect/token | jq -r .access_token)
DBT_TARGET_CATALOG=ws_cbs uv run dbt build --profiles-dir .
```
