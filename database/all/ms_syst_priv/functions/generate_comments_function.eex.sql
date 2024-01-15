CREATE OR REPLACE FUNCTION
    ms_syst_priv.generate_comments_function(
        p_comments_config ms_syst_priv.comments_config_function
    )
RETURNS void AS
$BODY$

-- File:        generate_comments_function.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/generate_comments_function.eex.sql
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

    var_working_config       ms_syst_priv.comments_config_function;
    var_resolved_trigger     text := '';
    var_resolved_description text;
    var_resolved_params      text := '';
    var_resolved_general_use text;

    var_curr_param ms_syst_priv.comments_config_function_param;

    var_comment text;

BEGIN

    CASE
        WHEN nullif( p_comments_config.function_schema, '') IS NULL THEN
            RAISE EXCEPTION
                'Function comment configurations must specify which schema '
                'hosts the function.';

        WHEN nullif( p_comments_config.function_name, '') IS NULL THEN
            RAISE EXCEPTION
                'Function comment configurations must specify the name of the '
                'function being commented upon.';

        ELSE
            NULL;
    END CASE;

    var_working_config.function_schema := p_comments_config.function_schema;
    var_working_config.function_name   := p_comments_config.function_name;
    var_working_config.description     :=
        coalesce( p_comments_config.description, '( Routine Not Yet Documented )' );

    var_working_config.general_usage    := p_comments_config.general_usage;
    var_working_config.trigger_function :=
        coalesce( p_comments_config.trigger_function, false );

    var_working_config.trigger_timing :=
        coalesce( p_comments_config.trigger_timing, '{}'::text[] );

    var_working_config.trigger_ops :=
        coalesce( p_comments_config.trigger_ops, '{}'::text[] );

    var_working_config.params         :=
        coalesce(
            p_comments_config.params,
            '{}'::ms_syst_priv.comments_config_function_param[]
        );

    var_resolved_description := var_working_config.description;

    << trigger_block >>
    DECLARE
        var_timings text[ ] := '{}'::text[ ];
        var_ops     text[ ] := '{}'::text[ ];

    BEGIN
        IF var_working_config.trigger_function THEN

            -- Timings

            IF 'b' = ANY( var_working_config.trigger_timing ) THEN
                var_timings := var_timings || '`BEFORE`'::text;
            END IF;

            IF 'a' = ANY( var_working_config.trigger_timing ) THEN
                var_timings := var_timings || '`AFTER`'::text;
            END IF;

            IF 'i' = ANY( var_working_config.trigger_timing ) THEN
                var_timings := var_timings || '`INSTEAD OF`'::text;
            END IF;

            IF array_length( var_timings, 1) = 0 THEN
                var_timings := var_timings || '(Not Yet Documented)'::text;
            END IF;

            -- Operations

            IF 'i' = ANY( var_working_config.trigger_ops ) THEN
                var_ops := var_ops || '`INSERT`'::text;
            END IF;

            IF 'u' = ANY( var_working_config.trigger_ops ) THEN
                var_ops := var_ops || '`UPDATE`'::text;
            END IF;

            IF 'd' = ANY( var_working_config.trigger_ops ) THEN
                var_ops := var_ops || '`DELETE`'::text;
            END IF;

            IF array_length( var_ops, 1) = 0 THEN
                var_ops := var_ops || '(Not Yet Documented)'::text;
            END IF;

            var_resolved_trigger :=
                E'**Trigger Function Details**:\n\n' ||
                E'  * **Supported Timing**: ' ||
                array_to_string(var_timings, ', ') || E'\n\n' ||
                E'  * **Supported Operations**: ' ||
                array_to_string(var_ops, ', ');

        END IF;
    END trigger_block;

    var_resolved_general_use :=
        E'**General Usage**\n\n' || var_working_config.general_usage;

    << parameter_loop >>
    FOR var_curr_param IN
        SELECT
              p.param_name
            , coalesce( p.description, '( Parameter Not Yet Documented)' )
            , coalesce( p.required, TRUE )
            , coalesce( p.default_value, '( No Default )' )
        FROM unnest( var_working_config.params ) p
    LOOP
        IF nullif( var_curr_param.param_name, '' ) IS NULL THEN
            RAISE EXCEPTION
                'Parameter comment configurations must specify a valid '
                'parameter name.';
        END IF;

        -- TODO: The select thing below could almost certainly be cleaner. Put
        --       this on the clean-up list.  The only thing this does for sure
        --       is give us a declarative solution.

        var_resolved_params :=
            var_resolved_params ||
                '  * **`' || var_curr_param.param_name || E'`** :: ' ||
                '    **Required?** ' ||
                CASE WHEN var_curr_param.required THEN 'True' ELSE 'False' END ||
                '; **Default**: ' || var_curr_param.default_value || E'\n\n' ||
                ( SELECT
                      string_agg( '    ' || q.doc_line, E'\n' )
                  FROM
                      ( SELECT
                            regexp_split_to_table(
                                var_curr_param.description,
                                '[\n\r\f\u000B\u0085\u2028\u2029]' ) AS doc_line ) q ) ||
                E'\n\n';

    END LOOP parameter_loop;

    IF nullif( var_resolved_params, '' ) IS NOT NULL THEN
        var_resolved_params := E'**Parameters**\n\n' || var_resolved_params;
    END IF;

    var_comment :=
        regexp_replace(
            coalesce( var_resolved_description || E'\n\n', '' )  ||
            coalesce( var_resolved_trigger || E'\n\n', '' ) ||
            coalesce( var_resolved_params || E'\n\n', '' )  ||
            coalesce( var_resolved_general_use || E'\n\n', '' ),
            '[\n\r\f\u000B\u0085\u2028\u2029]{3,}',
            E'\n\n' );

    EXECUTE format( 'COMMENT ON FUNCTION %1$I.%2$I IS %3$L;',
                    var_working_config.function_schema,
                    var_working_config.function_name,
                    var_comment);

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.generate_comments_function(
        p_comments_config ms_syst_priv.comments_config_function
    )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_function(
        p_comments_config ms_syst_priv.comments_config_function
    )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.generate_comments_function(
        p_comments_config ms_syst_priv.comments_config_function
    )
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
    var_comments_config.function_name   := 'generate_comments_function';

    var_comments_config.description :=
$DOC$Generates comments for functions, procedures, and trigger functions.$DOC$;

    var_comments_config.general_usage :=
$DOC$If the default value of a documented function is longer than ~40 characters, it
may be better to set the `default_value` to refer to the "General Usage" section
and then explain the default value there. This due to line-length issues in the
resulting formatted comments.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_comments_config.param_name    := 'p_comments_config';
    var_p_comments_config.description   :=
$DOC$A configuration object of type `ms_syst_priv.comments_config_function` which
is used in automatically generating the appropriately formatted function
comments.$DOC$;

    var_comments_config.params :=
        ARRAY [
            var_p_comments_config
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
