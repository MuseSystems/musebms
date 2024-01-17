CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_copy_function(
        p_source_schema text,
        p_source_name text,
        p_target_schema text,
        p_target_name text,
        p_supplemental text DEFAULT NULL)
RETURNS VOID AS
$BODY$

-- File:        generate_comments_copy_function.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_copy_function.eex.sql
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
    var_source_comments       text;
    var_resolved_supplemental text;
    var_function_comments     text;
BEGIN

    var_source_comments :=
        ( SELECT
              pgd.description
          FROM
              pg_catalog.pg_proc pgp
                  JOIN pg_catalog.pg_namespace pgn
                       ON pgn.oid = pgp.pronamespace
                  JOIN pg_catalog.pg_description pgd
                       ON pgd.objoid = pgp.oid
          WHERE
                pgd.classoid = 'pg_proc'::regclass
            AND pgd.objsubid = 0
            AND pgn.nspname = p_source_schema
            AND pgp.proname = p_source_name);

    var_resolved_supplemental :=
        E'**Supplemental Notes**\n\n' || p_supplemental;

    var_function_comments :=
        regexp_replace(
            coalesce(var_source_comments || E'\n', '') ||
            coalesce(var_resolved_supplemental || E'\n', ''),
            '[\n\r\f\u000B\u0085\u2028\u2029]{3,}',
            E'\n\n' );

    EXECUTE format( 'COMMENT ON FUNCTION %1$I.%2$I IS %3$L;',
                    p_target_schema,
                    p_target_name,
                    var_function_comments);

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_copy_function(
        p_source_schema text,
        p_source_name text,
        p_target_schema text,
        p_target_name text,
        p_supplemental text )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_copy_function(
        p_source_schema text,
        p_source_name text,
        p_target_schema text,
        p_target_name text,
        p_supplemental text )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_copy_function(
        p_source_schema text,
        p_source_name text,
        p_target_schema text,
        p_target_name text,
        p_supplemental text )
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;
    
    -- Parameters
    var_p_source_schema ms_syst_priv.comments_config_function_param;
    var_p_source_name   ms_syst_priv.comments_config_function_param;
    var_p_target_schema ms_syst_priv.comments_config_function_param;
    var_p_target_name   ms_syst_priv.comments_config_function_param;
    var_p_supplemental  ms_syst_priv.comments_config_function_param;

BEGIN
    
    --
    -- Function Config
    --
    
    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'generate_comments_copy_function';

    var_comments_config.description :=
$DOC$Copies the comments of a source function to be the comments of a different
target function.$DOC$;

    var_comments_config.general_usage :=
$DOC$The use case for this function is many Public API functions are just wrappers
exposing functions defined in the private logic.  In these cases the private
function logic will generally apply to the Public API wrapper and the private
function can serve as a single source of the documentation.

Note that this function current doesn't work with overloaded functions.$DOC$;
    
    --
    -- Parameter Configs
    -- 

    var_p_source_schema.param_name := 'p_source_schema';
    var_p_source_schema.description :=
$DOC$The name of the schema which hosts the function whose comments are to be copied.$DOC$;

    var_p_source_name.param_name := 'p_source_name';
    var_p_source_name.description :=
$DOC$The function name from which comments will be copied.$DOC$;

    var_p_target_schema.param_name := 'p_target_schema';
    var_p_target_schema.description :=
$DOC$The name of the schema which hosts the function which will receive the copied
comments.$DOC$;

    var_p_target_name.param_name := 'p_target_name';
    var_p_target_name.description :=
$DOC$The name of the function to which the copied comments will be applied.$DOC$;

    var_p_supplemental.param_name := 'p_supplemental';
    var_p_supplemental.required := FALSE;
    var_p_supplemental.description :=
$DOC$An optional text which can be added to the copied comments in a special
"Supplemental" section.  This allows the target function to have additional
notes if appropriate.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_p_source_schema
            , var_p_source_name
            , var_p_target_schema
            , var_p_target_name
            , var_p_supplemental
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
