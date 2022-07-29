CREATE OR REPLACE FUNCTION msbms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_enum_items_maintain_sort_order.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_enums/msbms_syst_data/syst_enum_items/trig_b_i_syst_enum_items_maintain_sort_order.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    new.sort_order :=
        coalesce(
            new.sort_order,
            ( SELECT max( sort_order ) + 1
              FROM msbms_syst_data.syst_enum_items
              WHERE enum_id = new.enum_id ),
            1 );

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() TO <%= msbms_owner %>;


COMMENT ON FUNCTION msbms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() IS
$DOC$For INSERTed records with a null sort_order value, this trigger will assign a
default value assuming the new record should be inserted at the end of the sort.

If the inserted record was already assigned a sort_order value, the inserted
value is respected.$DOC$;
