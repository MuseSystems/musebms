CREATE OR REPLACE FUNCTION msbms_syst_priv.encode_base32(p_value bigint)
RETURNS text AS
$BODY$

-- File:        encode_base32.eex.sql
-- Location:    musebms/database/all/msbms_syst_priv/functions/encode_base32.eex.sql
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
        msbms_syst_priv.nonstandard_encode(32, '0123456789ABCDEFGHJKMNPQRSTVWXYZ', p_value);

$BODY$
LANGUAGE sql IMMUTABLE;

ALTER FUNCTION msbms_syst_priv.encode_base32(p_value bigint)
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_priv.encode_base32(p_value bigint) FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_priv.encode_base32(p_value bigint) TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_priv.encode_base32(p_value bigint) IS
$DOC$Encodes a big integer value into Base32 representation.  The representation here
is that designed by Douglas Crockford (https://www.crockford.com/base32.html).$DOC$;
