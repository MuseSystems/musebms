CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_owner_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_owner_network_rules.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/msbms_syst/api_views/syst_owner_network_rules/trig_i_i_syst_owner_network_rules.eex.sql
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

    INSERT INTO msbms_syst_data.syst_owner_network_rules
        ( owner_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper )
    VALUES
        ( new.owner_id
        , new.ordering
        , new.functional_type
        , new.ip_host_or_network
        , new.ip_host_range_lower
        , new.ip_host_range_upper )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_i_syst_owner_network_rules()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_owner_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_owner_network_rules() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_owner_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_network_rules API View for INSERT operations.$DOC$;