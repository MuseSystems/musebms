CREATE OR REPLACE FUNCTION msbms_syst_data.trig_a_iu_syst_owner_network_rule_ordering()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_owner_network_rule_ordering.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_authentication/msbms_syst_data/syst_owner_network_rules/trig_a_iu_syst_owner_network_rule_ordering.eex.sql
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

    UPDATE msbms_syst_data.syst_owner_network_rules
    SET ordering = ordering + 1
    WHERE owner_id = new.owner_id AND ordering = new.ordering AND id != new.id;

    RETURN null;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_a_iu_syst_owner_network_rule_ordering()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_a_iu_syst_owner_network_rule_ordering() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_a_iu_syst_owner_network_rule_ordering() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_a_iu_syst_owner_network_rule_ordering() IS
$DOC$Ensures that the ordering of network rules is maintained and that ordering
values are not duplicated.$DOC$;
