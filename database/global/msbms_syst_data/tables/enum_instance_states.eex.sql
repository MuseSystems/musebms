
-- Source File: enum_instance_states.eex.sql
-- Location:    database/global/msbms_syst_data/tables/enum_instance_states.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.enum_instance_states
(
    id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT enum_instance_states_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL
        CONSTRAINT enum_instance_states_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT enum_instance_states_display_name_udx UNIQUE
    ,functional_type         text                                    NOT NULL
        CONSTRAINT enum_instance_states_functional_type_chk
        CHECK (functional_type in (  'uninitialized'
                                    ,'initializing'
                                    ,'active'
                                    ,'suspended'
                                    ,'inactive'
                                    ,'purge_eligible'))
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_syst_data.enum_instance_states OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.enum_instance_states FROM public;
GRANT ALL ON TABLE msbms_syst_data.enum_instance_states TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.enum_instance_states
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.enum_instance_states IS
$DOC$Establishes the available states in the life-cycle of a system instance
(msbms_syst_data.syst_instances) record, including some direction of state
related system functionality.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN  msbms_syst_data.enum_instance_states.functional_type IS
$DOC$Establishes what system recognized type the state represents.  Functional types
may determine how the system behaves in certain circumstances.  Functional types
recognized by this application:

    * uninitialized:  The instance definition record has been created, but the
                      corresponding instance has not been created on the
                      database server and is awaiting processing.

    * initializing:   The process of creating the instance has been started.

    * active:         The instance is created and usable by users.

    * suspended:      The instance is not available for regular use, though some
                      limited functionality may be available.  The instance is
                      likely visible to users for this reason.

    * inactive:       The instance is not available for any use and would not
                      typically be visible tp users for any purpose.

    * purge_eligible: The instance is not available for any use, not visible to
                      users and subject to be completely deleted from the system
                      at any point in time.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_instance_states.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
