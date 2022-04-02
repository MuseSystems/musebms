-- File:        test_data.eex.sql
-- Location:    database\cmp_msbms_syst_settings\testing_support\test_data.eex.sql
-- Project:     Muse Business Management System
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
--  Primary Initialization -- Settings
--------------------------------------------------------------------------------

INSERT INTO msbms_syst_data.syst_settings
    ( internal_name
    , display_name
    , syst_description
    , user_description
    , config_flag
    , config_integer
    , config_decimal
    , config_interval
    , config_date
    , config_time
    , config_timestamp
    , config_json
    , config_text
    , config_uuid
    , config_blob )
VALUES
    ( 'test_setting_one'
    , 'Test Setting One'
    , 'Test Setting One System Description'
    , 'Test Setting One User Description'
    , TRUE
    , 111
    , 111.111
    , '1 month'::interval
    , '2022-01-01'::date
    , '01:00'::time
    , '2022-01-01 01:00:00'::timestamptz
    , $JSON_TEST$
      {
        "test_settings_one": {
          "nested_test": "nested_test_value"
        },
        "test_settings_one_number": 1111,
        "test_settings_one_boolean": true
      }
      $JSON_TEST$::jsonb
    , 'Test Setting One Text'
    , 'bbd4d590-b2c7-11ec-a45c-00155d708817'::uuid
    , convert_to( 'Test Setting One Bytea', 'UTF8' ) )
     ,
    ( 'test_setting_two'
    , 'Test Setting Two'
    , 'Test Setting Two System Description'
    , 'Test Setting Two User Description'
    , FALSE
    , 222
    , 222.222
    , '2 days'::interval
    , '2022-01-02'::date
    , '02:00'::time
    , '2022-01-02 02:00:00'::timestamptz
    , $JSON_TEST$
      {
        "test_settings_two": {
          "nested_test": "nested_test_value"
        },
        "test_settings_two_number": 2222,
        "test_settings_two_boolean": false
      }
      $JSON_TEST$::jsonb
    , 'Test Setting Two Text'
    , '47241948-b2c9-11ec-b8c4-00155d708817'::uuid
    , convert_to( 'Test Setting Two Bytea', 'UTF8' ) )
     ,
    ( 'test_setting_three'
    , 'Test Setting Three'
    , 'Test Setting Three System Description'
    , 'Test Setting Three User Description'
    , TRUE
    , 333
    , 333.333
    , '3000000 microseconds'::interval
    , '2022-01-03'::date
    , '03:00'::time
    , '2022-01-03 03:00:00'::timestamptz
    , $JSON_TEST$
      {
        "test_settings_three": {
          "nested_test": "nested_test_value"
        },
        "test_settings_three_number": 3333,
        "test_settings_three_boolean": true
      }
      $JSON_TEST$::jsonb
    , 'Test Setting Three Text'
    , '47241948-b2c9-11ec-b8c4-00155d708817'::uuid
    , convert_to( 'Test Setting Three Bytea', 'UTF8' ) );

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
