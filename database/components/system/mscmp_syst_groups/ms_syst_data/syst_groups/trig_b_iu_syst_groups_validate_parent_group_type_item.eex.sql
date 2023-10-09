CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_groups_validate_parent_group_type_item.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst_data/syst_groups/trig_b_iu_syst_groups_validate_parent_group_type_item.eex.sql
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

BEGIN

    IF
        new.parent_group_id IS NULL AND
        coalesce(
            (   SELECT
                    current_gti.hierarchy_depth != expected_gti.hierarchy_depth
                FROM
                    ms_syst_data.syst_group_type_items current_gti
                        JOIN ms_syst_data.syst_group_type_items expected_gti
                            ON expected_gti.group_type_id = current_gti.group_type_id
                WHERE
                    current_gti.id = new.group_type_item_id
                ORDER BY
                    expected_gti.hierarchy_depth
                LIMIT 1 )
           , TRUE)
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'A Group which is not a child of a parent group ' ||
                          'cannot be assigned a Group Type Item value that ' ||
                          'is not at the top of the Group Type hierarchy.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_iu_syst_groups_validate_parent_group_type_item'
                            ,p_exception_name => 'invalid_hierarchy_depth'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    IF
        new.parent_group_id IS NOT NULL AND
        coalesce(
            (   SELECT
                    expected_gti.hierarchy_depth != current_gti.hierarchy_depth
                FROM
                    ms_syst_data.syst_group_type_items current_gti,
                    ms_syst_data.syst_groups parent
                    JOIN ms_syst_data.syst_group_type_items parent_gti
                        ON  parent_gti.id = parent.group_type_item_id
                    JOIN ms_syst_data.syst_group_type_items expected_gti
                        ON  expected_gti.group_type_id = parent_gti.group_type_id AND
                            expected_gti.hierarchy_depth > parent_gti.hierarchy_depth
                WHERE
                        parent.id = new.parent_group_id
                    AND current_gti.id = new.group_type_item_id
                ORDER BY
                    expected_gti.hierarchy_depth
                LIMIT 1 )
            , TRUE )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'A child Group must assigned to the Group Type Item ' ||
                          'which is the next level down in the parent Group''s ' ||
                          'Group Type hierarchy.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_iu_syst_groups_validate_parent_group_type_item'
                            ,p_exception_name => 'invalid_hierarchy_depth'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_b_iu_syst_groups_validate_parent_group_type_item() IS
$DOC$Trigger ensures that a child Group's assigned Group Item Type is consistent as being at the top of
the hierarchy if no parent Group is referenced, or in the next lower level of the hierarchy of the
parent's Group Type Item assignment.$DOC$;
