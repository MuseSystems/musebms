-- File:        enum_instance_types.eex.sql
-- Location:    musebms/database/application/msapp_platform/mssub_mcp/seed_data/enum_instance_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order )
VALUES
    ( 'instance_types_sysdef_standard'
    , 'Instance Types / Standard'
    , 'Standard'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'instance_types' )
    , TRUE
    , TRUE
    , TRUE
    , 'A simple type representing the most typical kind of Instance.'
    , 1 );
