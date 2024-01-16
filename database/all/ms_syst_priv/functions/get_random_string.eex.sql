CREATE OR REPLACE FUNCTION ms_syst_priv.get_random_string(
                                  p_length integer
                                , p_tokens text DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' )
RETURNS text AS
$BODY$

-- File:        get_random_string.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/get_random_string.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- TODO: PostgreSQL's random function is not a cryptographically secure
--       source of randomness.  That's probably OK here, but we do expect
--       this function to be used to generate ID's so I'm not 100%
--       confident that OK.

SELECT
    string_agg(
        ( string_to_array( p_tokens, NULL ) )[round( ( length( p_tokens ) - 1 ) * random( ) ) + 1],
        '' )
FROM generate_series( 1, p_length );

$BODY$
LANGUAGE sql VOLATILE;

ALTER FUNCTION ms_syst_priv.get_random_string(p_length integer, p_tokens text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_random_string(p_length integer, p_tokens text) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_random_string(p_length integer, p_tokens text) TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_length ms_syst_priv.comments_config_function_param;
    var_p_tokens ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'get_random_string';

    var_comments_config.description :=
$DOC$Returns a random text string, by default consisting of alpha-numeric symbols, of
the requested length.

An arbitrary set of characters from which to draw the random string may be
provided my the caller.$DOC$;

    --
    -- Parameter Configs
    --

    var_p_length.param_name := 'p_length';
    var_p_length.description :=
$DOC$The number of random characters to return.$DOC$;

    var_p_tokens.param_name := 'p_tokens';
    var_p_tokens.required := FALSE;
    var_p_tokens.default_value := '`0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`';
    var_p_tokens.description :=
$DOC$An option alternate set of characters to use in the generation.$DOC$;


    var_comments_config.params :=
        ARRAY [
              var_p_length
            , var_p_tokens
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
