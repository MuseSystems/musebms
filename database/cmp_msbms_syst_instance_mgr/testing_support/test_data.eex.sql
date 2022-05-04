-- File:        test_data.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\testing_support\test_data.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

--
--  Applications
--

INSERT INTO msbms_syst_data.syst_applications
    ( internal_name, display_name, syst_description )
VALUES
    ( 'test_app_2', 'Test App 2', 'Test App Two Description' )
     ,
    ( 'test_app_1', 'Test App 1', 'Test App One Description' );

--
--  Owners
--


INSERT INTO msbms_syst_data.syst_owners
    ( internal_name, display_name, owner_state_id )
VALUES
    ( 'owner_4', 'Owner 4 Inactive', ( SELECT id
                                         FROM msbms_syst_data.syst_enum_items
                                         WHERE internal_name = 'owner_states_sysdef_inactive' ) )
     ,
    ( 'owner_3', 'Owner 3 Active', ( SELECT id
                                         FROM msbms_syst_data.syst_enum_items
                                         WHERE internal_name = 'owner_states_sysdef_active' ) )
     ,
    ( 'owner_1', 'Owner 1 Active', ( SELECT id
                                       FROM msbms_syst_data.syst_enum_items
                                       WHERE internal_name = 'owner_states_sysdef_active' ) )
     ,
    ( 'owner_2', 'Owner 2 Inactive', ( SELECT id
                                          FROM msbms_syst_data.syst_enum_items
                                          WHERE internal_name = 'owner_states_sysdef_inactive' ) );
