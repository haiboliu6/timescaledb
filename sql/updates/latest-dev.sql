--rewrite hypertable catalog table because previous updates messed up
--and the table is now using the missingval optimization which doesnt work
--with catalog scans; Note this is equivalent to a VACUUM FULL
--but that command cannot be used inside an update script.
CLUSTER  _timescaledb_catalog.hypertable USING hypertable_pkey;
ALTER TABLE _timescaledb_catalog.hypertable SET WITHOUT CLUSTER;

--The metadata table also has the missingval optimization;
CLUSTER  _timescaledb_catalog.metadata USING metadata_pkey;
ALTER TABLE _timescaledb_catalog.metadata SET WITHOUT CLUSTER;

GRANT SELECT ON _timescaledb_catalog.continuous_aggs_materialization_invalidation_log TO PUBLIC;
DROP FUNCTION IF EXISTS get_telemetry_report();

-- Add new function definitions, columns and tables for distributed hypertables
DROP FUNCTION IF EXISTS create_hypertable(regclass,name,name,integer,name,name,anyelement,boolean,boolean,regproc,boolean,text,regproc,regproc);

ALTER TABLE _timescaledb_catalog.hypertable ADD COLUMN replication_factor SMALLINT NULL CHECK (replication_factor > 0);

-- Table for hypertable -> servers mappings
CREATE TABLE IF NOT EXISTS _timescaledb_catalog.hypertable_server (
    hypertable_id          INTEGER NOT NULL     REFERENCES _timescaledb_catalog.hypertable(id),
    server_hypertable_id   INTEGER NULL,
    server_name            NAME NOT NULL,
    UNIQUE(server_hypertable_id, server_name),
    UNIQUE(hypertable_id, server_name)
);
SELECT pg_catalog.pg_extension_config_dump('_timescaledb_catalog.hypertable_server', '');

GRANT SELECT ON _timescaledb_catalog.hypertable_server TO PUBLIC;
