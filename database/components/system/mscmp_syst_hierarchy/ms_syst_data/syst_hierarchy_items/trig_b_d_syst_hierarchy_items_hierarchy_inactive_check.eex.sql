CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_d_syst_hierarchy_items_hierarchy_inactive_check()
RETURNS trigger AS
$BODY$

-- File:        trig_b_d_syst_hierarchy_items_hierarchy_inactive_check.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchy_items/trig_b_d_syst_hierarchy_items_hierarchy_inactive_check.eex.sql
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
        ( SELECT eft.internal_name = 'hierarchy_states_active'
          FROM ms_syst_data.syst_hierarchies ch
              JOIN ms_syst_data.syst_enum_items ei
                ON ei.id = ch.hierarchy_state_id
              JOIN ms_syst_data.syst_enum_functional_types eft
                  ON eft.id = ei.functional_type_id
          WHERE ch.id = old.hierarchy_id )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'Deleting Hierarchy Item records may only be done ' ||
                          'when the parent Hierarchy is in an "inactive" ' ||
                          'state.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl_data'
                            ,p_proc_name      => 'trig_b_d_syst_hierarchy_items_hierarchy_inactive_check'
                            ,p_exception_name => 'invalid_state'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb( old )
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM003',
                SCHEMA  = tg_table_schema,
                TABLE   = tg_table_name;

    END IF;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_d_syst_hierarchy_items_hierarchy_inactive_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_hierarchy_items_hierarchy_inactive_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_hierarchy_items_hierarchy_inactive_check() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_b_d_syst_hierarchy_items_hierarchy_inactive_check';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'd' ]::text[ ];

    var_comments_config.description :=
$DOC$Verifies that the parent Hierarchy is in an "inactive" prior to allowing
deletion of the Hierarchy Item record.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
