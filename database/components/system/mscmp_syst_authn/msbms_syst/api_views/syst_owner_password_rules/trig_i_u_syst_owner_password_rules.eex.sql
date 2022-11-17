CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_owner_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/msbms_syst/api_views/syst_owner_password_rules/trig_i_u_syst_owner_password_rules.eex.sql
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

    IF new.owner_id != old.owner_id THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_owner_password_rules'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    UPDATE msbms_syst_data.syst_owner_password_rules
    SET
        password_length        = new.password_length
      , max_age                = new.max_age
      , require_upper_case     = new.require_upper_case
      , require_lower_case     = new.require_lower_case
      , require_numbers        = new.require_numbers
      , require_symbols        = new.require_symbols
      , disallow_recently_used = new.disallow_recently_used
      , disallow_compromised   = new.disallow_compromised
      , require_mfa            = new.require_mfa
      , allowed_mfa_types      = new.allowed_mfa_types
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_u_syst_owner_password_rules()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owner_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owner_password_rules() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_owner_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_password_rules API View for UPDATE operations.$DOC$;
