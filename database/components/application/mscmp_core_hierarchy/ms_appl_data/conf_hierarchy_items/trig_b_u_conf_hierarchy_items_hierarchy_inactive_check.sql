CREATE OR REPLACE FUNCTION ms_appl_data.trig_b_u_conf_hierarchy_items_hierarchy_inactive_check()
RETURNS trigger AS
$BODY$

-- File:        trig_b_u_conf_hierarchy_items_hierarchy_inactive_check.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_data/conf_hierarchy_items/trig_b_u_conf_hierarchy_items_hierarchy_inactive_check.sql
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
        (new.hierarchy_depth != old.hierarchy_depth
                OR new.required != old.required
                OR new.allow_leaf_nodes != old.allow_leaf_nodes)
                AND ( SELECT eft.internal_name = 'hierarchy_states_active'
                      FROM
                          ms_appl_data.conf_hierarchies ch
                              JOIN ms_syst_data.syst_enum_items ei
                                   ON ei.id = ch.hierarchy_state_id
                              JOIN ms_syst_data.syst_enum_functional_types eft
                                   ON eft.id = ei.functional_type_id
                      WHERE ch.id = new.hierarchy_id )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'Deleting Hierarchy Item records may only be done ' ||
                          'when the parent Hierarchy is in an "inactive" ' ||
                          'state.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl_data'
                            ,p_proc_name      => 'trig_b_d_conf_hierarchy_items_hierarchy_inactive_check'
                            ,p_exception_name => 'invalid_state'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_appl_data.trig_b_u_conf_hierarchy_items_hierarchy_inactive_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl_data.trig_b_u_conf_hierarchy_items_hierarchy_inactive_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl_data.trig_b_u_conf_hierarchy_items_hierarchy_inactive_check() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl_data.trig_b_u_conf_hierarchy_items_hierarchy_inactive_check() IS
$DOC$Ensures that, if a functionally significant column is changed during an update
operation, that the parent Hierarchy record is set to an "inactive" state.$DOC$;
