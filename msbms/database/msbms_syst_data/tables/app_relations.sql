-- File:        app_relations.sql
-- Location:    msbms/database/msbms_syst_data/tables/app_relations.sql
-- Project:     Muse Systems Business Management System
--
-- Licensed to Lima Buttgereit Holdings LLC (d/b/a Muse Systems) under one or
-- more agreements.  Muse Systems licenses this file to you under the terms and
-- conditions of your Muse Systems Master Services Agreement or governing
-- Statement of Work.
--
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.app_relations
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT app_relations_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL
        CONSTRAINT app_relations_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT app_relations_display_name_udx UNIQUE
    ,schema_name             text                                    NOT NULL
    ,table_name              text                                    NOT NULL
    ,app_feature_type_id     uuid                                    NOT NULL
        CONSTRAINT app_relations_app_feature_type_fk
        REFERENCES msbms_syst_data.app_feature_types ( id )
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
    ,CONSTRAINT app_relations_schema_table_udx
        UNIQUE ( schema_name, table_name )
);

ALTER TABLE msbms_syst_data.app_relations OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_syst_data.app_relations FROM public;
GRANT ALL ON TABLE msbms_syst_data.app_relations TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.app_relations
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.app_relations IS
$DOC$A list of the application tables and associated metadata that is not normally
part of the table definition kept in the catalog.  This includes categorization
by the feature type and association with forms and operations that may make use
of the relation.  Finally, this serves to associate enum values to the relations
to which they pertain.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.internal_name IS
$DOC$A candidate key useful for programatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.schema_name IS
$DOC$The schema name where the record's table resides.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.table_name IS
$DOC$The name of the relation that is the subject of the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.app_feature_type IS
$DOC$Categorizes the record according to its feature type.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.app_relations.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
