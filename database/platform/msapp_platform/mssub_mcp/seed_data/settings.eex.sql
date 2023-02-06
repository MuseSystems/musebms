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
    , setting_uuid )
VALUES
    ( 'platform_state'
    , 'Platform State'
    , TRUE
    , 'Defines the current installation and runtime state of the platform as a whole.  ' ||
      'Valid values are drawn from the system enumeration "platform_states".'
    , (SELECT id FROM ms_syst_data.syst_enum_items WHERE internal_name = 'platform_states_sysdef_bootstrapping') )
  , ( 'platform_owner'
    , 'Platform Owner'
    , TRUE
    , 'Identifies the Platform Owner once the system is bootstrapped.  ' ||
      'The system assumes that all Platform Administrator Access Accounts ' ||
      'are owned by the Platform Owner defined in this configuration point.'
    , NULL::uuid );
