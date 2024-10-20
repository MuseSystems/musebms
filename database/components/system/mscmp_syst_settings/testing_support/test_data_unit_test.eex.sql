-- File:        test_data_unit_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/testing_support/test_data_unit_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

--------------------------------------------------------------------------------
--  Primary Initialization -- Settings
--------------------------------------------------------------------------------

INSERT INTO ms_syst_data.syst_settings
    ( internal_name
    , display_name
    , syst_defined
    , syst_description
    , user_description
    , setting_flag
    , setting_integer
    , setting_integer_range
    , setting_decimal
    , setting_decimal_range
    , setting_interval
    , setting_date
    , setting_date_range
    , setting_time
    , setting_timestamp
    , setting_timestamp_range
    , setting_json
    , setting_text
    , setting_uuid
    , setting_blob )
VALUES
    ( 'test_setting_one'
    , 'Test Setting One'
    , TRUE
    , 'Test Setting One System Description'
    , 'Test Setting One User Description'
    , TRUE
    , 111
    , int8range(1,11)
    , 111.111
    , numrange(1.1, 11.11)
    , '1 month'::interval
    , '2022-01-01'::date
    ,  daterange('2022-01-01'::date, '2023-01-01'::date)
    , '01:00'::time
    , '2022-01-01 01:00:00Z'::timestamptz
    , tstzrange('2022-01-01 01:00:00Z'::timestamptz, 'infinity'::timestamptz)
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
    , TRUE
    , 'Test Setting Two System Description'
    , 'Test Setting Two User Description'
    , FALSE
    , 222
    , int8range(2,22)
    , 222.222
    , numrange(2.2, 22.22)
    , '2 days'::interval
    , '2022-01-02'::date
    ,  daterange('2022-01-02'::date, '2023-01-02'::date)
    , '02:00'::time
    , '2022-01-02 02:00:00'::timestamptz
    , tstzrange('2022-01-02 02:00:00'::timestamptz, 'infinity'::timestamptz)
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
    , TRUE
    , 'Test Setting Three System Description'
    , 'Test Setting Three User Description'
    , TRUE
    , 333
    , int8range(3,33)
    , 333.333
    , numrange(3.3, 33.33)
    , '3000000 microseconds'::interval
    , '2022-01-03'::date
    ,  daterange('2022-01-03'::date, '2023-01-03'::date)
    , '03:00'::time
    , '2022-01-03 03:00:00'::timestamptz
    , tstzrange('2022-01-03 03:00:00'::timestamptz, 'infinity'::timestamptz)
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
