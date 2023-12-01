CREATE OR REPLACE FUNCTION ms_appl_data.trig_b_u_conf_hierarchies_validate_state_change()
RETURNS trigger AS
$BODY$

-- File:        trig_b_u_conf_hierarchies_validate_state_change.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl_data/conf_hierarchies/trig_b_u_conf_hierarchies_validate_state_change.eex.sql
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

    IF old.hierarchy_state_id = new.hierarchy_state_id THEN
        RETURN new;
    END IF;

    SELECT INTO var_context_data
        eft.internal_name AS new_state_name
    FROM
        ms_syst_data.syst_enum_items ei
            JOIN ms_syst_data.syst_enum_functional_types eft
                 ON eft.id = ei.functional_type_id
    WHERE ei.id = new.hierarchy_state_id;

    CASE var_context_data.new_state_name
        WHEN 'hierarchy_states_active' THEN

            IF NOT ms_appl_priv.is_hierarchy_config_valid( new ) THEN

                RAISE EXCEPTION
                    USING
                        MESSAGE = 'Hierarchy records may not be set to an ' ||
                                  '"active" state unless the Hierarchy record and ' ||
                                  'all associated Hierarchy Item records are ' ||
                                  'consistent and valid.',
                        DETAIL  = ms_syst_priv.get_exception_details(
                                     p_proc_schema    => 'ms_appl_data'
                                    ,p_proc_name      =>
                                        'trig_b_u_conf_hierarchies_validate_state_change'
                                    ,p_exception_name => 'invalid_state'
                                    ,p_errcode        => 'PM003'
                                    ,p_param_data     =>
                                        jsonb_build_object('new', new, 'old', old)
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

            END IF;

        WHEN 'hierarchy_states_inactive' THEN

            IF ms_appl.is_hierarchy_record_referenced( new.id ) THEN

                RAISE EXCEPTION
                    USING
                        MESSAGE = 'Hierarchy records may not be set to an ' ||
                                  '"inactive" state when the data of hierarchy ' ||
                                  'implementing Components still reference the ' ||
                                  'Hierarchy record.',
                        DETAIL  = ms_syst_priv.get_exception_details(
                                     p_proc_schema    => 'ms_appl_data'
                                    ,p_proc_name      =>
                                        'trig_b_u_conf_hierarchies_validate_state_change'
                                    ,p_exception_name => 'invalid_state'
                                    ,p_errcode        => 'PM003'
                                    ,p_param_data     =>
                                        jsonb_build_object('new', new, 'old', old)
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

            END IF;

    END CASE;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_appl_data.trig_b_u_conf_hierarchies_validate_state_change()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl_data.trig_b_u_conf_hierarchies_validate_state_change() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl_data.trig_b_u_conf_hierarchies_validate_state_change() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl_data.trig_b_u_conf_hierarchies_validate_state_change() IS
$DOC$Checks that a Hierarchy record's state may be changed while ensuring that
such a change doesn't allow for data inconsistencies with either of the
Hierarchy or the data of Hierarchy implementing Components.

Setting the Hierarchy to an "active" state requires that the Hierarchy and its
associated Hierarchy Items are complete and fully self-consistent.  For the
"inactive" check, the Hierarchy may not be in use which is defined as being
referenced in the data of Hierarchy implementing Components.$DOC$;
