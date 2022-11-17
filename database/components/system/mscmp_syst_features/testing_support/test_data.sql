-- File:        test_data.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/testing_support/test_data.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

--------------------------------------------------------------------------------
--  Preliminary Initialization -- Feature Mapping
--------------------------------------------------------------------------------

INSERT INTO msbms_syst_data.syst_feature_map_levels
    ( internal_name
    , display_name
    , functional_type
    , syst_description
    , system_defined
    , user_maintainable )
VALUES
    ( 'syst_settings_test_module'
    , 'Modules'
    , 'nonassignable'
    , 'Broad, top level feature grouping.'
    , TRUE
    , FALSE )
     ,
    ( 'syst_settings_test_kind'
    , 'Kinds'
    , 'assignable'
    , 'Identifies different kinds of mappable features such as forms, settings, or enumerations.'
    , TRUE
    , FALSE );

INSERT INTO msbms_syst_data.syst_feature_map
    ( internal_name
    , display_name
    , external_name
    , feature_map_level_id
    , parent_feature_map_id
    , system_defined
    , user_maintainable
    , displayable
    , syst_description
    , sort_order )
VALUES
    ( 'test_module'
    , 'Test Module'
    , 'Test Module'
    , ( SELECT
            id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'syst_settings_test_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Testing at the Module level.'
    , 1 );

INSERT INTO msbms_syst_data.syst_feature_map
    ( internal_name
    , display_name
    , external_name
    , feature_map_level_id
    , parent_feature_map_id
    , system_defined
    , user_maintainable
    , displayable
    , syst_description
    , sort_order )
VALUES
    ( 'test_settings'
    , 'Test Settings'
    , 'Test Settings'
    , ( SELECT
            id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'syst_settings_test_kind' )
    , ( SELECT id FROM msbms_syst_data.syst_feature_map WHERE internal_name = 'test_module' )
    , TRUE
    , FALSE
    , TRUE
    , 'Testing at the Kind level.'
    , 1 );

--------------------------------------------------------------------------------
--  Finalization -- Settings / Feature Map Assignments
--------------------------------------------------------------------------------

INSERT INTO msbms_syst_data.syst_feature_setting_assigns
    ( feature_map_id, setting_id )
VALUES
    ( ( SELECT id FROM msbms_syst_data.syst_feature_map WHERE internal_name = 'test_settings' )
    , ( SELECT id FROM msbms_syst_data.syst_settings WHERE internal_name = 'test_setting_one' ) )
     ,
    ( ( SELECT id FROM msbms_syst_data.syst_feature_map WHERE internal_name = 'test_settings' )
    , ( SELECT id FROM msbms_syst_data.syst_settings WHERE internal_name = 'test_setting_two' ) )
     ,
    ( ( SELECT id FROM msbms_syst_data.syst_feature_map WHERE internal_name = 'test_settings' )
    , ( SELECT id FROM msbms_syst_data.syst_settings WHERE internal_name = 'test_setting_three' ) );

--------------------------------------------------------------------------------
--  Grant all privileges to test user
--------------------------------------------------------------------------------
