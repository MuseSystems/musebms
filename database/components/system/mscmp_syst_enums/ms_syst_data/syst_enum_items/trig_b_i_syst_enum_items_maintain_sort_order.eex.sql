CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_enum_items_maintain_sort_order.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/trig_b_i_syst_enum_items_maintain_sort_order.eex.sql
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
              FROM ms_syst_data.syst_enum_items
              WHERE enum_id = new.enum_id ),
            1 );

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_b_i_syst_enum_items_maintain_sort_order';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$For INSERTed records with a null sort_order value, this trigger will assign a
default value assuming the new record should be inserted at the end of the sort.$DOC$;

    var_comments_config.general_usage :=
$DOC$If the inserted record was already assigned a sort_order value, the inserted
value is respected.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
