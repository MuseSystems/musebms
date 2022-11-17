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

COMMENT ON FUNCTION ms_syst_priv.get_random_string(p_length integer, p_tokens text) IS
$DOC$Returns a random text string, by default consisting of alpha-numeric symbols, of
the requested length. Arbitrary characters may be provided my the caller.$DOC$;
