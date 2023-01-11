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
    ( 'msplatform_state'
    , 'Platform State'
    , TRUE
    , 'Defines the current installation and runtime state of the platform as a whole.  ' ||
      'Valid values are drawn from the system enumeration "platform_states".'
    , (SELECT id FROM ms_syst_data.syst_enum_items WHERE internal_name = 'platform_states_sysdef_bootstrapping') );
