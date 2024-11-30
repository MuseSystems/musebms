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
    v_token_array text[]  := string_to_array(p_tokens, NULL );
    v_remainder   integer;
    v_interim     bigint;
    v_return_text text    := '';


BEGIN

    v_interim := abs( p_value );

    << conversion_loop >>
    LOOP
        v_remainder   := v_interim % p_base;
        v_interim     := v_interim / p_base;
        v_return_text := '' || v_token_array[( v_remainder + 1 )] || v_return_text;

        EXIT WHEN v_interim <= 0;

    END LOOP conversion_loop;

    RETURN v_return_text;

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
    v_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    v_p_base   ms_syst_priv.comments_config_function_param;
    v_p_tokens ms_syst_priv.comments_config_function_param;
    v_p_value  ms_syst_priv.comments_config_function_param;
BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst_priv';
    v_comments_config.function_name   := 'nonstandard_encode';

    v_comments_config.trigger_function := FALSE;
    v_comments_config.trigger_timing   := ARRAY [ ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ ]::text[ ];

    v_comments_config.description :=
$DOC$Performs an encode operation, similar to the standard encode function, but for
non-standard encoding schemes such as Base32 or Base36.$DOC$;

    --
    -- Parameter Configs
    --

    v_p_base.param_name := 'p_base';
    v_p_base.description :=
$DOC$The number base that the encoding system is expecting.  For example, Base36
the `p_base` value is `36`.$DOC$;

    v_p_tokens.param_name := 'p_tokens';
    v_p_tokens.description :=
$DOC$The tokens to use in representing the numbering scheme.  The count of
characters passed in this parameter should match the `p_base` parameter.$DOC$;

    v_p_value.param_name := 'p_value';
    v_p_value.description :=
$DOC$The decimal value to encode in the requested base.$DOC$;

    v_comments_config.params :=
        ARRAY [
              v_p_base
            , v_p_tokens
            , v_p_value
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
