CREATE OR REPLACE FUNCTION
    ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text)
RETURNS bigint AS
$BODY$

-- File:        nonstandard_decode.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/nonstandard_decode.eex.sql
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
    var_encoded_arr       text[];
    var_return_result     bigint  := 0;
    var_interim           bigint;
    var_index             integer; -- Pointer to input array
    var_token             text;
    var_power             integer := 0; -- reverse pointer, used for position exponent (e.g. 2^32)

BEGIN

    IF p_value IS NULL OR length( p_value ) = 0 THEN
        RETURN NULL;
    END IF;

    var_encoded_arr := string_to_array( reverse( p_value ), NULL );

    << conversion_loop >>
    FOREACH var_token IN ARRAY var_encoded_arr LOOP

        var_index := strpos( p_tokens, var_token );

        IF var_index <> 0 THEN

            var_interim       := ( ( var_index - 1 ) * pow( p_base, var_power ) );
            var_return_result := var_return_result + var_interim;
            var_power         := 1 + var_power;

        END IF;

    END LOOP conversion_loop;

    RETURN var_return_result;

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text)
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
    var_comments_config.function_name   := 'nonstandard_decode';

    var_comments_config.description :=
$DOC$Performs a decode to decimal operation, similar to the standard decode function,
but for non-standard decoding schemes such as Base32 or Base36.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_base.param_name := 'p_base';
    var_p_base.description :=
$DOC$The number base that the value has been encoded in.  For example, Base36
the `p_base` value is `36`.$DOC$;

    var_p_tokens.param_name := 'p_tokens';
    var_p_tokens.description :=
$DOC$The tokens used in representing the numbering scheme.  The count of
characters passed in this parameter should match the `p_base` parameter.$DOC$;

    var_p_value.param_name := 'p_value';
    var_p_value.description :=
$DOC$The encoded value to convert to decimal.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_p_base
            , var_p_tokens
            , var_p_value
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
