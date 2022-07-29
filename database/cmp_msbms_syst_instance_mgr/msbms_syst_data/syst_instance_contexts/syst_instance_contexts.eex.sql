-- File:        syst_instance_contexts.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_instance_mgr/msbms_syst_data/syst_instance_contexts/syst_instance_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_instance_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_contexts_pk PRIMARY KEY
    ,internal_name
        text COLLATE msbms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_instance_contexts_internal_name_udx UNIQUE
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_contexts_instances_fk
            REFERENCES msbms_syst_data.syst_instances (id)
            ON DELETE CASCADE
    ,application_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_contexts_application_contexts_fk
            REFERENCES msbms_syst_data.syst_application_contexts (id)
            ON DELETE CASCADE
    ,start_context
        boolean
        NOT NULl DEFAULT false
    ,db_pool_size
        integer
        NOT NULL DEFAULT 0
        CONSTRAINT syst_instance_contexts_db_pool_size_chk
            CHECK ( db_pool_size >= 0 )
    ,context_code
        bytea
        NOT NULL
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
);

ALTER TABLE msbms_syst_data.syst_instance_contexts OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_instance_contexts FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_instance_contexts TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_instance_contexts
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_instance_contexts IS
$DOC$Instance specific settings which determine how each Instance connects to the
defined Application Contexts.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.instance_id IS
$DOC$Identifies the parent Instance for which Instance Contexts are being defined.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.application_context_id IS
$DOC$Identifies the Application Context which is being defined for the Instance.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.start_context IS
$DOC$If true, indicates that the Instance Context should be started, so long as the
Application Context record is also set to allow context starting.  If false, the
Instance Context not be started, even if the related Application Context is set
to allow context starts.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.db_pool_size IS
$DOC$If the Application Context is a login datastore context, this value establishes
how many database connections to open on behalf of this Instance Context.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.context_code IS
$DOC$An Instance Context specific series of bytes which are used in algorithmic
credential generation.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instance_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
