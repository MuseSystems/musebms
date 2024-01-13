-- File:        syst_menus.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst_data/syst_menus/syst_menus.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_menus
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_menus_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_menus_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_menus_display_name_udx UNIQUE
    ,menu_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_menus_menu_state_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
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

ALTER TABLE ms_syst_data.syst_menus OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_menus FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_menus TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_menus
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_menu_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_menus
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('menu_states', 'menu_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_menu_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_menus
    FOR EACH ROW WHEN ( old.menu_state_id != new.menu_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'menu_states', 'menu_state_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_menu_state_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_menus';

    var_comments_config.description :=
$DOC$Establishes user configurable menu and navigation definitions for use in the
User Interfaces of the application.$DOC$;

    --
    -- Column Configs
    --

    var_menu_state_id.column_name := 'menu_state_id';
    var_menu_state_id.description :=
$DOC$Indicates at which life-cycle stage the record exists.  Functionally, this
breaks down into "active" and "inactive" states.$DOC$;

    var_comments_config.columns :=
        ARRAY [ var_menu_state_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
