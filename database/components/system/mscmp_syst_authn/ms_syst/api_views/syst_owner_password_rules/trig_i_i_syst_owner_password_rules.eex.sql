CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_owner_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_password_rules/trig_i_i_syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_owner_password_rules
        ( owner_id
        , password_length
        , max_age
        , require_upper_case
        , require_lower_case
        , require_numbers
        , require_symbols
        , disallow_recently_used
        , disallow_compromised
        , require_mfa
        , allowed_mfa_types )
    VALUES
        ( new.owner_id
        , new.password_length
        , new.max_age
        , new.require_upper_case
        , new.require_lower_case
        , new.require_numbers
        , new.require_symbols
        , new.disallow_recently_used
        , new.disallow_compromised
        , new.require_mfa
        , new.allowed_mfa_types )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_owner_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_password_rules API View for INSERT operations.$DOC$;