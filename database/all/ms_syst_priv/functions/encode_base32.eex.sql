CREATE OR REPLACE FUNCTION ms_syst_priv.encode_base32(p_value bigint)
RETURNS text AS
$BODY$

-- File:        encode_base32.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/encode_base32.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

    SELECT
        ms_syst_priv.nonstandard_encode(32, '0123456789ABCDEFGHJKMNPQRSTVWXYZ', p_value);

$BODY$
LANGUAGE sql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.encode_base32(p_value bigint)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.encode_base32(p_value bigint) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.encode_base32(p_value bigint) TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'encode_base32';

    var_comments_config.description :=
$DOC$Encodes a big integer value into Base32 representation.  The representation here
is that designed by Douglas Crockford (https://www.crockford.com/base32.html).$DOC$;

    var_comments_config.general_usage :=
$DOC$$DOC$;

    --
    -- Parameter Configs
    --

    var_p_value.param_name := 'p_value';

    var_p_value.description :=
$DOC$The value to encode as a Crockford Base32 value.$DOC$;


    var_comments_config.params :=
        ARRAY [ var_p_value ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
