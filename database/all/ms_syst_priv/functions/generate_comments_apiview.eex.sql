CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_apiview(
        p_comments_config ms_syst_priv.comments_config_apiview)
RETURNS void AS
$BODY$

-- File:        generate_comments_apiview.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_apiview.eex.sql
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
    var_dst_view  regclass;

    var_resolved_view_desc text;
    var_resolved_view_sops text := '';
    var_resolved_view_uops text := '';
    var_resolved_view_supp text;

    var_view_comment text;

    var_working_config ms_syst_priv.comments_config_apiview;

BEGIN

    /***************************************************************************
      API View Comment Generation
     **************************************************************************/

    var_src_table :=
        CASE
            WHEN
                p_comments_config.table_schema IS NOT NULL AND
                    p_comments_config.table_name IS NOT NULL
            THEN
                ((p_comments_config.table_schema) ||
                    '.' ||
                    (p_comments_config.table_name))::regclass
            ELSE
                NULL::regclass
        END;

    var_dst_view :=
        ((p_comments_config.view_schema) ||
            '.' ||
            (p_comments_config.view_name))::regclass;

    var_working_config.table_schema := p_comments_config.table_schema;
    var_working_config.table_name   := p_comments_config.table_name;
    var_working_config.view_schema  := p_comments_config.view_schema;
    var_working_config.view_name    := p_comments_config.view_name;

    var_working_config.user_records :=
        coalesce( p_comments_config.user_records, TRUE );

    var_working_config.user_insert :=
        var_working_config.user_records AND
        coalesce( p_comments_config.user_insert, TRUE );

    var_working_config.user_select :=
        var_working_config.user_records AND
        coalesce( p_comments_config.user_select, TRUE );

    var_working_config.user_update :=
        var_working_config.user_records AND
        coalesce( p_comments_config.user_update, TRUE );

    var_working_config.user_delete :=
        var_working_config.user_records AND
        coalesce( p_comments_config.user_delete, TRUE );

    var_working_config.syst_records :=
        coalesce( p_comments_config.syst_records, FALSE );

    var_working_config.syst_select :=
        var_working_config.syst_records AND
        coalesce( p_comments_config.syst_select, TRUE );

    var_working_config.syst_update :=
        var_working_config.syst_records AND
        coalesce( p_comments_config.syst_update, FALSE );

    var_working_config.syst_delete :=
        var_working_config.syst_records AND
        coalesce( p_comments_config.syst_delete, FALSE );

    var_working_config.generate_common :=
        CASE
            WHEN
                p_comments_config.table_schema IS NOT NULL AND
                    p_comments_config.table_name IS NOT NULL
            THEN
                coalesce( p_comments_config.generate_common, TRUE )
            ELSE
                FALSE
        END;

    var_resolved_view_desc :=
            coalesce(
                p_comments_config.override_description,
                ( SELECT
                      regexp_substr(
                          pd.description,
                          '^(?:(?!\n\*\*Direct Usage\*\*).)*',
                          1, 1 )
                  FROM pg_catalog.pg_description pd
                  WHERE
                        pd.objoid = var_src_table
                    AND pd.classoid = 'pg_class'::regclass
                    AND pd.objsubid = 0 ),
                '( Source Data is not documented. )' );

    IF var_working_config.syst_records THEN

        var_resolved_view_sops :=
            E'**System Defined Record Supported Operations**\n\n' ||
                CASE
                    WHEN var_working_config.syst_select THEN
                        E'  * `SELECT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_working_config.syst_update THEN
                        E'  * `UPDATE` - See column comments for applicable' ||
                            E' restrictions.\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_working_config.syst_delete THEN
                        E'  * `DELETE` - Only user maintainable records.\n'
                    ELSE
                        ''
                END;

    END IF;

    IF var_working_config.user_records THEN

        var_resolved_view_uops :=
            E'**User Defined Record Supported Operations**\n\n' ||
                CASE
                    WHEN var_working_config.user_insert THEN
                        E'  * `INSERT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_working_config.user_select THEN
                        E'  * `SELECT`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_working_config.user_update THEN
                        E'  * `UPDATE`\n'
                    ELSE
                        ''
                END ||
                CASE
                    WHEN var_working_config.user_delete THEN
                        E'  * `DELETE`\n'
                    ELSE
                        ''
                END;

    END IF;

    var_resolved_view_supp :=
        E'**Supplemental Notes**\n\n' ||
        p_comments_config.supplemental;

    var_view_comment :=
        regexp_replace(
            var_resolved_view_desc || E'\n' ||
            var_resolved_view_uops || E'\n' ||
            var_resolved_view_sops || E'\n' ||
            coalesce(var_resolved_view_supp || E'\n', ''),
            '[\n\r\f\u000B\u0085\u2028\u2029]{3,}',
            E'\n\n' );

    EXECUTE format( 'COMMENT ON VIEW %1$I.%2$I IS %3$L;',
                    var_working_config.view_schema,
                    var_working_config.view_name,
                    var_view_comment);

    /***************************************************************************
      Column Comment Generation
     **************************************************************************/

    IF var_working_config.generate_common THEN

        PERFORM
            ms_syst_priv.generate_comments_apiview_common_columns(
                p_view_config => var_working_config );

    END IF;

    PERFORM
        ms_syst_priv.generate_comments_apiview_column(
            p_view_config   => var_working_config,
            p_column_config => c )
    FROM
        unnest( p_comments_config.columns ) c;


END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_apiview(
        p_comments_config ms_syst_priv.comments_config_apiview)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_apiview(
        p_comments_config ms_syst_priv.comments_config_apiview)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_apiview(
        p_comments_config ms_syst_priv.comments_config_apiview)
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_comments_config ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'generate_comments_apiview';

    var_comments_config.description :=
$DOC$Generates API View comments as well as comments for any requested columns.

API Views are typically closely associated with specific Data Tables.  While
this function does not require Data Table to API View parity of columns, types,
etc. it does assume that a substantial amount of Data Table to API View parity
exists.  Given this, the descriptive texts of the API View and its columns are
extracted from the Data Table comments and applied to the API View.  Additional
information that is specific for the API View is then added using the
configurations passed in the `p_comments_config` parameter.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_comments_config.param_name := 'p_comments_config';
    var_p_comments_config.description :=
$DOC$A `ms_syst_priv.comments_config_apiview` value which provides the configuration
and texts from which to generate the API View documentation.  See the
documentation of that database type for more information.$DOC$;


    var_comments_config.params :=
        ARRAY [ var_p_comments_config ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
