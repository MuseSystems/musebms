CREATE OR REPLACE FUNCTION msbms_syst_data.trig_a_iu_syst_enum_values_maintain_sort_order()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_enum_values_maintain_sort_order.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst_data\tables\syst_enum_values\trig_a_iu_syst_enum_values_maintain_sort_order.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    UPDATE msbms_syst_data.syst_enum_values
    SET sort_order = sort_order + 1
    WHERE enum_id = new.enum_id AND sort_order = new.sort_order AND id != new.id;

    RETURN null;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_a_iu_syst_enum_values_maintain_sort_order()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_a_iu_syst_enum_values_maintain_sort_order() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_a_iu_syst_enum_values_maintain_sort_order() TO <%= msbms_owner %>;


COMMENT ON FUNCTION msbms_syst_data.trig_a_iu_syst_enum_values_maintain_sort_order() IS
$DOC$Automatically maintains the sort order of syst_enum_value records in cases where
sort ordering collides with existing syst_enum_values records for the same
enum_id.  On insert or update when the new sort_order value matches that of an
existing record for the enumeration, the system will sort the match record after
the new/updated record. This will cascade for all syst_enum_values records
matching the enum_id until the last one is updated.$DOC$;
