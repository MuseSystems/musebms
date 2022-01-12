
-- Source File: syst_instances.eex.sql
-- Location:    msbms/database/global/msbms_syst_data/tables/syst_instances.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_instances
(
     id                       uuid        DEFAULT uuid_generate_v1( )  NOT NULL
        CONSTRAINT syst_instances_pk PRIMARY KEY
    ,internal_name            text                                     NOT NULL
        CONSTRAINT syst_instances_internal_name_udx UNIQUE
    ,display_name             text                                     NOT NULL
        CONSTRAINT syst_instances_display_name_udx UNIQUE
    ,enum_instance_type_id    uuid                                     NOT NULL
        CONSTRAINT syst_instances_enum_instance_type_fk
        REFERENCES msbms_syst_data.enum_instance_types (id)
    ,enum_instance_state_id   uuid                                     NOT NULL
        CONSTRAINT syst_instances_enum_instance_state_fk
        REFERENCES msbms_syst_data.enum_instance_states (id)
    ,dbserver_name            text                                     NOT NULL
    ,db_app_context_pool_size integer     DEFAULT 10                   NOT NULL
        CONSTRAINT syst_instances_db_app_context_pool_size_no_neg_chk
        CHECK (db_app_context_pool_size > 0)
    ,db_api_context_pool_size integer     DEFAULT 3                    NOT NULL
        CONSTRAINT syst_instances_db_api_context_pool_size_no_neg_chk
        CHECK (db_api_context_pool_size > 0)
    ,instance_code            bytea       DEFAULT gen_random_bytes(32) NOT NULL
    ,owning_instance_id       uuid
        CONSTRAINT syst_instances_owning_instance_fk
        REFERENCES msbms_syst_data.syst_instances (id)
        CONSTRAINT syst_instances_self_ownership_chk
        CHECK (owning_instance_id IS NULL OR owning_instance_id != id)
    ,diag_timestamp_created   timestamptz DEFAULT now( )               NOT NULL
    ,diag_role_created        text                                     NOT NULL
    ,diag_timestamp_modified  timestamptz DEFAULT now( )               NOT NULL
    ,diag_wallclock_modified  timestamptz DEFAULT clock_timestamp( )   NOT NULL
    ,diag_role_modified       text                                     NOT NULL
    ,diag_row_version         bigint      DEFAULT 1                    NOT NULL
    ,diag_update_count        bigint      DEFAULT 0                    NOT NULL
);

ALTER TABLE msbms_syst_data.syst_instances OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_instances FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_instances TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_instances IS
$DOC$Defines known application instances and provides their configuration settings.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.enum_instance_type_id IS
$DOC$Indicates the type of the instance.  This can designate instances as being
production or non-production, or make other functional differences between
instances created for different reasons based on the assigned instance type.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.enum_instance_state_id IS
$DOC$Establishes the current life-cycle state of the instance record.  This can
determine functionality such as if the instance is usable, visible, or if it may
be purged from the database completely.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.dbserver_name IS
$DOC$References a database server found in the msbms_startup_options.toml file.
While this file may override certain defaults set for the server in that file,
we need to use the references in that file to know where we should connect.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.db_app_context_pool_size IS
$DOC$The number of pooled database connections available to the application access
context.  The application will checkout connections from the pool as needed and
otherwise queue requests as necessary (within limits).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.db_api_context_pool_size IS
$DOC$The number of pooled database connections available to the API access context.
The application will checkout connections from the pool as needed and otherwise
queue requests as necessary (within limits).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.instance_code IS
$DOC$A randomly generated sequence of bytes used in instance database connection
authentication.  Note that this value, while random, should be no fewer than 32
bytes long.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.owning_instance_id IS
$DOC$In some cases, an instance is considered subordinate to another instance.  For
example, consider a production environment and a related sandbox environment.
The existence of the sandbox doesn't have real meaning without being associated
with some sort of production instance where the real work is performed.  This
kind of association becomes clearer in SaaS environments where a primary
instance is contracted for, but other supporting instances, such as a sandbox,
should follow certain account related actions of the primary.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
