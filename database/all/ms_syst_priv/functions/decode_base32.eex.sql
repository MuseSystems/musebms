CREATE OR REPLACE FUNCTION ms_syst_priv.decode_base32(p_value text)
RETURNS bigint AS
$BODY$

-- File:        decode_base32.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/decode_base32.eex.sql
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
    var_resolved_value text :=
        upper(
            regexp_replace(
                regexp_replace( p_value, '[il]', '1', 'ig' ),
                'o', '0', 'ig' ));
BEGIN

    RETURN
        (SELECT
             ms_syst_priv.nonstandard_decode(
                 p_base   => 32,
                 p_tokens => '0123456789ABCDEFGHJKMNPQRSTVWXYZ',
                 P_value  => var_resolved_value));

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.decode_base32(p_value text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.decode_base32(p_value text) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.decode_base32(p_value text) TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_p_value ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'decode_base32';

    var_comments_config.description :=
$DOC$Decodes integers represented in Base32.  The representation here is that
designed by Douglas Crockford (https://www.crockford.com/base32.html).$DOC$;

    --
    -- Parameter Configs
    --

    var_p_value.param_name := 'p_value';
    var_p_value.description :=
        $DOC$The Base32 encoded value to decode back to a decimal representation.$DOC$;


    var_comments_config.params :=
        ARRAY [ var_p_value ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
