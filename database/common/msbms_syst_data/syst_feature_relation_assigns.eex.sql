-- Source File: syst_feature_relation_assigns.eex.sql
-- Location:    database/instance/msbms_syst_data/tables/syst_feature_relation_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_feature_relation_assigns
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT syst_feature_relation_assigns_pk PRIMARY KEY
    ,feature_id              uuid                                    NOT NULL
        CONSTRAINT syst_feature_relation_assigns_feature_fk
        REFERENCES msbms_syst_data.syst_features (id)
    ,relation_id             uuid                                    NOT NULL
        CONSTRAINT syst_feature_relation_assigns_relation_fk
        REFERENCES msbms_syst_data.syst_relations (id)
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_syst_data.syst_feature_relation_assigns OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_feature_relation_assigns FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_feature_relation_assigns TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_feature_relation_assigns
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_feature_relation_assigns IS
$DOC$A join table which allows application relations to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.feature_id IS
$DOC$Identifies the feature record to which the relation record is being
associated.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.relation_id IS
$DOC$Identifies the relation record which is being associates with the feature.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_relation_assigns.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
