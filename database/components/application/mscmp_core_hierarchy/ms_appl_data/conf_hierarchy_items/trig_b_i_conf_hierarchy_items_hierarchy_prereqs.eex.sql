CREATE OR REPLACE FUNCTION ms_appl_data.trig_b_i_conf_hierarchy_items_hierarchy_prereqs()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_conf_hierarchy_items_hierarchy_prereqs.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_data/conf_hierarchy_items/trig_b_i_conf_hierarchy_items_hierarchy_prereqs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE

    var_context_data record;

BEGIN

    SELECT INTO var_context_data
        eft.internal_name = 'hierarchy_states_active' AS is_active
      , ch.structured
    FROM
        ms_appl_data.conf_hierarchies ch
            JOIN ms_syst_data.syst_enum_items ei
                 ON ei.id = ch.hierarchy_state_id
            JOIN ms_syst_data.syst_enum_functional_types eft
                 ON eft.id = ei.functional_type_id
    WHERE ch.id = new.hierarchy_id;

    CASE
        WHEN var_context_data.is_active THEN

            RAISE EXCEPTION
                USING
                    MESSAGE = 'Inserting Hierarchy Item records may only be ' ||
                              'done when the parent Hierarchy is in an ' ||
                              '"inactive" state.',
                    DETAIL  = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_appl_data'
                                ,p_proc_name      =>
                                    'trig_b_i_conf_hierarchy_items_hierarchy_prereqs'
                                ,p_exception_name => 'invalid_state'
                                ,p_errcode        => 'PM003'
                                ,p_param_data     => to_jsonb( new )
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM003',
                    SCHEMA  = tg_table_schema,
                    TABLE   = tg_table_name;


        WHEN NOT var_context_data.structured THEN

            RAISE EXCEPTION
                USING
                    MESSAGE = 'Hierarchy Item records may not be inserted ' ||
                              'for unstructured Hierarchies.',
                    DETAIL  = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_appl_data'
                                ,p_proc_name      =>
                                    'trig_b_i_conf_hierarchy_items_hierarchy_prereqs'
                                ,p_exception_name => 'invalid_state'
                                ,p_errcode        => 'PM003'
                                ,p_param_data     => to_jsonb( new )
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM003',
                    SCHEMA  = tg_table_schema,
                    TABLE   = tg_table_name;

        ELSE

            RETURN new;

    END CASE;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_appl_data.trig_b_i_conf_hierarchy_items_hierarchy_prereqs()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl_data.trig_b_i_conf_hierarchy_items_hierarchy_prereqs() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl_data.trig_b_i_conf_hierarchy_items_hierarchy_prereqs() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl_data.trig_b_i_conf_hierarchy_items_hierarchy_prereqs() IS
$DOC$Validates that the Hierarchy conditions of being in an "inactive" state and
that the Hierarchy is a "structured" Hierarchy are true.$DOC$;
