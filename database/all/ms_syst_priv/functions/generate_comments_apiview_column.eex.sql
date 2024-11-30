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
    v_src_table regclass;

    v_defaulted_view ms_syst_priv.comments_config_apiview;

    v_defaulted_column ms_syst_priv.comments_config_apiview_column;

    v_resolved_col_desc text;
    v_resolved_col_reqs text;
    v_resolved_col_sops text := '';
    v_resolved_col_uops text := '';
    v_resolved_col_supp text;

    v_col_syst_update_mode ms_syst_priv.comments_apiview_update_modes;

    v_column_comment text;

BEGIN

    v_src_table :=
        ( p_view_config.table_schema || '.' ||
            p_view_config.table_name )::regclass;

    v_defaulted_view.user_records :=
        coalesce( p_view_config.user_records, TRUE );

    v_defaulted_view.user_insert :=
        v_defaulted_view.user_records AND
        coalesce( p_view_config.user_insert, TRUE );

    v_defaulted_view.user_select :=
        v_defaulted_view.user_records AND
        coalesce( p_view_config.user_select, TRUE );

    v_defaulted_view.user_update :=
        v_defaulted_view.user_records AND
        coalesce( p_view_config.user_update, TRUE );

    v_defaulted_view.user_delete :=
        v_defaulted_view.user_records AND
        coalesce( p_view_config.user_delete, TRUE );

    v_defaulted_view.syst_records :=
        coalesce( p_view_config.syst_records, FALSE );

    v_defaulted_view.syst_select :=
        v_defaulted_view.syst_records AND
        coalesce( p_view_config.syst_select, TRUE );

    v_defaulted_view.syst_update :=
        v_defaulted_view.syst_records AND
        coalesce( p_view_config.syst_update, FALSE );

    v_defaulted_view.syst_delete :=
        v_defaulted_view.syst_records AND
        coalesce( p_view_config.syst_delete, FALSE );

    v_defaulted_column.required :=
        coalesce( p_column_config.required, FALSE );

    v_defaulted_column.unique_values :=
        coalesce( p_column_config.unique_values, FALSE );

    v_defaulted_column.default_value :=
        coalesce( p_column_config.default_value, '( No Default Value )' );

    v_defaulted_column.user_insert :=
        v_defaulted_view.user_records AND
        v_defaulted_view.user_insert AND
        coalesce( p_column_config.user_insert, TRUE );

    v_defaulted_column.user_select :=
        v_defaulted_view.user_records AND
        v_defaulted_view.user_select AND
        coalesce( p_column_config.user_select, TRUE );

    v_defaulted_column.user_update :=
        v_defaulted_view.user_records AND
        v_defaulted_view.user_update AND
        coalesce( p_column_config.user_update, TRUE );

    v_defaulted_column.syst_select :=
        v_defaulted_view.syst_records AND
        coalesce( p_column_config.syst_select, TRUE );

    v_defaulted_column.syst_update_mode :=
        CASE
            WHEN
                v_defaulted_view.syst_records AND
                v_defaulted_view.syst_update
            THEN
                coalesce( p_column_config.syst_update_mode, 'never' )
            ELSE
                'never'
        END;

    v_resolved_col_desc :=
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
                                ON pd.objoid = v_src_table
                                    AND pd.classoid = 'pg_catalog.pg_class'::regclass
                                    AND pd.objsubid = pa.attnum
              WHERE
                    pa.attrelid = v_src_table
                AND pa.attname = p_column_config.column_name
                AND pa.attnum > 0
                AND NOT pa.attisdropped ),
            '( Source column is not documented. )' );

    v_resolved_col_reqs :=
        E'**Data Requirements**\n\n  * Required?:               ' ||
        v_defaulted_column.required ||
        E'\n  * Unique Values Required?: ' ||
        v_defaulted_column.unique_values ||
        E'\n  * Default Value:           ' ||
        v_defaulted_column.default_value;

    IF v_defaulted_view.syst_records THEN

        v_resolved_col_sops :=
            E'**System Defined Record Supported Operations**\n\n' ||
                CASE
                    WHEN v_defaulted_column.syst_select THEN
                        E'  * `SELECT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN v_defaulted_column.syst_update_mode = 'always' THEN
                        E'  * `UPDATE` - Always updatable, even ' ||
                        E'when not otherwise user maintainable.\n'

                    WHEN v_defaulted_column.syst_update_mode = 'maint' THEN
                        E'  * `UPDATE` - Only user maintainable records.\n'

                    WHEN v_defaulted_column.syst_update_mode = 'never' THEN
                        ''
                END;

    END IF;

    IF v_defaulted_view.user_records THEN

        v_resolved_col_uops :=
            E'**User Defined Record Supported Operations**\n\n' ||
                CASE
                    WHEN v_defaulted_column.user_insert THEN
                        E'  * `INSERT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN v_defaulted_column.user_select THEN
                        E'  * `SELECT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN v_defaulted_column.user_update THEN
                        E'  * `UPDATE`\n'
                    ELSE
                        ''
                END;

    END IF;

    v_resolved_col_supp :=
        E'**Supplemental Notes**\n\n' ||
        p_column_config.supplemental;

    v_column_comment :=
        regexp_replace(
            v_resolved_col_desc || E'\n' ||
            v_resolved_col_reqs || E'\n\n' ||
            coalesce( v_resolved_col_uops || E'\n', '') ||
            coalesce( v_resolved_col_sops || E'\n', '') ||
            coalesce( v_resolved_col_supp || E'\n', '' ),
            '[\n\r\f\u000B\u0085\u2028\u2029]{3,}',
            E'\n\n' );

    EXECUTE format( 'COMMENT ON COLUMN %1$I.%2$I.%3$I IS %4$L;',
                    p_view_config.view_schema,
                    p_view_config.view_name,
                    p_column_config.column_name,
                    v_column_comment);

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
    v_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    v_p_view_config   ms_syst_priv.comments_config_function_param;
    v_p_column_config ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst_priv';
    v_comments_config.function_name   := 'generate_comments_apiview_column';

    v_comments_config.description :=
$DOC$Generates API View Column comments based on the passed comment configurations.$DOC$;

    v_comments_config.general_usage :=
$DOC$While optional, if the targeted API View Column is identified as being closely
related to an underlying Data Table Column, this function will attempt to
extract descriptive texts from the Data Table Column comments so that these
descriptions don't need to be duplicated manually for the API View; this
behavior may be overridden in the passed comment configuration.$DOC$;

    --
    -- Parameter Configs
    --

    v_p_view_config.param_name := 'p_view_config';
    v_p_view_config.description :=
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

    v_p_column_config.param_name := 'p_column_config';
    v_p_column_config.description :=
$DOC$A value of type `ms_syst_priv.comments_config_apiview_column` which
configures the comments to generate for the identified API View Column. See
the database type documenation for more information.$DOC$;

    v_comments_config.params :=
        ARRAY [
              v_p_view_config
            , v_p_column_config
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
