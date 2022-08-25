CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_owner_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/api_views/syst_owner_network_rules/trig_i_u_syst_owner_network_rules.eex.sql
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

    IF
        new.owner_id  = old.owner_id OR
        new.ip_family = old.ip_family
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_owner_network_rules'
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

    UPDATE msbms_syst_data.syst_owner_network_rules
    SET
        ordering            = new.ordering
      , functional_type     = new.functional_type
      , ip_host_or_network  = new.ip_host_or_network
      , ip_host_range_lower = new.ip_host_range_lower
      , ip_host_range_upper = new.ip_host_range_upper
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_u_syst_owner_network_rules()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owner_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owner_network_rules() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_owner_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_network_rules API View for UPDATE operations.$DOC$;
