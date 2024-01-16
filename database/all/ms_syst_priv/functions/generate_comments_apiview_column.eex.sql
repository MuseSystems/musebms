CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_apiview_column(
        p_view_config   ms_syst_priv.comments_config_apiview,
        p_column_config ms_syst_priv.comments_config_apiview_column)
RETURNS void AS
$BODY$

-- File:        generate_comments_apiview_column.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_apiview_column.eex.sql
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
    var_src_table regclass;

    var_defaulted_view ms_syst_priv.comments_config_apiview;

    var_defaulted_column ms_syst_priv.comments_config_apiview_column;

    var_resolved_col_desc text;
    var_resolved_col_reqs text;
    var_resolved_col_sops text := '';
    var_resolved_col_uops text := '';
    var_resolved_col_supp text;

    var_col_syst_update_mode ms_syst_priv.comments_apiview_update_modes;

    var_column_comment text;

BEGIN

    var_src_table :=
        ( p_view_config.table_schema || '.' ||
            p_view_config.table_name )::regclass;

    var_defaulted_view.user_records :=
        coalesce( p_view_config.user_records, TRUE );

    var_defaulted_view.user_insert :=
        var_defaulted_view.user_records AND
        coalesce( p_view_config.user_insert, TRUE );

    var_defaulted_view.user_select :=
        var_defaulted_view.user_records AND
        coalesce( p_view_config.user_select, TRUE );

    var_defaulted_view.user_update :=
        var_defaulted_view.user_records AND
        coalesce( p_view_config.user_update, TRUE );

    var_defaulted_view.user_delete :=
        var_defaulted_view.user_records AND
        coalesce( p_view_config.user_delete, TRUE );

    var_defaulted_view.syst_records :=
        coalesce( p_view_config.syst_records, FALSE );

    var_defaulted_view.syst_select :=
        var_defaulted_view.syst_records AND
        coalesce( p_view_config.syst_select, TRUE );

    var_defaulted_view.syst_update :=
        var_defaulted_view.syst_records AND
        coalesce( p_view_config.syst_update, FALSE );

    var_defaulted_view.syst_delete :=
        var_defaulted_view.syst_records AND
        coalesce( p_view_config.syst_delete, FALSE );

    var_defaulted_column.required :=
        coalesce( p_column_config.required, FALSE );

    var_defaulted_column.unique_values :=
        coalesce( p_column_config.unique_values, FALSE );

    var_defaulted_column.default_value :=
        coalesce( p_column_config.default_value, '( No Default Value )' );

    var_defaulted_column.user_insert :=
        var_defaulted_view.user_records AND
        var_defaulted_view.user_insert AND
        coalesce( p_column_config.user_insert, TRUE );

    var_defaulted_column.user_select :=
        var_defaulted_view.user_records AND
        var_defaulted_view.user_select AND
        coalesce( p_column_config.user_select, TRUE );

    var_defaulted_column.user_update :=
        var_defaulted_view.user_records AND
        var_defaulted_view.user_update AND
        coalesce( p_column_config.user_update, TRUE );

    var_defaulted_column.syst_select :=
        var_defaulted_view.syst_records AND
        coalesce( p_column_config.syst_select, TRUE );

    var_defaulted_column.syst_update_mode :=
        CASE
            WHEN
                var_defaulted_view.syst_records AND
                var_defaulted_view.syst_update
            THEN
                coalesce( p_column_config.syst_update_mode, 'never' )
            ELSE
                'never'
        END;

    var_resolved_col_desc :=
        coalesce(
            p_column_config.override_description,
            ( SELECT
                  regexp_substr(
                      pd.description,
                      '^(?:(?!\n\*\*Direct Usage\*\*).)*',
                      1, 1 )
              FROM
                  pg_catalog.pg_attribute pa
                      LEFT JOIN pg_catalog.pg_description pd
                                ON pd.objoid = var_src_table
                                    AND pd.classoid = 'pg_catalog.pg_class'::regclass
                                    AND pd.objsubid = pa.attnum
              WHERE
                    pa.attrelid = var_src_table
                AND pa.attname = p_column_config.column_name
                AND pa.attnum > 0
                AND NOT pa.attisdropped ),
            '( Source column is not documented. )' );

    var_resolved_col_reqs :=
        E'**Data Requirements**\n\n  * Required?:               ' ||
        var_defaulted_column.required ||
        E'\n  * Unique Values Required?: ' ||
        var_defaulted_column.unique_values ||
        E'\n  * Default Value:           ' ||
        var_defaulted_column.default_value;

    IF var_defaulted_view.syst_records THEN

        var_resolved_col_sops :=
            E'**System Defined Record Supported Operations**\n\n' ||
                CASE
                    WHEN var_defaulted_column.syst_select THEN
                        E'  * `SELECT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_defaulted_column.syst_update_mode = 'always' THEN
                        E'  * `UPDATE` - Always updatable, even ' ||
                        E'when not otherwise user maintainable.\n'

                    WHEN var_defaulted_column.syst_update_mode = 'maint' THEN
                        E'  * `UPDATE` - Only user maintainable records.\n'

                    WHEN var_defaulted_column.syst_update_mode = 'never' THEN
                        ''
                END;

    END IF;

    IF var_defaulted_view.user_records THEN

        var_resolved_col_uops :=
            E'**User Defined Record Supported Operations**\n\n' ||
                CASE
                    WHEN var_defaulted_column.user_insert THEN
                        E'  * `INSERT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_defaulted_column.user_select THEN
                        E'  * `SELECT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_defaulted_column.user_update THEN
                        E'  * `UPDATE`\n'
                    ELSE
                        ''
                END;

    END IF;

    var_resolved_col_supp :=
        E'**Supplemental Notes**\n\n' ||
        p_column_config.supplemental;

    var_column_comment :=
        regexp_replace(
            var_resolved_col_desc || E'\n' ||
            var_resolved_col_reqs || E'\n\n' ||
            coalesce( var_resolved_col_uops || E'\n', '') ||
            coalesce( var_resolved_col_sops || E'\n', '') ||
            coalesce( var_resolved_col_supp || E'\n', '' ),
            '[\n\r\f\u000B\u0085\u2028\u2029]{3,}',
            E'\n\n' );

    EXECUTE format( 'COMMENT ON COLUMN %1$I.%2$I.%3$I IS %4$L;',
                    p_view_config.view_schema,
                    p_view_config.view_name,
                    p_column_config.column_name,
                    var_column_comment);

