-- File:        syst_owners.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_owners/syst_owners.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_owners
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_owners_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_owners_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_owners_display_name_udx UNIQUE
    ,owner_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_owner_owner_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
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

ALTER TABLE ms_syst_data.syst_owners OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_owners FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_owners TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_owner_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('owner_states', 'owner_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_owner_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_owners
    FOR EACH ROW WHEN ( old.owner_state_id != new.owner_state_id )EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('owner_states', 'owner_state_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns

    var_owner_state_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_owners';

    var_comments_config.description :=
$DOC$Identifies instance owners.  Instance owners are typically the clients which
have commissioned the use of an application instance.$DOC$;

    --
    -- Column Configs
    --

    var_owner_state_id.column_name := 'owner_state_id';
    var_owner_state_id.description :=
$DOC$Establishes the current life-cycle state in which Instance Owner record
currently resides.$DOC$;

    var_comments_config.columns :=
        ARRAY [ var_owner_state_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
