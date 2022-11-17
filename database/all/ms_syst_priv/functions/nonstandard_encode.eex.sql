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

COMMENT ON
    FUNCTION ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint) IS
$DOC$Performs an encode operation, similar to the standard encode function, but for
non-standard encoding schemes, such as Base32 or Base36.$DOC$;