END;
$BODY$
LANGUAGE plpgsql;

ALTER FUNCTION
    ms_syst_priv.generate_comments_apiview_column(
        p_view_config   ms_syst_priv.comments_config_apiview,
        p_column_config ms_syst_priv.comments_config_apiview_column)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_apiview_column(
        p_view_config   ms_syst_priv.comments_config_apiview,
        p_column_config ms_syst_priv.comments_config_apiview_column)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_apiview_column(
        p_view_config   ms_syst_priv.comments_config_apiview,
        p_column_config ms_syst_priv.comments_config_apiview_column)
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_view_config   ms_syst_priv.comments_config_function_param;
    var_p_column_config ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'generate_comments_apiview_column';

    var_comments_config.description :=
$DOC$Generates API View Column comments based on the passed comment configurations.$DOC$;

    var_comments_config.general_usage :=
$DOC$While optional, if the targeted API View Column is identified as being closely
related to an underlying Data Table Column, this function will attempt to
extract descriptive texts from the Data Table Column comments so that these
descriptions don't need to be duplicated manually for the API View; this
behavior may be overridden in the passed comment configuration.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_view_config.param_name := 'p_view_config';
    var_p_view_config.description :=
$DOC$A value of type `ms_syst_priv.comments_config_apiview` which contains view
level configuration information such as identification of the view,
associated Data Table identification, available record modes (system defined
& user defined), and similar concerns which can influence column comment
generation.  This value is required, though only the following fields are
used:

  * `view_schema`  - (required)
  * `view_name`    - (required)
  * `table_schema` - (optional)
  * `table_name`   - (optional)
  * `user_records` - (optional)
  * `user_insert`  - (optional)
  * `user_select`  - (optional)
  * `user_update`  - (optional)
  * `syst_records` - (optional)
  * `syst_select`  - (optional)
  * `syst_update`  - (optional)

Any fields passed as `NULL` will assume their default values.  See the
database type documentation for more information, including to find any
defined field level default values.$DOC$;

    var_p_column_config.param_name := 'p_column_config';
    var_p_column_config.description :=
$DOC$A value of type `ms_syst_priv.comments_config_apiview_column` which
configures the comments to generate for the identified API View Column. See
the database type documenation for more information.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_p_view_config
            , var_p_column_config
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
