-- File:        syst_interaction_logs.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/ms_syst_data/syst_interaction_logs/syst_interaction_logs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_interaction_logs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_interaction_logs_pk PRIMARY KEY
    ,interaction_timestamp
        timestamptz
        NOT NULL DEFAULT now()
    ,interaction_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_interaction_logs_interaction_types_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,interface_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_interaction_logs_interface_types_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,data
        jsonb
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_interaction_logs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_interaction_logs FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_interaction_logs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_interaction_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('interaction_types', 'interaction_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_interaction_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW WHEN ( old.interaction_type_id != new.interaction_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'interaction_types', 'interaction_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_interface_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('interface_types', 'interface_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_interface_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW WHEN ( old.interface_type_id != new.interface_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'interface_types', 'interface_type_id');

CREATE INDEX syst_interaction_logs_interaction_timestamp_idx
    ON ms_syst_data.syst_interaction_logs USING brin (interaction_timestamp);

COMMENT ON
    TABLE ms_syst_data.syst_interaction_logs IS
$DOC$Records interactions to drive both system functionality and to provide usage
telemetry.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.interaction_timestamp IS
$DOC$The nominal time at which the event being recorded is considered to have
happened.  This is the database transaction start time specifically.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.interaction_type_id IS
$DOC$The kind of interaction being recorded.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.interface_type_id IS
$DOC$The origin entry point into the application and from which the activity was
initiated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.data IS
$DOC$Optional document style data which may more completely elaborate on the activity
being recorded.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

COMMENT ON
    INDEX ms_syst_data.syst_interaction_logs_interaction_timestamp_idx IS
$DOC$Allows faster searching of specific actions filtering by time; useful for
rate limiting, etc.$DOC$;
