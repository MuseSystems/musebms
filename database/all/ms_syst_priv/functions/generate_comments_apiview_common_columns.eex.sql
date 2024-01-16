CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_apiview_common_columns(
        p_view_config ms_syst_priv.comments_config_apiview )
RETURNS void AS
$BODY$

-- File:        generate_comments_apiview_common_columns.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_apiview_common_columns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE
    var_table regclass :=
        (p_view_config.table_schema || '.' || p_view_config.table_name)::regclass;

    var_columns jsonb := $API_VIEW_COMMON_COLUMNS$
    [
      {
        "column_name": "id",
        "unique_values": true,
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "internal_name",
        "required": true,
        "unique_values": true
      },
      {
        "column_name": "display_name",
        "required": true,
        "unique_values": true,
        "syst_update_mode": "maint"
      },
      {
        "column_name": "external_name",
        "required": true,
        "syst_update_mode": "maint"
      },
      {
        "column_name": "syst_defined",
        "default_value": "`FALSE`",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "user_maintainable",
        "default_value": "`TRUE`",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "syst_description",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "user_description",
        "syst_update_mode": "always"
      },
      {
        "column_name": "diag_timestamp_created",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "diag_role_created",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "diag_timestamp_modified",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "diag_wallclock_modified",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "diag_role_modified",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "diag_row_version",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      },
      {
        "column_name": "diag_update_count",
        "default_value": "Automatically Generated",
        "user_insert": false,
        "user_update": false
      }
    ]
    $API_VIEW_COMMON_COLUMNS$::jsonb;

BEGIN

    PERFORM
        ms_syst_priv.generate_comments_apiview_column(
            p_view_config   => p_view_config,
            p_column_config =>
                jsonb_populate_record(
                    NULL::ms_syst_priv.comments_config_apiview_column, c ) )
    FROM
        jsonb_array_elements( var_columns ) c
            JOIN pg_attribute pa
                ON c ->> 'column_name' = pa.attname::text
    WHERE
          pa.attrelid = var_table
      AND pa.attnum > 0
      AND NOT pa.attisdropped;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_apiview_common_columns(
        p_view_config ms_syst_priv.comments_config_apiview )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_apiview_common_columns(
        p_view_config ms_syst_priv.comments_config_apiview )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_apiview_common_columns(
        p_view_config ms_syst_priv.comments_config_apiview )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;
    
    -- Parameters
    var_p_view_config ms_syst_priv.comments_config_function_param;

BEGIN
    
    --
    -- Function Config
    --
    
    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'generate_comments_apiview_common_columns';

    var_comments_config.description :=
$DOC$Provides boilerplate API View Column comment configurations and generates the
comments for columns which appear in many places across the applications and
where standardized descriptions are likely to apply.$DOC$;

    var_comments_config.general_usage :=
$DOC$This function expects that a there is a closely associated Data Table defined.
The Data Table columns provide the descriptive texts for the related API View
columns.  If the API View is not closely associated with an underlying Data
Table, common columns should be configured manually as regular API View Columns
and passed directly to either `ms_syst_priv.generate_comments_apiview` or
`ms_syst_priv.generate_comments_apiview_column` as appropriate.$DOC$;
    
    --
    -- Parameter Configs
    -- 

    var_p_view_config.param_name := 'p_view_config';
    var_p_view_config.description :=
$DOC$A required value of type `ms_syst_priv.comments_config_apiview`.  This value
provides the basic comments configuration data used to determine to which
API View to apply common column comments, find which columns may be present,
etc.  Only the fields of the value below are used by this function:

  * `view_schema`  - (required)
  * `view_name`    - (required)
  * `table_schema` - (required)
  * `table_name`   - (required)
  * `user_records` - (optional)
  * `user_insert`  - (optional)
  * `user_select`  - (optional)
  * `user_update`  - (optional)
  * `syst_records` - (optional)
  * `syst_select`  - (optional)
  * `syst_update`  - (optional)

Any fields passed as `NULL` will assume their default values.  See the
database type documentation for more information, including to find any
defined field level default values.  Failing to provide a `table_schema` and
`table_name` will not raise an exception, but may produce unsatisfactory
results.  In cases where the API View is not strongly associated with a Data
Table, common columns should be documentend manually.$DOC$;


    var_comments_config.params :=
        ARRAY [ var_p_view_config ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
