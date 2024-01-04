-- File:        test_data_doc_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/testing_support/test_data_doc_test.eex.sql
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
    ( 'get_example_setting'
    , 'Get Example Settings'
    , TRUE
    , 'An example setting for retrieving values'
    , NULL
    , TRUE
    , 9876
    , int8range(1,9)
    , 987.654
    , numrange(1.1, 99.99)
    , '987000 microseconds'::interval
    , '2022-01-03'::date
    ,  daterange('2022-01-03'::date, '2023-01-03'::date)
    , '03:00'::time
    , '2022-01-03 03:00:00'::timestamptz
    , tstzrange('2022-01-03 03:00:00'::timestamptz, 'infinity'::timestamptz)
    , $JSON_TEST$
      {
        "get_example_setting": {
          "nested_example": "nested_example_value"
        },
        "get_example_setting_number": 5432,
        "get_example_setting_boolean": true
      }
      $JSON_TEST$::jsonb
    , 'Get Example Setting Text'
    , '47241948-b2c9-11ec-b8c4-00155d708817'::uuid
    , convert_to( 'Get Example Setting Bytea', 'UTF8' ) )
     ,
    ( 'set_example_setting'
    , 'Set Example Settings'
    , TRUE
    , 'An example setting for setting values'
    , NULL
    , TRUE
    , 9876
    , int8range(1,9)
    , 987.654
    , numrange(1.1, 99.99)
    , '987000 microseconds'::interval
    , '2022-01-03'::date
    ,  daterange('2022-01-03'::date, '2023-01-03'::date)
    , '03:00'::time
    , '2022-01-03 03:00:00'::timestamptz
    , tstzrange('2022-01-03 03:00:00'::timestamptz, 'infinity'::timestamptz)
    , $JSON_TEST$
      {
        "set_example_setting": {
          "nested_example": "nested_example_value"
        },
        "set_example_setting_number": 5432,
        "set_example_setting_boolean": true
      }
      $JSON_TEST$::jsonb
    , 'Set Example Setting Text'
    , '47241948-b2c9-11ec-b8c4-00155d708817'::uuid
    , convert_to( 'Set Example Setting Bytea', 'UTF8' ) )
     ,
    ( 'delete_example_setting'
    , 'Delete Example Settings'
    , FALSE
    , '(System Description Not Applicable)'
    , 'An example setting for deleting values'
    , TRUE
    , 9876
    , int8range(1,9)
    , 987.654
    , numrange(1.1, 99.99)
    , '987000 microseconds'::interval
    , '2022-01-03'::date
    ,  daterange('2022-01-03'::date, '2023-01-03'::date)
    , '03:00'::time
    , '2022-01-03 03:00:00'::timestamptz
    , tstzrange('2022-01-03 03:00:00'::timestamptz, 'infinity'::timestamptz)
    , $JSON_TEST$
      {
        "delete_example_setting": {
          "nested_example": "nested_example_value"
        },
        "delete_example_setting_number": 5432,
        "delete_example_setting_boolean": true
      }
      $JSON_TEST$::jsonb
    , 'Delete Example Setting Text'
    , '47241948-b2c9-11ec-b8c4-00155d708817'::uuid
    , convert_to( 'Delete Example Setting Bytea', 'UTF8' ) );

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ms_syst      TO <%= ms_appusr %>;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ms_syst_priv TO <%= ms_appusr %>;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ms_syst_data TO <%= ms_appusr %>;
