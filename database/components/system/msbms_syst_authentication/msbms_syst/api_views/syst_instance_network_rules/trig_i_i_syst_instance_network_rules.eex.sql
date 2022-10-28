CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_instance_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/msbms_syst/api_views/syst_instance_network_rules/trig_i_i_syst_instance_network_rules.eex.sql
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

    INSERT INTO msbms_syst_data.syst_instance_network_rules
        ( instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper )
    VALUES
        ( new.instance_id
        , new.ordering
        , new.functional_type
        , new.ip_host_or_network
        , new.ip_host_range_lower
        , new.ip_host_range_upper )
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

ALTER FUNCTION msbms_syst.trig_i_i_syst_instance_network_rules()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_network_rules() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_instance_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_network_rules API View for INSERT operations.$DOC$;
