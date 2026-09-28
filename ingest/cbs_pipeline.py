"""Land CBS StatLine tables as parquet in S3 with dlt.

Each CBS table is an OData v3 service: TypedDataSet (facts) plus one entity set
per dimension (Key/Title/...). We land both, per table, under

    s3://<bucket>/raw/cbs/<name>/            (facts)
    s3://<bucket>/raw/cbs/<name>__<dim>/     (dimension, dim lowercased)

with write_disposition=replace, so each folder is exactly the latest snapshot.
dbt bronze reads the folders with SQE's read_parquet().

Env: CBS_LANDING_BUCKET_URL (default s3://cbs-landing/raw), plus dlt's standard
DESTINATION__FILESYSTEM__CREDENTIALS__{AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,
ENDPOINT_URL}. For a local dry run: CBS_LANDING_BUCKET_URL=file:///tmp/cbs.
"""

import os

import dlt
from dlt.sources.helpers import requests

# ODataFeed, not ODataApi: only the feed pages (odata.nextLink) past 10k rows.
ODATA = "https://opendata.cbs.nl/ODataFeed/odata"

# name -> (CBS table id, dimensions)
TABLES = {
    "energy_use_dwellings": ("81528NED", ["Woningkenmerken", "RegioS", "Perioden"]),
    "energy_tariffs": ("85592NED", ["Btw", "Perioden"]),
}


def odata_rows(url: str):
    """Yield every row of an OData v3 entity set, following odata.nextLink."""
    params = {"$format": "json"}
    while url:
        page = requests.get(url, params=params).json()
        yield from page["value"]
        url, params = page.get("odata.nextLink"), None  # nextLink carries its own query


def strip(row: dict) -> dict:
    # CBS pads codes ("NL01  "); strip so joins on Key work downstream.
    return {k: v.strip() if isinstance(v, str) else v for k, v in row.items()}


@dlt.source(name="cbs")
def cbs(tables: dict = TABLES):
    for name, (table_id, dims) in tables.items():
        yield dlt.resource(
            (strip(r) for r in odata_rows(f"{ODATA}/{table_id}/TypedDataSet")),
            name=name, write_disposition="replace",
        )
        for dim in dims:
            yield dlt.resource(
                (strip(r) for r in odata_rows(f"{ODATA}/{table_id}/{dim}")),
                name=f"{name}__{dim.lower()}", write_disposition="replace",
            )


def run() -> None:
    pipeline = dlt.pipeline(
        pipeline_name="cbs_landing",
        destination=dlt.destinations.filesystem(
            bucket_url=os.environ.get("CBS_LANDING_BUCKET_URL", "s3://cbs-landing/raw"),
            layout="{table_name}/{load_id}.{file_id}.{ext}",
        ),
        dataset_name="cbs",
    )
    print(pipeline.run(cbs(), loader_file_format="parquet"))


if __name__ == "__main__":
    run()
