-- File:        settings.eex.sql
-- Location:    musebms/database/application/msapp_platform/mssub_mcp/seed_data/settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_settings
    ( internal_name
    , display_name
    , syst_defined
    , syst_description
    , setting_uuid
    , setting_integer )
VALUES
    ( 'mssub_mcp_state'
    , 'MCP State'
    , TRUE
    , 'Defines the current installation and runtime state of the MCP as a whole.  ' ||
      'Valid values are drawn from the system enumeration "mssub_mcp_states".'
    , (SELECT id FROM ms_syst_data.syst_enum_items WHERE internal_name = 'mssub_mcp_states_sysdef_bootstrapping')
    , NULL::integer )
  , ( 'mcp_owner'
    , 'Platform Owner'
    , TRUE
    , 'Identifies the Platform Owner once the system is bootstrapped.  ' ||
      'The system assumes that all Platform Administrator Access Accounts ' ||
      'are owned by the Platform Owner defined in this configuration point.'
    , NULL::uuid
    , NULL::integer )
  , ( 'mssub_mcp_session_expiration'
    , 'MCP Session Expiration'
    , TRUE
    , 'The number of seconds after which stale user interface session ' ||
      'records should be considered expired and eligible for purging.'
    , NULL::uuid
    , (3600)::integer );
