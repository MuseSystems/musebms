CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_instance_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/msbms_syst/api_views/syst_instance_network_rules/trig_i_u_syst_instance_network_rules.eex.sql
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
        new.instance_id != old.instance_id OR
        new.ip_family   != old.ip_family
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_instance_network_rules'
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

    UPDATE msbms_syst_data.syst_instance_network_rules
    SET
        ordering            = new.ordering
      , functional_type     = new.functional_type
      , ip_host_or_network  = new.ip_host_or_network
      , ip_host_range_lower = new.ip_host_range_lower
      , ip_host_range_upper = new.ip_host_range_upper
    WHERE id = new.id
    RETURNING id
        , instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_u_syst_instance_network_rules()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_network_rules() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_instance_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_network_rules API View for UPDATE operations.$DOC$;