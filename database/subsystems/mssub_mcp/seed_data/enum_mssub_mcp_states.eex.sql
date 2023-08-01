-- File:        enum_mssub_mcp_states.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/seed_data/enum_mssub_mcp_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DO
$INIT_ENUM_MSSUB_MCP_STATES$
    DECLARE
        var_enum_id uuid;

    BEGIN

        INSERT INTO ms_syst_data.syst_enums
            ( internal_name
            , display_name
            , syst_description
            , syst_defined
            , user_maintainable )
        VALUES
            ( 'mssub_mcp_states'
            , 'MCP States'
            , 'Defines the available values describing the MCP life-cycle states.'
            , TRUE
            , FALSE)
        RETURNING id INTO var_enum_id;

        INSERT INTO ms_syst_data.syst_enum_items
            ( internal_name
            , display_name
            , external_name
            , enum_id
            , enum_default
            , functional_type_default
            , syst_defined
            , user_maintainable
            , syst_description
            , sort_order )
        VALUES
            ( 'mssub_mcp_states_sysdef_bootstrapping'
            , 'MCP States / Bootstrapping'
            , 'Bootstrapping'
            , var_enum_id
            , TRUE
            , TRUE
            , TRUE
            , FALSE
            , 'The system is freshly installed and has not been configured.'
            , 001)

            ,
            ( 'mssub_mcp_states_sysdef_active'
            , 'MCP States / Active'
            , 'Active'
            , var_enum_id
            , FALSE
            , FALSE
            , TRUE
            , FALSE
            , 'The MCP is fully bootstrapped and ready for normal interactive use.'
            , 002);

    END;
$INIT_ENUM_MSSUB_MCP_STATES$;
