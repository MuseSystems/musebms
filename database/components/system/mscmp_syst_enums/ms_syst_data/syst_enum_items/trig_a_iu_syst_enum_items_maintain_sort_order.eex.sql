CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_enum_items_maintain_sort_order.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/trig_a_iu_syst_enum_items_maintain_sort_order.eex.sql
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

    UPDATE ms_syst_data.syst_enum_items
    SET sort_order = sort_order + 1
    WHERE enum_id = new.enum_id AND sort_order = new.sort_order AND id != new.id;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_a_iu_syst_enum_items_maintain_sort_order';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'a' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i', 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Automatically maintains the sort order of syst_enum_item records in cases where
sort ordering collides with existing syst_enum_items records for the same
enum_id.$DOC$;

    var_comments_config.general_usage :=
$DOC$On insert or update when the new sort_order value matches that of an existing
record for the enumeration, the system will sort the match record after the
new/updated record. This will cascade for all syst_enum_items records matching
the enum_id until the last one is updated.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
