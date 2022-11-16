-- File:        syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/msbms_syst_data/syst_instance_type_contexts/syst_instance_type_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_instance_type_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_type_contexts_pk PRIMARY KEY
    ,instance_type_application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_contexts_inst_type_app_fk
            REFERENCES msbms_syst_data.syst_instance_type_applications (id)
            ON DELETE CASCADE
    ,application_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_contexts_application_contexts_fk
            REFERENCES msbms_syst_data.syst_application_contexts (id)
            ON DELETE CASCADE
    ,default_db_pool_size
        integer
        NOT NULL DEFAULT 0
        CONSTRAINT syst_instance_type_contexts_default_db_pool_size_chk
            CHECK ( default_db_pool_size >= 0 )
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT syst_instance_type_contexts_instance_types_applications_udx
        UNIQUE (instance_type_application_id, application_context_id)
);

ALTER TABLE msbms_syst_data.syst_instance_type_contexts OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_instance_type_contexts FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_instance_type_contexts TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_instance_type_contexts IS
$DOC$Establishes Instance Type defaults for each of an Application's defined
datastore contexts.  In practice, these records are used in the creation of
Instance Context records, but do not establish a direct relationship; records in
this table simply inform us what Instance Contexts should exist and give us
default values to use in their creation.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.instance_type_application_id IS
$DOC$The Instance Type/Application association to which the context definition
belongs.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.application_context_id IS
$DOC$The Application Context which is being represented in the Instance Type.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.default_db_pool_size IS
$DOC$A default pool size which is assigned to new Instances of the Instance Type
unless the creator of the Instance specifies a different value.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_type_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
