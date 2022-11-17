CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_enum_functional_type_validate_new_allowed.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_functional_types/trig_b_i_syst_enum_functional_type_validate_new_allowed.eex.sql
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

    IF
        NOT EXISTS(SELECT TRUE
                    FROM ms_syst_data.syst_enum_functional_types
                    WHERE enum_id = new.enum_id) AND
        EXISTS(
                SELECT TRUE
                FROM ms_syst_data.syst_enum_items
                WHERE enum_id = new.enum_id
            )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot add a functional type requirement after enumeration item ' ||
                          'records have already been defined.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_i_syst_enum_functional_type_validate_new_allowed'
                            ,p_exception_name => 'invalid_functional_type'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(new)
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
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed() IS
$DOC$Checks to see if this is the first functional type being added for the
enumeration and, if so, that no syst_enum_items records already exist.  Adding a
first functional type for an enumeration which already has defined enumeration
items implies that the enumeration items must be assigned a functional type in
the same operation to keep data consistency.  In practice, this would be
difficult since there would almost certainly have to be multiple functional
types available in order to avoid making bogus assignments; it would be much
more difficult to manage such a process as compared to simply disallowing the
scenario.$DOC$;
