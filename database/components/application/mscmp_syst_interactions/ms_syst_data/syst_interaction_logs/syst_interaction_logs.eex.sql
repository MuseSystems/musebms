-- File:        syst_interaction_logs.eex.sql
-- Location:    musebms/database/components/application/mscmp_syst_interactions/ms_syst_data/syst_interaction_logs/syst_interaction_logs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_interaction_logs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_interaction_timestamp ms_syst_priv.comments_config_table_column;
    var_interaction_type_id   ms_syst_priv.comments_config_table_column;
    var_interface_type_id     ms_syst_priv.comments_config_table_column;
    var_data                  ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_interaction_logs';

    var_comments_config.description :=
$DOC$Records interactions to drive both system functionality and to provide usage
telemetry.$DOC$;

    --
    -- Column Configs
    --

    var_interaction_timestamp.column_name := 'interaction_timestamp';
    var_interaction_timestamp.description :=
$DOC$The nominal time at which the event being recorded is considered to have
happened.  This is the database transaction start time specifically.$DOC$;

    var_interaction_type_id.column_name := 'interaction_type_id';
    var_interaction_type_id.description :=
$DOC$The kind of interaction being recorded.$DOC$;

    var_interface_type_id.column_name := 'interface_type_id';
    var_interface_type_id.description :=
$DOC$The origin entry point into the application and from which the activity was
initiated.$DOC$;

    var_data.column_name := 'data';
    var_data.description :=
$DOC$Optional document style data which may more completely elaborate on the activity
being recorded.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_interaction_timestamp
            , var_interaction_type_id
            , var_interface_type_id
            , var_data
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;

COMMENT ON
    INDEX ms_syst_data.syst_interaction_logs_interaction_timestamp_idx IS
$DOC$Allows faster searching of specific actions filtering by time; useful for
rate limiting, etc.$DOC$;
