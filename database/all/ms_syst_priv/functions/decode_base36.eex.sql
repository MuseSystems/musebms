CREATE OR REPLACE FUNCTION ms_syst_priv.decode_base36(p_value text)
RETURNS bigint AS
$BODY$

-- File:        decode_base36.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/decode_base36.eex.sql
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
    v_resolved_value text := upper(p_value);
BEGIN

    RETURN
        (SELECT
             ms_syst_priv.nonstandard_decode(
                 p_base   => 36,
                 p_tokens => '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                 P_value  => v_resolved_value));

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.decode_base36(p_value text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.decode_base36(p_value text) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.decode_base36(p_value text) TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    v_p_value ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst_priv';
    v_comments_config.function_name   := 'decode_base36';

    v_comments_config.description :=
$DOC$Decodes integers represented in Base36 notation back to decimal form.$DOC$;

    --
    -- Parameter Configs
    --

    v_p_value.param_name := 'p_value';
    v_p_value.description :=
$DOC$The Base36 value to decode to decimal.$DOC$;

    v_comments_config.params :=
        ARRAY [ v_p_value ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
