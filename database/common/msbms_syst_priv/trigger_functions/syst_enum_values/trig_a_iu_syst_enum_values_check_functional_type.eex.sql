CREATE OR REPLACE FUNCTION msbms_syst_priv.trig_a_iu_syst_enum_values_check_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_enum_values_check_functional_type.eex.sql
-- Location:    database\common\msbms_syst_priv\trigger_functions\syst_enum_values\trig_a_iu_syst_enum_values_check_functional_type.eex.sql
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

    IF
        NOT EXISTS( SELECT TRUE
                    FROM msbms_syst_data.syst_enums ce
                        JOIN msbms_syst_data.syst_enum_functional_types ceft
                            ON ceft.enum_id = ce.id
                    WHERE   ce.id   = new.enum_id
                        AND ceft.id = new.functional_type_id) AND
        EXISTS( SELECT TRUE
                FROM msbms_syst_data.syst_enums ce
                    JOIN msbms_syst_data.syst_enum_functional_types ceft
                        ON ceft.enum_id = ce.id
                WHERE   ce.id = new.enum_id)
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The enumeration requires a valid functional type to be specified.',
                DETAIL  = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_syst_enum_values_check_functional_types'
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

    RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_priv.trig_a_iu_syst_enum_values_check_functional_types()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_priv.trig_a_iu_syst_enum_values_check_functional_types() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_priv.trig_a_iu_syst_enum_values_check_functional_types() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_priv.trig_a_iu_syst_enum_values_check_functional_types() IS
$DOC$Ensures that if the parent syst_enums record has syst_enum_functional_types
records defined, a syst_enum_values record will reference one of those
functional types.  Note that this trigger function is intended to be use by
constraint triggers.$DOC$;
