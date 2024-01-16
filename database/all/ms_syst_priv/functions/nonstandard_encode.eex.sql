CREATE OR REPLACE FUNCTION
    ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint)
RETURNS text AS
$BODY$

-- File:        nonstandard_encode.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/nonstandard_encode.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- Note that this function is an adaptation of code published publicly by
-- David Sanabria (https://github.com/david-sanabria) at:
-- https://gist.github.com/david-sanabria/0d3ff67eb56d2750502aed4186d6a4a7
--
-- The original code is believed to be copyright David Sanabria.

DECLARE
    var_token_array text[]  := string_to_array(p_tokens, NULL );
    var_remainder   integer;
    var_interim     bigint;
    var_return_text text    := '';


BEGIN

    var_interim := abs( p_value );

    << conversion_loop >>
    LOOP
        var_remainder   := var_interim % p_base;
        var_interim     := var_interim / p_base;
        var_return_text := '' || var_token_array[( var_remainder + 1 )] || var_return_text;

        EXIT WHEN var_interim <= 0;

    END LOOP conversion_loop;

    RETURN var_return_text;

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint)
    TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_base   ms_syst_priv.comments_config_function_param;
    var_p_tokens ms_syst_priv.comments_config_function_param;
    var_p_value  ms_syst_priv.comments_config_function_param;
BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'nonstandard_encode';

    var_comments_config.trigger_function := FALSE;
    var_comments_config.trigger_timing   := ARRAY [ ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ ]::text[ ];

    var_comments_config.description :=
$DOC$Performs an encode operation, similar to the standard encode function, but for
non-standard encoding schemes such as Base32 or Base36.$DOC$;

    var_comments_config.general_usage :=
$DOC$$DOC$;

    --
    -- Parameter Configs
    --

    var_p_base.param_name := 'p_base';
    var_p_base.description :=
$DOC$The number base that the encoding system is expecting.  For example, Base36
the `p_base` value is `36`.$DOC$;

    var_p_tokens.param_name := 'p_tokens';
    var_p_tokens.description :=
$DOC$The tokens to use in representing the numbering scheme.  The count of
characters passed in this parameter should match the `p_base` parameter.$DOC$;

    var_p_value.param_name := 'p_value';
    var_p_value.description :=
$DOC$The decimal value to encode in the requested base.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_p_base
            , var_p_tokens
            , var_p_value
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
